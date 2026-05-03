from typing import Literal, Optional
from pydantic import BaseModel, Field


Verdict = Literal["supported", "refuted", "unverifiable"]


class Span(BaseModel):
    start: int
    end: int


class Source(BaseModel):
    url: str
    title: str
    snippet: str
    trust: float = Field(ge=0.0, le=1.0)


class Claim(BaseModel):
    id: str
    text: str
    span: Span
    verdict: Verdict
    confidence: float = Field(ge=0.0, le=1.0)
    sources: list[Source] = []
    suggestion: Optional[str] = None


class Summary(BaseModel):
    total: int
    supported: int
    refuted: int
    unverifiable: int
    trust_score: float = Field(ge=0.0, le=100.0)


class FactCheckRequest(BaseModel):
    text: str = Field(min_length=1)
    language: str = "ko"


class FactCheckResponse(BaseModel):
    claims: list[Claim]
    summary: Summary
    cached: bool = False
