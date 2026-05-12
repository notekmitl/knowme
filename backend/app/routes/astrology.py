from fastapi import APIRouter
from pydantic import BaseModel

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


@router.post("/generate-chart")
def generate_chart(
    request: GenerateChartRequest
):

    chart = build_chart(
        request.birth_date,
        request.birth_time,
        request.latitude,
        request.longitude
    )

    overall_summary = generate_overall_summary(
        chart
    )

    chart["overall_summary"] = overall_summary

    save_chart(
        request.uid,
        chart
    )

    return {
        "success": True,
        "chart": chart
    }