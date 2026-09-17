"""Apparent-solar-time conversion for the governed Reader V3 contract."""

from __future__ import annotations

import calendar
import math
from datetime import datetime, timedelta

from app.services.bazi.utils.datetime_parser import InvalidBirthDatetime


SOLAR_TIME_METHOD = "noaa_fractional_year_eot_v1"


def validate_coordinates(
    latitude: float | None,
    longitude: float | None,
) -> tuple[float, float]:
    """Return finite WGS84 coordinates or fail closed."""
    if latitude is None or longitude is None:
        raise InvalidBirthDatetime(
            "latitude and longitude are required when birth_time is known"
        )
    lat = float(latitude)
    lon = float(longitude)
    if not math.isfinite(lat) or not -90.0 <= lat <= 90.0:
        raise InvalidBirthDatetime("latitude must be between -90 and 90")
    if not math.isfinite(lon) or not -180.0 <= lon <= 180.0:
        raise InvalidBirthDatetime("longitude must be between -180 and 180")
    return lat, lon


def equation_of_time_minutes(local_civil: datetime) -> float:
    """NOAA fractional-year approximation of the Equation of Time."""
    days = 366 if calendar.isleap(local_civil.year) else 365
    decimal_hour = (
        local_civil.hour
        + local_civil.minute / 60.0
        + local_civil.second / 3600.0
    )
    gamma = (
        2.0
        * math.pi
        / days
        * (local_civil.timetuple().tm_yday - 1 + (decimal_hour - 12.0) / 24.0)
    )
    return 229.18 * (
        0.000075
        + 0.001868 * math.cos(gamma)
        - 0.032077 * math.sin(gamma)
        - 0.014615 * math.cos(2.0 * gamma)
        - 0.040849 * math.sin(2.0 * gamma)
    )


def apparent_solar_time(
    local_civil: datetime,
    *,
    latitude: float | None,
    longitude: float | None,
) -> tuple[datetime, dict]:
    """Convert an aware civil time to apparent solar time and audit data.

    NOAA defines the offset as ``EoT + 4*longitude - 60*timezone`` where
    longitude is east-positive and timezone is the UTC offset in hours. The
    historical offset comes from the resolved IANA-zone datetime, including
    daylight-saving rules in force at that instant.
    """
    if local_civil.tzinfo is None or local_civil.utcoffset() is None:
        raise InvalidBirthDatetime("resolved local civil time must be timezone-aware")
    lat, lon = validate_coordinates(latitude, longitude)
    offset = local_civil.utcoffset()
    if offset is None:
        raise InvalidBirthDatetime("timezone has no UTC offset at birth time")

    utc_offset_minutes = offset.total_seconds() / 60.0
    eot_minutes = equation_of_time_minutes(local_civil)
    longitude_correction_minutes = 4.0 * lon - utc_offset_minutes
    total_correction_minutes = eot_minutes + longitude_correction_minutes
    apparent = local_civil.replace(tzinfo=None) + timedelta(
        minutes=total_correction_minutes
    )
    rounded = (apparent + timedelta(microseconds=500_000)).replace(
        microsecond=0
    )

    audit = {
        "status": "computed",
        "method": SOLAR_TIME_METHOD,
        "local_civil_datetime": local_civil.isoformat(),
        "timezone": getattr(local_civil.tzinfo, "key", str(local_civil.tzinfo)),
        "historical_utc_offset_minutes": _round(utc_offset_minutes),
        "standard_meridian_degrees": _round(utc_offset_minutes / 4.0),
        "latitude_degrees": _round(lat),
        "longitude_degrees": _round(lon),
        "longitude_correction_minutes": _round(
            longitude_correction_minutes
        ),
        "equation_of_time_minutes": _round(eot_minutes),
        "total_correction_minutes": _round(total_correction_minutes),
        "apparent_solar_datetime": rounded.isoformat(),
        "rounding": "nearest_second_half_up",
    }
    return rounded, audit


def unknown_time_audit(timezone: str) -> dict:
    """Explicitly record that Reader V3 did not manufacture a birth time."""
    return {
        "status": "not_computed_unknown_birth_time",
        "method": SOLAR_TIME_METHOD,
        "timezone": str(timezone).strip(),
        "apparent_solar_datetime": None,
    }


def _round(value: float) -> float:
    return round(value, 6)
