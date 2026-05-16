import asyncio

from app.core.config import settings
from app.models.schemas import (
    Claim, FactCheckRequest, FactCheckResponse, Summary,
)
from app.services import extractor, search, verifier, corrector, query_gen
from app.services.cache import MemoryCache


_cache = MemoryCache(ttl_seconds=settings.cache_ttl_days * 24 * 3600)


async def run(req: FactCheckRequest) -> FactCheckResponse:
    cache_key = MemoryCache.key("factcheck", req.language, req.text)
    if (cached := _cache.get(cache_key)) is not None:
        return FactCheckResponse(**cached, cached=True)

    text = req.text[: settings.max_text_length]
    claims = await extractor.extract(text)
    if not claims:
        return _empty_response()

    await asyncio.gather(*[_verify_one(c, req.language) for c in claims])

    refuted = [c for c in claims if c.verdict == "refuted"]
    suggestions = await asyncio.gather(*[corrector.correct(c, c.sources) for c in refuted])
    for c, s in zip(refuted, suggestions):
        c.suggestion = s

    response = FactCheckResponse(
        claims=claims,
        summary=_summarize(claims),
    )
    _cache.set(cache_key, response.model_dump(exclude={"cached"}))
    return response


async def _verify_one(claim: Claim, language: str) -> None:
    queries = await query_gen.generate(claim.text)
    results = await asyncio.gather(*[search.search(q, language=language) for q in queries])
    sources = []
    seen: set[str] = set()
    for batch in results:
        for s in batch:
            host = s.url.split("/")[2] if "://" in s.url else s.url
            if host in seen:
                continue
            seen.add(host)
            sources.append(s)
    sources = sources[: settings.search_results_per_query * 2]
    verdict, confidence, used = await verifier.verify(claim, sources)
    claim.verdict = verdict
    claim.confidence = confidence
    claim.sources = used


def _summarize(claims: list[Claim]) -> Summary:
    total = len(claims)
    s = sum(1 for c in claims if c.verdict == "supported")
    r = sum(1 for c in claims if c.verdict == "refuted")
    u = sum(1 for c in claims if c.verdict == "unverifiable")
    if total == 0:
        score = 0.0
    else:
        score = (s * 1.0 + u * 0.5) / total * 100.0
    return Summary(
        total=total, supported=s, refuted=r, unverifiable=u,
        trust_score=round(score, 1),
    )


def _empty_response() -> FactCheckResponse:
    return FactCheckResponse(
        claims=[],
        summary=Summary(total=0, supported=0, refuted=0, unverifiable=0, trust_score=0.0),
    )
