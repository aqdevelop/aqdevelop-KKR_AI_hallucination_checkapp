from __future__ import annotations

from app.core.config import settings
from app.core.prompts import SEARCH_QUERIES_SYSTEM
from app.services import llm


async def generate(claim_text: str) -> list[str]:
    if settings.mock_mode:
        return [claim_text]
    try:
        data = await llm.call_json(
            model=settings.extractor_model,
            system=SEARCH_QUERIES_SYSTEM,
            user=claim_text,
            max_tokens=256,
        )
        raw = data.get("queries", [])
        queries = [q.strip() for q in raw if isinstance(q, str) and q.strip()]
        return queries[:3] or [claim_text]
    except Exception:
        return [claim_text]
