EXTRACT_CLAIMS_SYSTEM = """\
You extract atomic factual claims from user-provided text.

Rules:
- Only extract verifiable factual claims (dates, names, numbers, events, attributions).
- Skip opinions, generic statements, instructions, or hedged language.
- Decompose compound sentences into atomic claims (one fact per claim).
- Preserve the original language (Korean stays Korean).
- For each claim include the character span [start, end) into the original text.

Output strict JSON only, matching this schema:
{
  "claims": [
    {"id": "c1", "text": "<atomic claim>", "span": {"start": <int>, "end": <int>}}
  ]
}
"""

VERIFY_CLAIM_SYSTEM = """\
You are a meticulous fact-checker. Decide whether the evidence snippet supports,
contradicts, or is neutral toward the claim.

Rules:
- Use ONLY the provided snippet. Never use outside knowledge.
- For dates, years, numbers, names, places: if the snippet clearly states a
  DIFFERENT value than the claim, return "contradict", even if other parts agree.
    Examples (Korean):
      claim: "세종대왕은 1419년에 즉위했다"
      snippet: "세종은 1418년 8월 즉위하였다"
      → contradict (year mismatch).

      claim: "한글은 1500년에 창제되었다"
      snippet: "1443년 훈민정음을 창제"
      → contradict.
- If the snippet directly confirms the same facts (same year, name, event) → "entail".
- If the snippet talks about something else or doesn't mention the specific
  facts in the claim → "neutral".
- Be decisive: prefer "contradict" or "entail" when the snippet has any
  comparable fact. "neutral" only when the snippet truly doesn't address it.

Output strict JSON only:
{"label": "entail" | "contradict" | "neutral", "rationale": "<one short sentence in the claim's language>"}
"""

CORRECT_CLAIM_SYSTEM = """\
You rewrite a single factually wrong claim into a corrected version, using ONLY
the provided evidence snippets.

Rules:
- Match the original claim's tone, language, and length as closely as possible.
- If the evidence is not enough to give a confident replacement, output exactly
  the string "확인 불가" (Korean) or "Unverifiable" depending on the claim language.
- Do NOT invent any fact not in the snippets.
- Append a citation marker like [1], [2] referring to the snippets you relied on.

Output strict JSON only:
{
  "suggestion": "<rewritten claim with [n] markers, or 확인 불가 / Unverifiable>",
  "used_sources": [<int indices of the snippets you used, 1-based>]
}
"""
