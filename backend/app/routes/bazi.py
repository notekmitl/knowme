from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.security.firebase_auth import current_firebase_uid

from app.services.bazi.builders.bazi_builder import (
    BaziInvariantError,
    build_bazi,
    build_results_snapshot,
)
from app.services.bazi.calculators.lunar_engine import BaziComputeError
from app.services.bazi.save_bazi_service import save_bazi
from app.services.bazi.utils.datetime_parser import InvalidBirthDatetime

router = APIRouter()


class GenerateBaziRequest(BaseModel):
    uid: str
    birth_date: str
    birth_time: str | None = None
    timezone: str = "Asia/Bangkok"
    latitude: float | None = None
    longitude: float | None = None


@router.post("/generate-bazi")
def generate_bazi(
    request: GenerateBaziRequest,
    authenticated_uid: str = Depends(current_firebase_uid),
):
    if not request.uid.strip():
        raise HTTPException(
            status_code=400,
            detail={"code": "MISSING_UID", "message": "uid is required"},
        )

    if request.uid.strip() != authenticated_uid:
        raise HTTPException(
            status_code=403,
            detail={
                "code": "UID_MISMATCH",
                "message": "Authenticated user cannot write another user's chart",
            },
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
    except InvalidBirthDatetime as exc:
        raise HTTPException(
            status_code=400,
            detail={"code": "INVALID_DATETIME", "message": str(exc)},
        ) from exc
    except (BaziComputeError, BaziInvariantError) as exc:
        raise HTTPException(
            status_code=500,
            detail={"code": "BAZI_COMPUTE_FAILED", "message": str(exc)},
        ) from exc

    results_snapshot = build_results_snapshot(chart)

    try:
        save_bazi(authenticated_uid, chart, results_snapshot)
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
            "astrology": f"users/{authenticated_uid}/astrology/chinese_bazi",
            "results": f"users/{authenticated_uid}/results/chinese_bazi",
        },
    }
