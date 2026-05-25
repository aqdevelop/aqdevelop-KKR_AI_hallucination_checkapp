import re
from urllib.parse import quote, urlparse

import httpx

from app.core.config import settings
from app.models.schemas import Source
from app.services import trust


BRAVE_URL = "https://api.search.brave.com/res/v1/web/search"
GOOGLE_URL = "https://www.googleapis.com/customsearch/v1"
NAVER_URL = "https://openapi.naver.com/v1/search/webkr.json"
_UA = "Mozilla/5.0 (compatible; FactLensBot/1.0; +https://factlens.app)"

_HTML_TAG = re.compile(r"<[^>]+>")
_HTML_ENTITY = {"&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": '"', "&#39;": "'"}


def _clean_html(s: str) -> str:
    s = _HTML_TAG.sub("", s)
    for k, v in _HTML_ENTITY.items():
        s = s.replace(k, v)
    return s.strip()


async def search(query: str, language: str = "ko") -> list[Source]:
    if settings.mock_mode:
        return _mock_sources(query)

    results: list[Source] = []

    # Wikipedia first — authoritative, free, no key. Best ground-truth source.
    if settings.enable_wikipedia:
        try:
            results += await _wikipedia(query, language)
        except Exception as e:
            print(f"[SEARCH] wikipedia failed for '{query[:40]}': {type(e).__name__}: {str(e)[:120]}", flush=True)

    if language == "ko" and settings.naver_client_id and settings.naver_client_secret:
        try:
            results += await _naver(query)
        except Exception as e:
            print(f"[SEARCH] naver failed for '{query[:40]}': {type(e).__name__}: {str(e)[:120]}", flush=True)

    web_count = sum(1 for s in results if "wikipedia.org" not in s.url)
    if web_count < 3 and settings.brave_search_api_key:
        try:
            results += await _brave(query, language)
        except Exception as e:
            print(f"[SEARCH] brave failed for '{query[:40]}': {type(e).__name__}: {str(e)[:120]}", flush=True)

    web_count = sum(1 for s in results if "wikipedia.org" not in s.url)
    if web_count < 3 and settings.google_cse_api_key:
        try:
            results += await _google(query)
        except Exception as e:
            print(f"[SEARCH] google failed for '{query[:40]}': {type(e).__name__}: {str(e)[:120]}", flush=True)

    return dedupe_sources(results)[: settings.search_results_per_query * 2]


async def _wikipedia(query: str, language: str) -> list[Source]:
    lang = "ko" if language == "ko" else "en"
    api = f"https://{lang}.wikipedia.org/w/api.php"
    async with httpx.AsyncClient(timeout=8.0, headers={"User-Agent": _UA}) as client:
        r = await client.get(api, params={
            "action": "query",
            "list": "search",
            "srsearch": query,
            "srlimit": 3,
            "format": "json",
        })
        r.raise_for_status()
        hits = r.json().get("query", {}).get("search", [])
    out: list[Source] = []
    for h in hits[:3]:
        title = h.get("title", "")
        if not title:
            continue
        url = f"https://{lang}.wikipedia.org/wiki/" + quote(title.replace(" ", "_"))
        out.append(Source(
            url=url,
            title=f"{title} - 위키백과",
            snippet=_clean_html(h.get("snippet", "")),
            trust=trust.score(url),
        ))
    return out


async def _naver(query: str) -> list[Source]:
    headers = {
        "X-Naver-Client-Id": settings.naver_client_id,
        "X-Naver-Client-Secret": settings.naver_client_secret,
    }
    params = {
        "query": query,
        "display": min(settings.search_results_per_query, 10),
        "sort": "sim",
    }
    async with httpx.AsyncClient(timeout=10.0) as client:
        r = await client.get(NAVER_URL, headers=headers, params=params)
        r.raise_for_status()
        data = r.json()
    out: list[Source] = []
    for item in data.get("items", []):
        url = item.get("link", "")
        if not url:
            continue
        out.append(Source(
            url=url,
            title=_clean_html(item.get("title", "")),
            snippet=_clean_html(item.get("description", "")),
            trust=trust.score(url),
        ))
    return out


async def _brave(query: str, language: str) -> list[Source]:
    headers = {
        "Accept": "application/json",
        "X-Subscription-Token": settings.brave_search_api_key,
    }
    params = {
        "q": query,
        "count": settings.search_results_per_query,
        "search_lang": "ko" if language == "ko" else "en",
        "country": "KR" if language == "ko" else "US",
    }
    async with httpx.AsyncClient(timeout=10.0) as client:
        r = await client.get(BRAVE_URL, headers=headers, params=params)
        r.raise_for_status()
        data = r.json()
    out: list[Source] = []
    for item in data.get("web", {}).get("results", []):
        url = item.get("url", "")
        if not url:
            continue
        out.append(Source(
            url=url,
            title=item.get("title", ""),
            snippet=item.get("description", ""),
            trust=trust.score(url),
        ))
    return out


async def _google(query: str) -> list[Source]:
    params = {
        "key": settings.google_cse_api_key,
        "cx": settings.google_cse_id,
        "q": query,
        "num": min(settings.search_results_per_query, 10),
    }
    async with httpx.AsyncClient(timeout=10.0) as client:
        r = await client.get(GOOGLE_URL, params=params)
        r.raise_for_status()
        data = r.json()
    out: list[Source] = []
    for item in data.get("items", []):
        url = item.get("link", "")
        if not url:
            continue
        out.append(Source(
            url=url,
            title=item.get("title", ""),
            snippet=item.get("snippet", ""),
            trust=trust.score(url),
        ))
    return out


def dedupe_sources(sources: list[Source], per_host: int = 2) -> list[Source]:
    """Dedupe by exact URL, capping how many results one host may contribute.

    Sorted by trust so the best page from each host survives the cap. Unlike
    the old host-unique dedupe, this keeps multiple authoritative pages
    (e.g. several Wikipedia articles) instead of throwing them away.
    """
    seen_urls: set[str] = set()
    host_count: dict[str, int] = {}
    out: list[Source] = []
    for s in sorted(sources, key=lambda x: x.trust, reverse=True):
        if s.url in seen_urls:
            continue
        host = (urlparse(s.url).hostname or s.url).lower()
        if host_count.get(host, 0) >= per_host:
            continue
        seen_urls.add(s.url)
        host_count[host] = host_count.get(host, 0) + 1
        out.append(s)
    return out


def _mock_sources(query: str) -> list[Source]:
    return [
        Source(
            url="https://ko.wikipedia.org/wiki/" + query.replace(" ", "_"),
            title=f"{query} - 위키백과",
            snippet=f"이 항목은 '{query}'에 대한 모의 검색 결과입니다. (MOCK_MODE)",
            trust=0.85,
        ),
        Source(
            url="https://www.yna.co.kr/view/mock-" + query[:10],
            title=f"{query} 관련 보도",
            snippet=f"'{query}'에 관한 모의 뉴스 스니펫.",
            trust=0.85,
        ),
    ]
