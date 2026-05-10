import json
import re
from typing import Any

from app.core.config import settings


_anthropic: Any = None
_gemini: Any = None


def _get_anthropic() -> Any:
    global _anthropic
    if _anthropic is None:
        if not settings.anthropic_api_key:
            raise RuntimeError(
                "ANTHROPIC_API_KEY is empty but a claude-* model was requested"
            )
        from anthropic import AsyncAnthropic
        _anthropic = AsyncAnthropic(api_key=settings.anthropic_api_key)
    return _anthropic


def _get_gemini() -> Any:
    global _gemini
    if _gemini is None:
        if not settings.gemini_api_key:
            raise RuntimeError(
                "GEMINI_API_KEY is empty but a gemini-* model was requested"
            )
        from google import genai
        _gemini = genai.Client(api_key=settings.gemini_api_key)
    return _gemini


def _extract_json(text: str) -> dict[str, Any]:
    match = re.search(r"\{.*\}", text, re.DOTALL)
    if not match:
        raise ValueError(f"No JSON object found in model output: {text[:200]}")
    return json.loads(match.group(0))


async def _call_anthropic(model: str, system: str, user: str, max_tokens: int) -> str:
    client = _get_anthropic()
    resp = await client.messages.create(
        model=model,
        max_tokens=max_tokens,
        system=system,
        messages=[{"role": "user", "content": user}],
    )
    return "".join(b.text for b in resp.content if b.type == "text")


async def _call_gemini(model: str, system: str, user: str, max_tokens: int) -> str:
    client = _get_gemini()  # raises early if key missing, before importing SDK types
    from google.genai import types as genai_types
    resp = await client.aio.models.generate_content(
        model=model,
        contents=user,
        config=genai_types.GenerateContentConfig(
            system_instruction=system,
            response_mime_type="application/json",
            max_output_tokens=max_tokens,
        ),
    )
    return resp.text or ""


async def call_json(model: str, system: str, user: str, max_tokens: int = 1024) -> dict[str, Any]:
    """Call the LLM matching the model name prefix and parse JSON.

    claude-*  → Anthropic
    gemini-*  → Google Gemini
    """
    if model.startswith("claude-"):
        call = _call_anthropic
    elif model.startswith("gemini-"):
        call = _call_gemini
    else:
        raise ValueError(f"Unknown model provider for: {model!r}")

    text = await call(model, system, user, max_tokens)
    try:
        return _extract_json(text)
    except (ValueError, json.JSONDecodeError):
        retry_text = await call(
            model,
            system + "\n\nReturn STRICT valid JSON only. No prose, no markdown.",
            user,
            max_tokens,
        )
        return _extract_json(retry_text)
