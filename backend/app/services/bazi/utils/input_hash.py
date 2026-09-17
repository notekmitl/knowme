"""Deterministic input hash for BaZi idempotency."""

import hashlib
import json

from app.services.bazi.constants import CONTRACT_ID


def compute_input_hash(
    birth_date: str,
    birth_time: str | None,
    timezone: str,
    gender: str | None = None,
    latitude: float | None = None,
    longitude: float | None = None,
) -> str:
    normalized_time = (
        str(birth_time).strip()
        if birth_time is not None and str(birth_time).strip()
        else None
    )
    payload = {
        "birth_date": str(birth_date).strip(),
        "birth_time": normalized_time,
        "timezone": str(timezone).strip(),
        "gender": str(gender).strip() if gender else None,
        "latitude": _coordinate(latitude),
        "longitude": _coordinate(longitude),
        "version": CONTRACT_ID,
    }
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def _coordinate(value: float | None) -> float | None:
    if value is None:
        return None
    return round(float(value), 6)
