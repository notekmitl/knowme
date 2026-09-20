#!/usr/bin/env python3
"""Repeatable local latency check for the deterministic Western V2 engine."""

import argparse
import json
import statistics
import sys
import time
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
BACKEND_ROOT = REPO_ROOT / "backend"
sys.path.insert(0, str(BACKEND_ROOT))

from app.services.astrology.builders.chart_builder import build_chart  # noqa: E402


CASES = (
    {
        "name": "owner_chiang_mai",
        "birth_date": "1982-06-06",
        "birth_time": "00:03",
        "latitude": 18.7883,
        "longitude": 98.9853,
        "timezone": "Asia/Bangkok",
    },
    {
        "name": "bangkok_daytime",
        "birth_date": "1990-05-12",
        "birth_time": "15:30",
        "latitude": 13.7563,
        "longitude": 100.5018,
        "timezone": "Asia/Bangkok",
    },
    {
        "name": "phuket_late_night",
        "birth_date": "2001-03-03",
        "birth_time": "23:45",
        "latitude": 7.8804,
        "longitude": 98.3923,
        "timezone": "Asia/Bangkok",
    },
)


def _measure(case, iterations):
    build_chart(**{key: value for key, value in case.items() if key != "name"})
    samples_ms = []
    chart = None
    for _ in range(iterations):
        started = time.perf_counter()
        chart = build_chart(
            **{key: value for key, value in case.items() if key != "name"}
        )
        samples_ms.append((time.perf_counter() - started) * 1000)

    return {
        "name": case["name"],
        "median_ms": round(statistics.median(samples_ms), 3),
        "p95_ms": round(sorted(samples_ms)[int(iterations * 0.95) - 1], 3),
        "big3": chart["big3"],
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--iterations", type=int, default=500)
    parser.add_argument("--max-median-ms", type=float, default=25.0)
    args = parser.parse_args()
    if args.iterations < 20:
        parser.error("--iterations must be at least 20")

    results = [_measure(case, args.iterations) for case in CASES]
    passed = all(item["median_ms"] <= args.max_median_ms for item in results)
    print(
        json.dumps(
            {
                "engine": "western_natal_v2",
                "iterations_per_case": args.iterations,
                "max_median_ms": args.max_median_ms,
                "passed": passed,
                "results": results,
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    raise SystemExit(0 if passed else 1)


if __name__ == "__main__":
    main()
