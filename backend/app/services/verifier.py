import asyncio
import hashlib

from app.core.config import settings
from app.core.prompts import VERIFY_CLAIM_HOLISTIC_SYSTEM
from app.models.schemas import Claim, Source, Verdict
from app.services import content_fetch, llm


async def verify(claim: Claim, sources: list[Source]) -> tuple[Verdict, float, list[Source]]:
    if not sources:
        return "unverifiable", 0.0, []

    if settings.mock_mode:
        return _mock_verdict(claim, sources)

    # Read the top sources by trust. One grounded LLM call per claim (cheaper
    # on quota than the old per-snippet voting, and far more accurate because
    # it reasons over real page bodies instead of 1-2 sentence snippets).
    top = sorted(sources, key=lambda s: s.trust, reverse=True)[: settings.max_sources_to_verify]

    if settings.enable_content_fetch:
        bodies = await asyncio.gather(
            *[content_fetch.fetch_text(s.url, settings.max_evidence_chars) for s in top]
        )
    else:
        bodies = ["" for _ in top]

    blocks: list[str] = []
    for i, (s, body) in enumerate(zip(top, bodies), 1):
        text = (body or s.snippet or "").strip()[: settings.max_evidence_chars]
        if not text:
            text = "(본문을 가져오지 못함)"
        blocks.append(f"[{i}] 제목: {s.title}\nURL: {s.url}\n내용: {text}")

    user = (
        f"검증할 주장:\n{claim.text}\n\n"
        f"수집된 근거 ({len(blocks)}건):\n" + "\n\n".join(blocks)
    )

    try:
        data = await llm.call_json(
            model=settings.verifier_model,
            system=VERIFY_CLAIM_HOLISTIC_SYSTEM,
            user=user,
            max_tokens=1024,
        )
    except Exception as e:
        print(
            f"[VERIFY] ERROR(unverifiable) | claim='{claim.text[:40]}' | "
            f"{type(e).__name__}: {str(e)[:120]}",
            flush=True,
        )
        return "unverifiable", 0.0, top[:3]

    verdict = data.get("verdict")
    if verdict not in ("supported", "refuted", "unverifiable"):
        verdict = "unverifiable"

    try:
        confidence = max(0.0, min(1.0, float(data.get("confidence", 0.0))))
    except (TypeError, ValueError):
        confidence = 0.0

    cited = data.get("cited_sources") or []
    used: list[Source] = []
    for idx in cited:
        if isinstance(idx, int) and 1 <= idx <= len(top):
            used.append(top[idx - 1])
    if not used:
        # No explicit citation — keep the strongest sources so the UI still
        # shows something, but this usually pairs with an "unverifiable".
        used = top[:3]

    quote = str(data.get("evidence_quote", ""))[:120]
    print(
        f"[VERIFY] {verdict:12} conf={confidence:.2f} cited={cited} | "
        f"claim='{claim.text[:40]}' | quote='{quote}'",
        flush=True,
    )
    return verdict, round(confidence, 2), used


def _mock_verdict(claim: Claim, sources: list[Source]) -> tuple[Verdict, float, list[Source]]:
    h = int(hashlib.sha256(claim.text.encode("utf-8")).hexdigest(), 16)
    bucket = h % 10
    if bucket < 6:
        return "supported", 0.9, sources
    if bucket < 8:
        return "unverifiable", 0.5, sources
    return "refuted", 0.85, sources
