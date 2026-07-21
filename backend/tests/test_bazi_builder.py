import pytest

from app.services.bazi.builders.bazi_builder import build_bazi
from app.services.bazi.utils.datetime_parser import MissingBirthTime


def test_four_pillars_standard_case():
    chart = build_bazi(
        birth_date="1990-05-12",
        birth_time="15:30",
        timezone="Asia/Bangkok",
    )

    assert chart["completeness"] == "four_pillars"
    assert chart["pillars"]["year"]["pillar_label"] == "庚午"
    assert chart["pillars"]["month"]["pillar_label"] == "辛巳"
    assert chart["pillars"]["day"]["pillar_label"] == "丁丑"
    assert chart["pillars"]["hour"]["pillar_label"] == "戊申"


def test_day_master():
    chart = build_bazi(
        birth_date="1990-05-12",
        birth_time="15:30",
        timezone="Asia/Bangkok",
    )

    dm = chart["day_master"]
    assert dm["stem"] == "丁"
    assert dm["stem_roman"] == "ding"
    assert dm["element"] == "fire"
    assert dm["polarity"] == "yin"
    assert dm["pillar_label"] == "丁丑"


def test_lichun_boundary_before():
    chart = build_bazi(
        birth_date="1990-02-03",
        birth_time="12:00",
        timezone="Asia/Bangkok",
    )

    assert chart["pillars"]["year"]["pillar_label"] == "己巳"
    assert chart["year_animal"]["roman"] == "snake"


def test_lichun_boundary_after():
    chart = build_bazi(
        birth_date="1990-02-04",
        birth_time="12:00",
        timezone="Asia/Bangkok",
    )

    assert chart["pillars"]["year"]["pillar_label"] == "庚午"
    assert chart["year_animal"]["roman"] == "horse"


def test_year_animal():
    chart = build_bazi(
        birth_date="1990-05-12",
        birth_time="15:30",
        timezone="Asia/Bangkok",
    )

    animal = chart["year_animal"]
    assert animal["zh"] == "马"
    assert animal["roman"] == "horse"
    assert animal["en"] == "Horse"


def test_element_balance_surface_stem_branch_v1():
    chart = build_bazi(
        birth_date="1990-05-12",
        birth_time="15:30",
        timezone="Asia/Bangkok",
    )

    balance = chart["element_balance"]
    assert balance["method"] == "surface_stem_branch_v1"
    assert balance["total_slots"] == 8
    assert balance["wood"] == 0
    assert balance["fire"] == 3
    assert balance["earth"] == 2
    assert balance["metal"] == 3
    assert balance["water"] == 0
    assert chart["dominant_element"] == "fire"


def test_required_metadata_fields():
    chart = build_bazi(
        birth_date="1990-05-12",
        birth_time="15:30",
        timezone="Asia/Bangkok",
    )

    assert chart["version"] == "bazi_v1"
    assert chart["engine_version"] == "lunar_python@1.4.8"
    assert chart["generated_at"]
    assert len(chart["input_hash"]) == 64


def test_birth_time_required():
    with pytest.raises(MissingBirthTime):
        build_bazi(
            birth_date="1990-05-12",
            birth_time="",
            timezone="Asia/Bangkok",
        )
