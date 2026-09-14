"""Deterministic input hash for BaZi idempotency."""

import hashlib
import json

from app.services.bazi.constants import CONTRACT_ID


def compute_input_hash(
    birth_date: str,
    birth_time: str | None,
    timezone: str,
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
        "version": CONTRACT_ID,
    }
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()
