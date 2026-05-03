from fastapi import APIRouter, HTTPException

from app.core.config import settings
from app.models.schemas import FactCheckRequest, FactCheckResponse
from app.services import pipeline


router = APIRouter()


@router.post("/factcheck", response_model=FactCheckResponse)
async def factcheck(req: FactCheckRequest) -> FactCheckResponse:
    if len(req.text) > settings.max_text_length:
        raise HTTPException(
            status_code=413,
            detail=f"text exceeds max length of {settings.max_text_length}",
        )
    return await pipeline.run(req)
