"""Build KnowMe BaZi V1 chart payload from birth input."""

from datetime import datetime
from datetime import timezone as dt_timezone

from app.services.bazi.calculators.lunar_engine import compute_eight_char
from app.services.bazi.constants import (
    BAZI_VERSION,
    ENGINE_POLICY,
    ENGINE_VERSION,
)
from app.services.bazi.mappers.pillar_mapper import map_pillars_from_eight_char
from app.services.bazi.mappers.shengxiao_mapper import map_year_animal
from app.services.bazi.summarizers.bazi_summarizer import (
    compute_dominant_element,
    compute_element_balance,
    summarize_day_master,
)
from app.services.bazi.utils.datetime_parser import parse_birth_datetime
from app.services.bazi.utils.input_hash import compute_input_hash


def build_bazi(
    birth_date: str,
    birth_time: str,
    timezone: str,
    latitude: float | None = None,
    longitude: float | None = None,
) -> dict:
    """
    KnowMe BaZi V1 — four pillars only (birth_time required).

    Returns chart dict ready for Firestore astrology/chinese_bazi.
    """
    y, m, d, h, mi, s = parse_birth_datetime(birth_date, birth_time, timezone)
    lunar, eight_char = compute_eight_char(y, m, d, h, mi, s)

    pillars = map_pillars_from_eight_char(eight_char)
    day_master = summarize_day_master(eight_char.getDayGan())
    day_master["pillar_label"] = pillars["day"]["pillar_label"]

    element_balance = compute_element_balance(pillars)
    dominant_element = compute_dominant_element(element_balance)
    year_animal = map_year_animal(lunar)

    input_hash = compute_input_hash(birth_date, birth_time, timezone)
    generated_at = datetime.now(dt_timezone.utc).isoformat()

    return {
        "version": BAZI_VERSION,
        "engine_version": ENGINE_VERSION,
        "generated_at": generated_at,
        "input_hash": input_hash,
        "completeness": "four_pillars",
        "engine_policy": dict(ENGINE_POLICY),
        "input": {
            "birth_date": birth_date,
            "birth_time": birth_time,
            "timezone": timezone,
            "latitude": latitude,
            "longitude": longitude,
        },
        "pillars": pillars,
        "day_master": day_master,
        "year_animal": year_animal,
        "element_balance": element_balance,
        "dominant_element": dominant_element,
    }


def build_results_snapshot(chart: dict) -> dict:
    """Minimal results/chinese_bazi snapshot for future UI/Fusion prep."""
    return {
        "version": chart["version"],
        "engine_version": chart["engine_version"],
        "generated_at": chart["generated_at"],
        "input_hash": chart["input_hash"],
        "completeness": chart["completeness"],
        "day_master": chart["day_master"],
        "year_animal": chart["year_animal"],
        "dominant_element": chart["dominant_element"],
        "element_balance": chart["element_balance"],
        "pillars": chart["pillars"],
        "mirrored_from": "astrology/chinese_bazi",
    }
