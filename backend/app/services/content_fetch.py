"""Best-effort extraction of readable body text from a URL.

The verifier needs real page content, not 1-2 sentence search snippets,
to make a grounded judgement. This module fetches a page and pulls out
its paragraph text. Wikipedia is special-cased to use its clean plain-text
extract API. Everything is best-effort: any failure returns "" and the
caller falls back to the search snippet.
"""

from __future__ import annotations

import re
from urllib.parse import urlparse, unquote

import httpx

_UA = "Mozilla/5.0 (compatible; FactLensBot/1.0; +https://factlens.app)"

_SCRIPT_STYLE = re.compile(
    r"<(script|style|noscript|template|svg|nav|footer|header|aside)\b[^>]*>.*?</\1>",
    re.IGNORECASE | re.DOTALL,
)
_P_TAG = re.compile(r"<p\b[^>]*>(.*?)</p>", re.IGNORECASE | re.DOTALL)
_TAG = re.compile(r"<[^>]+>")
_WS = re.compile(r"[ \t\f\v\r\n]+")

_ENTITIES = {
    "&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": '"',
    "&#39;": "'", "&apos;": "'", "&nbsp;": " ", "&middot;": "·",
    "&hellip;": "…", "&mdash;": "—", "&ndash;": "–",
}


def _unescape(s: str) -> str:
    for k, v in _ENTITIES.items():
        s = s.replace(k, v)
    s = re.sub(r"&#(\d+);", lambda m: _safe_chr(m.group(1)), s)
    s = re.sub(r"&#x([0-9a-fA-F]+);", lambda m: _safe_chr_hex(m.group(1)), s)
    return s


def _safe_chr(num: str) -> str:
    try:
        return chr(int(num))
    except (ValueError, OverflowError):
        return ""


def _safe_chr_hex(num: str) -> str:
    try:
        return chr(int(num, 16))
    except (ValueError, OverflowError):
        return ""


def _extract_body(html: str) -> str:
    """Prefer <p> paragraph text (the real article); fall back to a full strip."""
    cleaned = _SCRIPT_STYLE.sub(" ", html)
    paragraphs = _P_TAG.findall(cleaned)
    if paragraphs:
        parts = []
        for p in paragraphs:
            t = _WS.sub(" ", _unescape(_TAG.sub(" ", p))).strip()
            if len(t) >= 20:  # skip button/label noise
                parts.append(t)
        if parts:
            return "\n".join(parts).strip()
    return _WS.sub(" ", _unescape(_TAG.sub(" ", cleaned))).strip()


async def _wikipedia_extract(url: str, client: httpx.AsyncClient) -> str:
    parsed = urlparse(url)
    host = parsed.hostname or ""
    title = unquote(parsed.path.split("/wiki/")[-1])
    if not title:
        return ""
    api = f"https://{host}/w/api.php"
    r = await client.get(api, params={
        "action": "query",
        "prop": "extracts",
        "explaintext": 1,
        "redirects": 1,
        "titles": title,
        "format": "json",
    })
    r.raise_for_status()
    pages = r.json().get("query", {}).get("pages", {})
    for _, page in pages.items():
        extract = page.get("extract", "")
        if extract:
            return extract
    return ""


async def fetch_text(url: str, max_chars: int = 1800, timeout: float = 6.0) -> str:
    if not url:
        return ""
    try:
        async with httpx.AsyncClient(
            timeout=timeout,
            follow_redirects=True,
            headers={"User-Agent": _UA},
        ) as client:
            if "wikipedia.org/wiki/" in url:
                try:
                    extract = await _wikipedia_extract(url, client)
                    if extract:
                        return extract[:max_chars]
                except Exception:
                    pass  # fall through to generic fetch
            r = await client.get(url)
            ctype = r.headers.get("content-type", "").lower()
            if not any(t in ctype for t in ("html", "text", "xml")):
                return ""
            return _extract_body(r.text)[:max_chars]
    except Exception:
        return ""
