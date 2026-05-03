from app.core.config import settings
from app.core.prompts import CORRECT_CLAIM_SYSTEM
from app.models.schemas import Claim, Source
from app.services import llm


async def correct(claim: Claim, sources: list[Source]) -> str | None:
    if not sources:
        return None

    if settings.mock_mode:
        cite = "[1]" if sources else ""
        return f"(교정 예시) '{claim.text}' 의 정정된 버전 {cite}"

    snippets = "\n".join(
        f"[{i+1}] {s.snippet} ({s.url})" for i, s in enumerate(sources)
    )
    user = f"Claim: {claim.text}\n\nEvidence snippets:\n{snippets}"
    try:
        data = await llm.call_json(
            model=settings.corrector_model,
            system=CORRECT_CLAIM_SYSTEM,
            user=user,
            max_tokens=512,
        )
        return data.get("suggestion")
    except Exception:
        return None
