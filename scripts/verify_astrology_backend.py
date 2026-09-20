#!/usr/bin/env python3
"""Read-only startup verification for health and authenticated generation routes."""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request
from typing import Any


AUTH_PROBE = {
    "uid": "knowme-api-auth-probe",
    "birth_date": "1990-05-12",
    "birth_time": "15:30",
    "timezone": "Asia/Bangkok",
    "latitude": 13.7563,
    "longitude": 100.5018,
}


def _request(
    method: str,
    url: str,
    payload: dict[str, Any] | None = None,
    timeout: int = 90,
) -> tuple[int, str]:
    data = None
    headers = {"Accept": "application/json"}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"

    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            return resp.status, body
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        return exc.code, body


def _check(name: str, ok: bool, detail: str) -> bool:
    status = "PASS" if ok else "FAIL"
    print(f"[{status}] {name}: {detail}")
    return ok


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify KnowMe astrology API")
    parser.add_argument(
        "--base-url",
        required=True,
        help="API base URL without trailing slash",
    )
    args = parser.parse_args()
    base = args.base_url.rstrip("/")

    all_ok = True

    try:
        code, body = _request("GET", f"{base}/health")
        all_ok &= _check(
            "health",
            code == 200 and '"status"' in body,
            f"HTTP {code} {body[:120]}",
        )
    except Exception as exc:  # noqa: BLE001
        all_ok &= _check("health", False, str(exc))

    for path in (
        "/v1/generate-bazi",
        "/v1/generate-chart",
        "/generate-bazi",
        "/generate-chart",
    ):
        try:
            code, body = _request("POST", f"{base}{path}", AUTH_PROBE)
            all_ok &= _check(
                f"auth {path}",
                code == 401,
                f"HTTP {code} {body[:200]}",
            )
        except Exception as exc:  # noqa: BLE001
            all_ok &= _check(f"auth {path}", False, str(exc))

    print("OVERALL:", "PASS" if all_ok else "FAIL")
    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())
