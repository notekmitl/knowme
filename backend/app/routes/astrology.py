from fastapi import APIRouter

from app.services.astrology.builders.chart_builder import build_chart
from app.services.astrology.save_chart_service import save_chart

router = APIRouter()


@router.post("/generate-chart")
def generate_chart(
    uid: str,
    birth_date: str,
    birth_time: str,
    latitude: float,
    longitude: float
):

    chart = build_chart(
        birth_date,
        birth_time,
        latitude,
        longitude
    )

    save_chart(
        uid,
        chart
    )

    return {
        "success": True,
        "chart": chart
    }