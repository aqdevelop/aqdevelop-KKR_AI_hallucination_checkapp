import httpx

from app.core.config import settings
from app.models.schemas import Source
from app.services import trust


BRAVE_URL = "https://api.search.brave.com/res/v1/web/search"
GOOGLE_URL = "https://www.googleapis.com/customsearch/v1"


async def search(query: str, language: str = "ko") -> list[Source]:
    if settings.mock_mode:
        return _mock_sources(query)

    results: list[Source] = []
    if settings.brave_search_api_key:
        results = await _brave(query, language)

    if language == "ko" and len(results) < 3 and settings.google_cse_api_key:
        results += await _google(query)

    return _dedupe(results)[: settings.search_results_per_query]


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
