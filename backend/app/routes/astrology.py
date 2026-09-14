from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.security.firebase_auth import current_firebase_uid

from app.services.overall_summary_service import (
    generate_overall_summary,
)

from app.services.astrology.builders.chart_builder import (
    build_chart,
)

from app.services.astrology.save_chart_service import (
    save_chart,
)

router = APIRouter()


class GenerateChartRequest(BaseModel):
    uid: str
    birth_date: str
    birth_time: str
    latitude: float
    longitude: float


@router.post("/generate-chart", deprecated=True)
def generate_chart_legacy(request: GenerateChartRequest):
    """Compatibility endpoint for clients released before bearer auth."""
    return _generate_chart(request, write_uid=request.uid.strip())


@router.post("/v1/generate-chart")
def generate_chart_v1(
    request: GenerateChartRequest,
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
    return _generate_chart(request, write_uid=authenticated_uid)


def _generate_chart(request: GenerateChartRequest, *, write_uid: str):
    if not write_uid:
        raise HTTPException(
            status_code=400,
            detail={"code": "MISSING_UID", "message": "uid is required"},
        )

    chart = build_chart(
        request.birth_date,
        request.birth_time,
        request.latitude,
        request.longitude,
    )

    overall_summary = generate_overall_summary(
        chart,
    )

    chart["overall_summary"] = overall_summary

    save_chart(
        write_uid,
        chart,
    )

    return {
        "success": True,
        "chart": chart,
    }
