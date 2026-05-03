# Backend — AI Hallucination Detector

FastAPI service that extracts atomic claims from AI-generated text, searches the
web for evidence, decides supported / refuted / unverifiable, and proposes
corrections for refuted claims.

## Quick start (mock mode, no API keys)

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env       # MOCK_MODE=true by default
uvicorn app.main:app --reload --port 8080
```

Try it:

```bash
curl -s http://localhost:8080/healthz
curl -s -X POST http://localhost:8080/v1/factcheck \
  -H 'Content-Type: application/json' \
  -d '{"text":"세종대왕은 1418년에 즉위했다. 그는 한글을 창제했다.","language":"ko"}' | jq
```

## Real mode

Set in `.env`:
```
MOCK_MODE=false
ANTHROPIC_API_KEY=sk-ant-...
BRAVE_SEARCH_API_KEY=...
```

Optional fallback:
```
GOOGLE_CSE_API_KEY=...
GOOGLE_CSE_ID=...
```

## Layout

```
app/
├── main.py                 # FastAPI entry
├── api/factcheck.py        # POST /v1/factcheck
├── core/config.py          # Settings (env)
├── core/prompts.py         # Extract / verify / correct prompts
├── models/schemas.py       # Pydantic models (Claim, Verdict, Source ...)
└── services/
    ├── pipeline.py         # Orchestrator
    ├── extractor.py        # LLM #1 (Haiku) — atomic claim extraction
    ├── search.py           # Brave (+ Google fallback)
    ├── verifier.py         # LLM #2 (Sonnet) — entail/contradict/neutral
    ├── corrector.py        # LLM #3 (Sonnet) — replacement sentences
    ├── trust.py            # Domain trust scoring
    ├── cache.py            # In-memory cache (Firestore later)
    └── llm.py              # Anthropic client + JSON extraction
```

## Deploy (Cloud Run)

```bash
gcloud run deploy factcheck-api --source backend --region asia-northeast3 \
  --allow-unauthenticated --set-env-vars MOCK_MODE=false,...
```
