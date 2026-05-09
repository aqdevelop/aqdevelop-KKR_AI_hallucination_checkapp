from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.factcheck import router as factcheck_router
from app.core.config import settings


app = FastAPI(title="AI Hallucination Detector API", version="0.1.0")

_origins = (
    [o.strip() for o in settings.cors_origins.split(",") if o.strip()]
    if settings.cors_origins
    else ["*"]
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins,
    allow_credentials="*" not in _origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(factcheck_router, prefix="/v1")


@app.get("/healthz")
async def healthz() -> dict[str, str]:
    return {"status": "ok", "mock_mode": str(settings.mock_mode)}
