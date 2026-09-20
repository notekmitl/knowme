import hashlib
import json
from datetime import timezone as dt_timezone
import swisseph as swe

from app.services.astrology.calculators.planet_calculator import calculate_planets

from app.services.astrology.calculators.house_calculator import (
    calculate_houses,
    get_house,
)

from app.services.astrology.calculators.aspect_calculator import (
    calculate_aspects
)

from app.services.astrology.utils.astrology_utils import (
    get_sign
)

from app.services.astrology.interpretations.interpretation_engine import (
    generate_interpretations
)

from app.services.astrology.insight.insight_engine import (
    generate_personality_summary
)
from app.services.astrology.analysis import analyze_chart
from app.services.astrology.reader import build_reader
from app.services.bazi.utils.datetime_parser import parse_birth_datetime_aware


WESTERN_CHART_VERSION = "western_natal_v2"
WESTERN_CONTRACT_ID = "knowme_western_reader_v2"
WESTERN_ENGINE_VERSION = "swiss_ephemeris_tropical_placidus_v2"


def build_chart(
    birth_date,
    birth_time,
    latitude,
    longitude,
    timezone="Asia/Bangkok",
):
    _validate_coordinates(latitude, longitude)
    local_civil = parse_birth_datetime_aware(
        birth_date,
        birth_time,
        timezone,
    )
    utc_instant = local_civil.astimezone(dt_timezone.utc)

    decimal_hour = (
        utc_instant.hour +
        utc_instant.minute / 60 +
        utc_instant.second / 3600
    )

    julian_day = swe.julday(
        utc_instant.year,
        utc_instant.month,
        utc_instant.day,
        decimal_hour
    )

    planets = calculate_planets(
        julian_day
    )

    houses = calculate_houses(
        julian_day,
        latitude,
        longitude
    )

    for _, planet_data in planets.items():

        planet_data["house"] = get_house(
            planet_data["longitude"],
            houses["cusps"]
        )

    aspects = calculate_aspects(
        planets
    )

    interpretations = generate_interpretations(
        planets
    )

    insight = generate_personality_summary(
        {
            "big3": {
                "sun": planets["sun"]["sign"],
                "moon": planets["moon"]["sign"],
                "rising": get_sign(
                    houses["ascendant"]
                )
            },

            "interpretations": interpretations
        }
    )

    big3 = {
        "sun": planets["sun"]["sign"],
        "moon": planets["moon"]["sign"],
        "rising": get_sign(houses["ascendant"]),
    }
    analysis = analyze_chart(planets, houses, aspects)
    reader = build_reader(big3, planets, analysis)
    normalized_input = {
        "birth_date": birth_date.strip(),
        "birth_time": birth_time.strip(),
        "timezone": timezone.strip(),
        "latitude": round(float(latitude), 6),
        "longitude": round(float(longitude), 6),
    }

    return {

        "version": WESTERN_CHART_VERSION,
        "contract_id": WESTERN_CONTRACT_ID,
        "engine_version": WESTERN_ENGINE_VERSION,
        "input_hash": _input_hash(normalized_input),
        "input": {
            **normalized_input,
            "local_civil": local_civil.isoformat(),
            "utc_instant": utc_instant.isoformat().replace("+00:00", "Z"),
            "zodiac": "tropical",
            "house_system": "Placidus",
        },

        "big3": big3,

        "planets": planets,

        "houses": {
            "ascendant": round(houses["ascendant"], 6),
            "midheaven": round(houses["midheaven"], 6),
            "cusps": [round(value, 6) for value in houses["cusps"]],
            "system": houses["system"],
        },

        "aspects": aspects,

        "interpretations": interpretations,

        "insight": insight,

        "analysis": analysis,

        "reader": reader,
    }


def _validate_coordinates(latitude, longitude):
    lat = float(latitude)
    lon = float(longitude)
    if not -90 <= lat <= 90:
        raise ValueError("latitude must be between -90 and 90")
    if not -180 <= lon <= 180:
        raise ValueError("longitude must be between -180 and 180")


def _input_hash(normalized_input):
    payload = json.dumps(
        normalized_input,
        ensure_ascii=True,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()
