from statistics import median
from time import perf_counter

import pytest

from app.services.astrology.builders.chart_builder import build_chart
from app.services.astrology.reader import READER_REVISION, SIGN_TH
from app.services.bazi.utils.datetime_parser import InvalidBirthDatetime


READABILITY_FIXTURES = (
    ("1982-06-06", "00:03", 18.7883, 98.9853),
    ("1990-05-12", "15:30", 13.7563, 100.5018),
    ("2001-03-03", "23:45", 7.8804, 98.3923),
    ("1994-03-08", "12:00", 13.7563, 100.5018),
    ("1988-11-02", "12:15", 18.7883, 98.9853),
    ("1995-01-17", "18:20", 7.8804, 98.3923),
    ("2004-04-08", "09:05", 13.7563, 100.5018),
    ("1979-09-27", "21:10", 18.7883, 98.9853),
)


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
    assert chart["reader"]["version"] == READER_REVISION
    assert chart["input"]["local_civil"].startswith("1982-06-06T00:03:00+07:00")
    assert chart["input"]["utc_instant"] == "1982-06-05T17:03:00Z"
    assert chart["big3"] == {
        "sun": "Gemini",
        "moon": "Sagittarius",
        "rising": "Pisces",
    }
    assert chart["reader"]["overview"]["th"] == (
        "คุณเป็นคนช่างสงสัย เรียนรู้เร็ว และสนใจหลายเรื่อง "
        "ลึก ๆ ต้องการอิสระในการคิด แต่ภาพแรกที่คนอื่นเห็นเป็นคนอ่อนโยน"
        "และปรับตัวเก่ง จึงอาจมีคนคิดว่าคุณตามใจง่าย ทั้งที่จริงคุณมีความคิดเห็น"
        "และต้องการพื้นที่ตัดสินใจของตัวเอง"
    )


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
    assert all(section["basis"] for section in chart["reader"]["sections"])


def test_owner_reading_is_behavior_first_and_removes_ambiguous_copy():
    chart = build_chart(
        "1982-06-06",
        "00:03",
        18.7883,
        98.9853,
        "Asia/Bangkok",
    )
    rendered = "\n".join(
        [chart["reader"]["overview"]["th"]]
        + [item["body"] for item in chart["reader"]["sections"]]
    )
    forbidden = (
        "เติบโตในแบบราศี",
        "รับมือเรื่องส่วนตัวผ่านความรู้สึกแบบ",
        "นำเรื่องนี้มารวมในแผน",
        "ใช้จุดนี้จริง",
    )
    assert all(phrase not in rendered for phrase in forbidden)
    assert "จันทร์ในเรือน" not in rendered
    assert "ดาวเสาร์ในเรือน" not in rendered
    main_bodies = "\n".join(
        _section(chart, section_id)["body"]
        for section_id in ("identity", "work", "money", "love", "wellbeing")
    )
    assert all(
        marker not in main_bodies
        for marker in ("ราศี", "เรือน ", "ทำมุม", "ดาวพุธ", "ดาวศุกร์", "ดาวอังคาร")
    )
    for section_id in ("identity", "work", "money", "love", "wellbeing"):
        assert "จุดที่ควรระวัง" in _section(chart, section_id)["body"]


def test_eight_readability_fixtures_cover_elements_modalities_and_real_chart_bases():
    charts = [build_chart(*fixture, "Asia/Bangkok") for fixture in READABILITY_FIXTURES]

    assert {chart["analysis"]["elements"]["dominant"] for chart in charts} >= {
        "fire",
        "earth",
        "air",
        "water",
    }
    assert {chart["analysis"]["modalities"]["dominant"] for chart in charts} >= {
        "cardinal",
        "fixed",
        "mutable",
    }

    normalized_readings = set()
    for chart in charts:
        reader = chart["reader"]
        assert reader["version"] == READER_REVISION
        assert _section(reader, "identity")["basis"] == (
            f"ดวงอาทิตย์ราศี{SIGN_TH[chart['big3']['sun']]} · "
            f"ดวงจันทร์ราศี{SIGN_TH[chart['big3']['moon']]} · "
            f"ลัคนาราศี{SIGN_TH[chart['big3']['rising']]}"
        )
        assert f"ดาวพุธราศี{SIGN_TH[chart['planets']['mercury']['sign']]}" in _section(
            reader, "work"
        )["basis"]
        assert f"ดาวอังคารราศี{SIGN_TH[chart['planets']['mars']['sign']]}" in _section(
            reader, "work"
        )["basis"]
        assert f"ดาวศุกร์ราศี{SIGN_TH[chart['planets']['venus']['sign']]}" in _section(
            reader, "money"
        )["basis"]
        assert f"ดวงจันทร์ราศี{SIGN_TH[chart['big3']['moon']]}" in _section(
            reader, "wellbeing"
        )["basis"]
        _assert_referenced_houses_exist(chart)
        _assert_referenced_aspects_exist(chart)

        text = " ".join(
            [reader["overview"]["th"]]
            + [item["body"] for item in reader["sections"]]
        )
        for sign in tuple(SIGN_TH) + tuple(SIGN_TH.values()):
            text = text.replace(sign, "<sign>")
        normalized_readings.add(text)

    assert len(normalized_readings) == len(charts)


def _section(source: dict, section_id: str) -> dict:
    reader = source.get("reader", source)
    return next(item for item in reader["sections"] if item["id"] == section_id)


def _assert_referenced_houses_exist(chart: dict) -> None:
    for section in chart["reader"]["sections"]:
        basis = section["basis"]
        if "ไม่มีดาวหลัก" in basis:
            continue
        for house in (2, 6, 8, 10):
            if f"ในเรือน {house}" not in basis:
                continue
            assert any(
                data.get("house") == house
                and planet_name in basis
                for planet, data in chart["planets"].items()
                for planet_name in (_planet_th(planet),)
            )


def _assert_referenced_aspects_exist(chart: dict) -> None:
    markers = {
        "conjunction": "กุมกัน",
        "sextile": "ทำมุม 60°",
        "square": "ทำมุม 90°",
        "trine": "ทำมุม 120°",
        "opposition": "ทำมุม 180°",
    }
    bases = "\n".join(item["basis"] for item in chart["reader"]["sections"])
    for kind, marker in markers.items():
        if marker not in bases:
            continue
        assert any(
            aspect["aspect"] == kind
            and _planet_th(aspect["planet1"]) in bases
            and _planet_th(aspect["planet2"]) in bases
            for aspect in chart["aspects"]
        )


def _planet_th(planet: str) -> str:
    return {
        "sun": "ดวงอาทิตย์",
        "moon": "ดวงจันทร์",
        "mercury": "ดาวพุธ",
        "venus": "ดาวศุกร์",
        "mars": "ดาวอังคาร",
        "jupiter": "ดาวพฤหัสบดี",
        "saturn": "ดาวเสาร์",
    }[planet]


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
