"""Build KnowMe BaZi Reader V3 from governed birth input."""

from datetime import datetime
from datetime import timezone as dt_timezone

from app.services.bazi.analysis import (
    build_luck_cycles,
    compute_day_master_support,
    compute_natal_relations,
    compute_ten_god_balance,
    enrich_pillars,
    normalize_gender,
)
from app.services.bazi.calculators.lunar_engine import compute_eight_char
from app.services.bazi.constants import (
    BAZI_VERSION,
    CONTRACT_ID,
    CONTRACT_NAME,
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
from app.services.bazi.utils.datetime_parser import (
    has_known_birth_time,
    parse_birth_date,
    parse_birth_datetime_aware,
)
from app.services.bazi.utils.input_hash import compute_input_hash
from app.services.bazi.utils.solar_time import (
    apparent_solar_time,
    unknown_time_audit,
)


class BaziInvariantError(RuntimeError):
    """Raised when a governed BaZi calculation invariant is violated."""


def build_bazi(
    birth_date: str,
    birth_time: str | None,
    timezone: str,
    latitude: float | None = None,
    longitude: float | None = None,
    gender: str | None = None,
) -> dict:
    """
    Build Known- or Unknown-time Reader V3 output.

    Known time resolves the historical IANA offset and converts the supplied
    civil clock to apparent solar time. Unknown time is never imputed.
    """
    if has_known_birth_time(birth_time):
        return _build_known_time(
            birth_date=birth_date,
            birth_time=str(birth_time).strip(),
            timezone=timezone,
            latitude=latitude,
            longitude=longitude,
            gender=gender,
        )
    return _build_unknown_time(
        birth_date=birth_date,
        timezone=timezone,
        latitude=latitude,
        longitude=longitude,
        gender=gender,
    )


def _build_known_time(
    *,
    birth_date: str,
    birth_time: str,
    timezone: str,
    latitude: float | None,
    longitude: float | None,
    gender: str | None,
) -> dict:
    local_civil = parse_birth_datetime_aware(
        birth_date,
        birth_time,
        timezone,
    )
    apparent, solar_time = apparent_solar_time(
        local_civil,
        latitude=latitude,
        longitude=longitude,
    )
    lunar, eight_char = compute_eight_char(
        apparent.year,
        apparent.month,
        apparent.day,
        apparent.hour,
        apparent.minute,
        apparent.second,
    )
    pillars = enrich_pillars(
        map_pillars_from_eight_char(eight_char),
        eight_char,
    )

    return _assemble_chart(
        birth_date=birth_date,
        birth_time=birth_time,
        timezone=timezone,
        latitude=latitude,
        longitude=longitude,
        pillars=pillars,
        year_animal=map_year_animal(lunar),
        completeness="four_pillars",
        ambiguities={"year": False, "month": False, "day": False},
        suppressed_fields=[],
        gender=gender,
        eight_char=eight_char,
        solar_time=solar_time,
    )


def _build_unknown_time(
    *,
    birth_date: str,
    timezone: str,
    latitude: float | None,
    longitude: float | None,
    gender: str | None,
) -> dict:
    y, m, d = parse_birth_date(birth_date, timezone)

    start_lunar, start_eight_char = compute_eight_char(y, m, d, 0, 0, 0)
    end_lunar, end_eight_char = compute_eight_char(y, m, d, 23, 59, 59)
    start = enrich_pillars(
        map_pillars_from_eight_char(start_eight_char),
        start_eight_char,
    )
    end = enrich_pillars(
        map_pillars_from_eight_char(end_eight_char),
        end_eight_char,
    )

    if start["day"]["pillar_label"] != end["day"]["pillar_label"]:
        raise BaziInvariantError(
            "Day pillar changed inside one local civil date under sect=2"
        )

    year_ambiguous = (
        start["year"]["pillar_label"] != end["year"]["pillar_label"]
    )
    month_ambiguous = (
        start["month"]["pillar_label"] != end["month"]["pillar_label"]
    )

    pillars = {
        "year": None if year_ambiguous else start["year"],
        "month": None if month_ambiguous else start["month"],
        "day": start["day"],
        "hour": None,
    }
    suppressed_fields = ["pillars.hour", "hour_dependent_outputs"]
    if year_ambiguous:
        suppressed_fields.extend(["pillars.year", "year_animal"])
    if month_ambiguous:
        suppressed_fields.append("pillars.month")

    return _assemble_chart(
        birth_date=birth_date,
        birth_time=None,
        timezone=timezone,
        latitude=latitude,
        longitude=longitude,
        pillars=pillars,
        year_animal=(
            None
            if year_ambiguous
            else _invariant_year_animal(start_lunar, end_lunar)
        ),
        completeness=(
            "three_pillars"
            if not year_ambiguous and not month_ambiguous
            else "partial_pillars"
        ),
        ambiguities={
            "year": year_ambiguous,
            "month": month_ambiguous,
            "day": False,
        },
        suppressed_fields=suppressed_fields,
        gender=gender,
        eight_char=None,
        solar_time=unknown_time_audit(timezone),
    )


def _invariant_year_animal(start_lunar, end_lunar) -> dict:
    start = map_year_animal(start_lunar)
    end = map_year_animal(end_lunar)
    if start != end:
        raise BaziInvariantError(
            "Year animal changed while the Year pillar remained invariant"
        )
    return start


def _assemble_chart(
    *,
    birth_date: str,
    birth_time: str | None,
    timezone: str,
    latitude: float | None,
    longitude: float | None,
    pillars: dict,
    year_animal: dict | None,
    completeness: str,
    ambiguities: dict,
    suppressed_fields: list[str],
    gender: str | None,
    eight_char,
    solar_time: dict,
) -> dict:
    day_pillar = pillars.get("day")
    if not isinstance(day_pillar, dict):
        raise BaziInvariantError("Reader V3 requires an invariant Day pillar")

    day_master = summarize_day_master(day_pillar["stem"])
    day_master["pillar_label"] = day_pillar["pillar_label"]

    element_balance = compute_element_balance(pillars)
    dominant_element = compute_dominant_element(element_balance)
    normalized_gender = normalize_gender(gender)
    ten_god_balance = compute_ten_god_balance(pillars)
    day_master_support = compute_day_master_support(
        pillars,
        day_master["element"],
    )
    natal_relations = compute_natal_relations(pillars)
    luck = (
        build_luck_cycles(eight_char, normalized_gender, pillars)
        if eight_char is not None
        else None
    )
    generated_at = datetime.now(dt_timezone.utc).isoformat()

    return {
        "version": BAZI_VERSION,
        "contract_id": CONTRACT_ID,
        "contract_name": CONTRACT_NAME,
        "engine_version": ENGINE_VERSION,
        "generated_at": generated_at,
        "input_hash": compute_input_hash(
            birth_date,
            birth_time,
            timezone,
            normalized_gender,
            latitude if birth_time is not None else None,
            longitude if birth_time is not None else None,
        ),
        "completeness": completeness,
        "time_known": birth_time is not None,
        "engine_policy": dict(ENGINE_POLICY),
        "input": {
            "birth_date": str(birth_date).strip(),
            "birth_time": birth_time,
            "timezone": str(timezone).strip(),
            "latitude": latitude,
            "longitude": longitude,
            "gender": normalized_gender,
            "coordinates_used_in_calculation": birth_time is not None,
        },
        "solar_time": solar_time,
        "pillars": pillars,
        "day_master": day_master,
        "year_animal": year_animal,
        "element_balance": element_balance,
        "dominant_element": dominant_element,
        "ten_god_balance": ten_god_balance,
        "day_master_support": day_master_support,
        "natal_relations": natal_relations,
        "luck": luck,
        "ambiguities": ambiguities,
        "suppressed_fields": suppressed_fields,
    }


def build_results_snapshot(chart: dict) -> dict:
    """Project the same governed facts to the mirror storage path."""
    return {
        "version": chart["version"],
        "contract_id": chart["contract_id"],
        "contract_name": chart["contract_name"],
        "engine_version": chart["engine_version"],
        "generated_at": chart["generated_at"],
        "input_hash": chart["input_hash"],
        "completeness": chart["completeness"],
        "time_known": chart["time_known"],
        "engine_policy": chart["engine_policy"],
        "input": chart["input"],
        "solar_time": chart["solar_time"],
        "day_master": chart["day_master"],
        "year_animal": chart["year_animal"],
        "dominant_element": chart["dominant_element"],
        "element_balance": chart["element_balance"],
        "ten_god_balance": chart["ten_god_balance"],
        "day_master_support": chart["day_master_support"],
        "natal_relations": chart["natal_relations"],
        "luck": chart["luck"],
        "pillars": chart["pillars"],
        "ambiguities": chart["ambiguities"],
        "suppressed_fields": chart["suppressed_fields"],
        "mirrored_from": "astrology/chinese_bazi",
    }
