from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from app.services.bazi.builders.bazi_builder import (
    build_bazi,
    build_results_snapshot,
)
from app.services.bazi.calculators.lunar_engine import BaziComputeError
from app.services.bazi.save_bazi_service import save_bazi
from app.services.bazi.utils.datetime_parser import (
    InvalidBirthDatetime,
    MissingBirthTime,
)

router = APIRouter()


class GenerateBaziRequest(BaseModel):
    uid: str
    birth_date: str
    birth_time: str = Field(min_length=1)
    timezone: str = "Asia/Bangkok"
    latitude: float | None = None
    longitude: float | None = None


@router.post("/generate-bazi")
def generate_bazi(request: GenerateBaziRequest):
    if not request.uid.strip():
        raise HTTPException(
            status_code=400,
            detail={"code": "MISSING_UID", "message": "uid is required"},
        )

    if not request.birth_date.strip():
        raise HTTPException(
            status_code=400,
            detail={
                "code": "MISSING_BIRTH_DATE",
                "message": "birth_date is required",
            },
        )

    try:
        chart = build_bazi(
            birth_date=request.birth_date,
            birth_time=request.birth_time,
            timezone=request.timezone,
            latitude=request.latitude,
            longitude=request.longitude,
        )
    except MissingBirthTime as exc:
        raise HTTPException(
            status_code=400,
            detail={"code": "MISSING_BIRTH_TIME", "message": str(exc)},
        ) from exc
    except InvalidBirthDatetime as exc:
        raise HTTPException(
            status_code=400,
            detail={"code": "INVALID_DATETIME", "message": str(exc)},
        ) from exc
    except BaziComputeError as exc:
        raise HTTPException(
            status_code=500,
            detail={"code": "BAZI_COMPUTE_FAILED", "message": str(exc)},
        ) from exc

    results_snapshot = build_results_snapshot(chart)

    try:
        save_bazi(request.uid, chart, results_snapshot)
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail={"code": "FIRESTORE_SAVE_FAILED", "message": str(exc)},
        ) from exc

    return {
        "success": True,
        "version": chart["version"],
        "completeness": chart["completeness"],
        "chart": chart,
        "saved_paths": {
            "astrology": f"users/{request.uid}/astrology/chinese_bazi",
            "results": f"users/{request.uid}/results/chinese_bazi",
        },
    }
