"""Public calculation-only API for the isolated PR 149 preview.

This module deliberately imports only the BaZi and Western calculators. It has
no Firebase initialization, authentication, saved-chart route, or database client.
"""

import os

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict

from app.services.astrology.builders.chart_builder import build_chart
from app.services.overall_summary_service import generate_overall_summary
from app.services.bazi.builders.bazi_builder import BaziInvariantError, build_bazi
from app.services.bazi.calculators.lunar_engine import BaziComputeError
from app.services.bazi.utils.datetime_parser import InvalidBirthDatetime


class CalculateBaziRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    birth_date: str
    birth_time: str | None = None
    timezone: str = "Asia/Bangkok"
    latitude: float | None = None
    longitude: float | None = None
    gender: str | None = None


class CalculateChartRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    birth_date: str
    birth_time: str
    timezone: str = "Asia/Bangkok"
    latitude: float
    longitude: float


app = FastAPI(title="KnowMe Overall Preview Calculator", version="1.0.0")
preview_origin = os.environ.get("PREVIEW_ORIGIN", "").strip()
app.add_middleware(
    CORSMiddleware,
    allow_origins=[preview_origin] if preview_origin else [],
    allow_methods=["POST"],
    allow_headers=["content-type"],
)


@app.get("/health")
def health():
    return {"status": "ok", "service": "knowme-overall-preview"}


@app.post("/v1/calculate-bazi")
def calculate_bazi(request: CalculateBaziRequest):
    if not request.birth_date.strip():
        raise HTTPException(400, detail={"code": "MISSING_BIRTH_DATE"})
    try:
        chart = build_bazi(
            birth_date=request.birth_date,
            birth_time=request.birth_time,
            timezone=request.timezone,
            latitude=request.latitude,
            longitude=request.longitude,
            gender=request.gender,
        )
    except InvalidBirthDatetime as exc:
        raise HTTPException(400, detail={"code": "INVALID_DATETIME", "message": str(exc)}) from exc
    except (BaziComputeError, BaziInvariantError) as exc:
        raise HTTPException(500, detail={"code": "BAZI_COMPUTE_FAILED", "message": str(exc)}) from exc
    return {"success": True, "version": chart["version"], "chart": chart}


@app.post("/v1/calculate-chart")
def calculate_chart(request: CalculateChartRequest):
    if not request.birth_date.strip() or not request.birth_time.strip():
        raise HTTPException(400, detail={"code": "MISSING_BIRTH_DATETIME"})
    try:
        chart = build_chart(
            request.birth_date,
            request.birth_time,
            request.latitude,
            request.longitude,
            request.timezone,
        )
    except (InvalidBirthDatetime, ValueError) as exc:
        raise HTTPException(400, detail={"code": "INVALID_BIRTH_INPUT", "message": str(exc)}) from exc
    summary = generate_overall_summary(chart)
    overview = (chart.get("reader") or {}).get("overview")
    chart["overall_summary"] = overview if isinstance(overview, dict) else summary
    return {"success": True, "version": chart["version"], "chart": chart}
