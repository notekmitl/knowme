"""Deterministic input hash for BaZi idempotency."""

import hashlib
import json


def compute_input_hash(
    birth_date: str,
    birth_time: str,
    timezone: str,
) -> str:
    payload = {
        "birth_date": birth_date,
        "birth_time": birth_time,
        "timezone": timezone,
        "version": "bazi_v1",
    }
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()
