from app.core.config import settings
from app.core.prompts import EXTRACT_CLAIMS_SYSTEM
from app.models.schemas import Claim, Span
from app.services import llm


def _find_span(text: str, claim_text: str, used: list[tuple[int, int]]) -> Span:
    start = 0
    while True:
        idx = text.find(claim_text, start)
        if idx < 0:
            break
        end = idx + len(claim_text)
        if not any(s <= idx < e or s < end <= e for s, e in used):
            used.append((idx, end))
            return Span(start=idx, end=end)
        start = idx + 1
    return Span(start=0, end=min(len(claim_text), len(text)))


async def extract(text: str) -> list[Claim]:
    if settings.mock_mode:
        return _mock_claims(text)

    data = await llm.call_json(
        model=settings.extractor_model,
        system=EXTRACT_CLAIMS_SYSTEM,
        user=text,
        max_tokens=8192,
    )
    used: list[tuple[int, int]] = []
    claims: list[Claim] = []
    for i, raw in enumerate(data.get("claims", [])):
        ct = raw.get("text", "").strip()
        if not ct:
            continue
        span_raw = raw.get("span") or {}
        if isinstance(span_raw.get("start"), int) and isinstance(span_raw.get("end"), int):
            span = Span(start=span_raw["start"], end=span_raw["end"])
        else:
            span = _find_span(text, ct, used)
        claims.append(Claim(
            id=raw.get("id") or f"c{i+1}",
            text=ct,
            span=span,
            verdict="unverifiable",
            confidence=0.0,
        ))
    return claims


def _mock_claims(text: str) -> list[Claim]:
    sentences = [s.strip() for s in text.replace("\n", " ").split(".") if len(s.strip()) > 5]
    claims: list[Claim] = []
    cursor = 0
    for i, s in enumerate(sentences[:6]):
        idx = text.find(s, cursor)
        if idx < 0:
            idx = cursor
        claims.append(Claim(
            id=f"c{i+1}",
            text=s,
            span=Span(start=idx, end=idx + len(s)),
            verdict="unverifiable",
            confidence=0.0,
        ))
        cursor = idx + len(s)
    return claims
