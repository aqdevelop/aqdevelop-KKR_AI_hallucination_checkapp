import asyncio
import hashlib

from app.core.config import settings
from app.core.prompts import VERIFY_CLAIM_SYSTEM
from app.models.schemas import Claim, Source, Verdict
from app.services import llm


async def verify(claim: Claim, sources: list[Source]) -> tuple[Verdict, float, list[Source]]:
    if not sources:
        return "unverifiable", 0.0, []

    if settings.mock_mode:
        return _mock_verdict(claim, sources)

    labels = await asyncio.gather(*[_classify(claim.text, s) for s in sources])

    entail = sum(s.trust for label, s in zip(labels, sources) if label == "entail")
    contradict = sum(s.trust for label, s in zip(labels, sources) if label == "contradict")
    distinct_entail = len({s.url for label, s in zip(labels, sources) if label == "entail"})

    verdict: Verdict
    if contradict > entail and contradict >= 0.6:
        verdict = "refuted"
    elif entail >= 1.2 and distinct_entail >= 2 and contradict < 0.3:
        verdict = "supported"
    else:
        verdict = "unverifiable"

    total = entail + contradict
    confidence = max(entail, contradict) / total if total > 0 else 0.0
    return verdict, round(confidence, 2), sources


async def _classify(claim_text: str, source: Source) -> str:
    user = (
        f"Claim: {claim_text}\n\n"
        f"Snippet (from {source.url}):\n{source.snippet}\n"
    )
    try:
        data = await llm.call_json(
            model=settings.verifier_model,
            system=VERIFY_CLAIM_SYSTEM,
            user=user,
            max_tokens=256,
        )
        label = data.get("label", "neutral")
        return label if label in ("entail", "contradict", "neutral") else "neutral"
    except Exception:
        return "neutral"


def _mock_verdict(claim: Claim, sources: list[Source]) -> tuple[Verdict, float, list[Source]]:
    h = int(hashlib.sha256(claim.text.encode("utf-8")).hexdigest(), 16)
    bucket = h % 10
    if bucket < 6:
        return "supported", 0.9, sources
    if bucket < 8:
        return "unverifiable", 0.5, sources
    return "refuted", 0.85, sources
