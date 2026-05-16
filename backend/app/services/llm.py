from __future__ import annotations

import json
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
    stripped = text.strip()
    if stripped.startswith("```"):
        first_nl = stripped.find("\n")
        if first_nl != -1:
            stripped = stripped[first_nl + 1 :]
        if stripped.endswith("```"):
            stripped = stripped[:-3]
        stripped = stripped.strip()

    start = stripped.find("{")
    if start == -1:
        raise ValueError(f"No JSON object found in model output: {text[:200]}")

    try:
        return json.loads(stripped[start:])
    except json.JSONDecodeError:
        pass

    end = stripped.rfind("}")
    if end > start:
        try:
            return json.loads(stripped[start : end + 1])
        except json.JSONDecodeError:
            pass

    repaired = _repair_truncated_json(stripped[start:])
    if repaired is not None:
        return repaired

    raise ValueError(
        f"Could not parse JSON (possibly truncated by max_tokens). "
        f"First 200 chars: {text[:200]}"
    )


def _repair_truncated_json(s: str) -> dict[str, Any] | None:
    """Try to recover a usable JSON object from a response truncated mid-output.

    Strategy: progressively trim trailing characters and close any open
    structures ({, [, ", or an unfinished token) until json.loads succeeds.
    """
    for cutoff in range(len(s), 0, -1):
        prefix = s[:cutoff]
        in_string = False
        escape = False
        stack: list[str] = []
        for ch in prefix:
            if escape:
                escape = False
                continue
            if ch == "\\":
                escape = True
                continue
            if ch == '"':
                in_string = not in_string
                continue
            if in_string:
                continue
            if ch in "{[":
                stack.append(ch)
            elif ch in "}]":
                if stack and ((ch == "}" and stack[-1] == "{") or (ch == "]" and stack[-1] == "[")):
                    stack.pop()

        candidate = prefix
        if in_string:
            candidate += '"'
        candidate = candidate.rstrip().rstrip(",")
        for opener in reversed(stack):
            candidate += "}" if opener == "{" else "]"
        try:
            return json.loads(candidate)
        except json.JSONDecodeError:
            continue
    return None


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
