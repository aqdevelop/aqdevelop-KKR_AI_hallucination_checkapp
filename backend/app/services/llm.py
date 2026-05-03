import json
import re
from typing import Any
from anthropic import AsyncAnthropic

from app.core.config import settings


_client: AsyncAnthropic | None = None


def _get_client() -> AsyncAnthropic:
    global _client
    if _client is None:
        _client = AsyncAnthropic(api_key=settings.anthropic_api_key)
    return _client


def _extract_json(text: str) -> dict[str, Any]:
    match = re.search(r"\{.*\}", text, re.DOTALL)
    if not match:
        raise ValueError(f"No JSON object found in model output: {text[:200]}")
    return json.loads(match.group(0))


async def call_json(model: str, system: str, user: str, max_tokens: int = 1024) -> dict[str, Any]:
    client = _get_client()
    resp = await client.messages.create(
        model=model,
        max_tokens=max_tokens,
        system=system,
        messages=[{"role": "user", "content": user}],
    )
    text = "".join(block.text for block in resp.content if block.type == "text")
    try:
        return _extract_json(text)
    except (ValueError, json.JSONDecodeError):
        retry = await client.messages.create(
            model=model,
            max_tokens=max_tokens,
            system=system + "\n\nReturn STRICT valid JSON only.",
            messages=[{"role": "user", "content": user}],
        )
        retry_text = "".join(b.text for b in retry.content if b.type == "text")
        return _extract_json(retry_text)
