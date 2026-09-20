from statistics import median
from time import perf_counter

import pytest

from app.services.astrology.builders.chart_builder import build_chart
from app.services.bazi.utils.datetime_parser import InvalidBirthDatetime


def test_owner_case_uses_exact_bangkok_instant_and_correct_rising():
    chart = build_chart(
        "1982-06-06",
        "00:03",
        18.7883,
        98.9853,
        "Asia/Bangkok",
    )

    assert chart["version"] == "western_natal_v2"
    assert chart["contract_id"] == "knowme_western_reader_v2"
    assert chart["input"]["local_civil"].startswith("1982-06-06T00:03:00+07:00")
    assert chart["input"]["utc_instant"] == "1982-06-05T17:03:00Z"
    assert chart["big3"] == {
        "sun": "Gemini",
        "moon": "Sagittarius",
        "rising": "Pisces",
    }


def test_reader_v2_covers_required_whole_chart_signals():
    chart = build_chart(
        "1990-05-12",
        "15:30",
        13.7563,
        100.5018,
        "Asia/Bangkok",
    )

    assert chart["big3"]["rising"] == "Libra"
    assert set(chart["analysis"]) == {
        "elements",
        "modalities",
        "polarities",
        "dominant_planets",
        "house_emphasis",
        "major_aspects",
    }
    assert sum(chart["analysis"]["elements"]["percentages"].values()) in range(98, 103)
    assert chart["analysis"]["dominant_planets"]
    assert chart["analysis"]["house_emphasis"]
    assert chart["aspects"] == sorted(chart["aspects"], key=lambda item: item["orb"])
    section_ids = {item["id"] for item in chart["reader"]["sections"]}
    assert section_ids == {
        "identity",
        "work",
        "money",
        "love",
        "wellbeing",
        "strengths",
        "cautions",
        "guidance",
    }
    assert all(item["th"] for item in chart["interpretations"])
    assert chart["reader"]["method"]
    assert chart["reader"]["disclaimer"]


def test_invalid_or_ambiguous_local_time_fails_closed():
    with pytest.raises(InvalidBirthDatetime):
        build_chart(
            "2021-11-07",
            "01:30",
            40.7128,
            -74.0060,
            "America/New_York",
        )


def test_pure_chart_generation_stays_below_25_ms_median():
    samples = []
    for _ in range(30):
        started = perf_counter()
        build_chart(
            "1982-06-06",
            "00:03",
            18.7883,
            98.9853,
            "Asia/Bangkok",
        )
        samples.append((perf_counter() - started) * 1000)

    assert median(samples[5:]) < 25
