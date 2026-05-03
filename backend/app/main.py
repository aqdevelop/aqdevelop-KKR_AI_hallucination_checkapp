from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.factcheck import router as factcheck_router
from app.core.config import settings


app = FastAPI(title="AI Hallucination Detector API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[o.strip() for o in settings.cors_origins.split(",")] if settings.cors_origins else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(factcheck_router, prefix="/v1")


@app.get("/healthz")
async def healthz() -> dict[str, str]:
    return {"status": "ok", "mock_mode": str(settings.mock_mode)}
