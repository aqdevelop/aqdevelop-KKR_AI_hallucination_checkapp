import re

import httpx

from app.core.config import settings
from app.models.schemas import Source
from app.services import trust


BRAVE_URL = "https://api.search.brave.com/res/v1/web/search"
GOOGLE_URL = "https://www.googleapis.com/customsearch/v1"
NAVER_URL = "https://openapi.naver.com/v1/search/webkr.json"

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

    if language == "ko" and settings.naver_client_id and settings.naver_client_secret:
        try:
            results = await _naver(query)
        except Exception as e:
            print(f"[SEARCH] naver failed for '{query[:40]}': {type(e).__name__}: {str(e)[:120]}", flush=True)

    if len(results) < 3 and settings.brave_search_api_key:
        try:
            results += await _brave(query, language)
        except Exception as e:
            print(f"[SEARCH] brave failed for '{query[:40]}': {type(e).__name__}: {str(e)[:120]}", flush=True)

    if language == "ko" and len(results) < 3 and settings.google_cse_api_key:
        try:
            results += await _google(query)
        except Exception as e:
            print(f"[SEARCH] google failed for '{query[:40]}': {type(e).__name__}: {str(e)[:120]}", flush=True)

    return _dedupe(results)[: settings.search_results_per_query]


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


def _dedupe(sources: list[Source]) -> list[Source]:
    seen: set[str] = set()
    out: list[Source] = []
    for s in sources:
        host = s.url.split("/")[2] if "://" in s.url else s.url
        if host in seen:
            continue
        seen.add(host)
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
