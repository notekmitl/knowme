import copy

import pytest

from app.services.bazi.builders.bazi_builder import (
    build_bazi,
    build_results_snapshot,
)
from app.services.bazi.utils.datetime_parser import InvalidBirthDatetime


def _known(
    date="1990-05-12",
    time="15:30",
    zone="Asia/Bangkok",
    latitude=13.7563,
    longitude=100.5018,
):
    return build_bazi(date, time, zone, latitude, longitude)


def _without_generated_at(chart):
    result = copy.deepcopy(chart)
    result.pop("generated_at", None)
    return result


def test_known_time_four_pillars_and_contract_metadata():
    chart = _known()

    assert chart["version"] == "knowme_bazi_compatibility_v1"
    assert chart["contract_id"] == "knowme_bazi_compatibility_v1"
    assert chart["contract_name"] == "KnowMe BaZi Compatibility V1"
    assert chart["engine_version"] == "lunar_python@1.4.8"
    assert chart["completeness"] == "four_pillars"
    assert chart["time_known"] is True
    assert [
        chart["pillars"][key]["pillar_label"]
        for key in ("year", "month", "day", "hour")
    ] == ["庚午", "辛巳", "丁丑", "戊申"]
    assert chart["suppressed_fields"] == []
    assert chart["ambiguities"] == {
        "year": False,
        "month": False,
        "day": False,
    }


def test_known_time_day_master_year_animal_and_surface_count():
    chart = _known()

    assert chart["day_master"] == {
        "stem": "丁",
        "stem_roman": "ding",
        "element": "fire",
        "polarity": "yin",
        "pillar_label": "丁丑",
    }
    assert chart["year_animal"] == {
        "zh": "马",
        "roman": "horse",
        "en": "Horse",
    }
    balance = chart["element_balance"]
    assert balance["method"] == "surface_stem_branch_compatibility_v1"
    assert balance["total_slots"] == 8
    assert [balance[key] for key in ("wood", "fire", "earth", "metal", "water")] == [
        0,
        3,
        2,
        3,
        0,
    ]


def test_lichun_exact_minute_changes_year_and_month():
    before = _known("1990-02-04", "10:13")
    at_boundary = _known("1990-02-04", "10:14")

    assert before["pillars"]["year"]["pillar_label"] == "己巳"
    assert before["pillars"]["month"]["pillar_label"] == "丁丑"
    assert at_boundary["pillars"]["year"]["pillar_label"] == "庚午"
    assert at_boundary["pillars"]["month"]["pillar_label"] == "戊寅"


def test_lunar_new_year_is_not_the_year_boundary_under_li_chun_policy():
    before_lunar_new_year = _known("1990-01-26", "12:00")
    lunar_new_year = _known("1990-01-27", "12:00")

    assert before_lunar_new_year["pillars"]["year"]["pillar_label"] == "己巳"
    assert lunar_new_year["pillars"]["year"]["pillar_label"] == "己巳"
    assert before_lunar_new_year["year_animal"] == lunar_new_year["year_animal"]


def test_jie_exact_minute_changes_month_only():
    before = _known("1990-03-06", "04:19")
    at_boundary = _known("1990-03-06", "04:20")

    assert before["pillars"]["month"]["pillar_label"] == "戊寅"
    assert at_boundary["pillars"]["month"]["pillar_label"] == "己卯"
    assert before["pillars"]["year"] == at_boundary["pillars"]["year"]


def test_sect_two_changes_day_at_civil_midnight_not_2300():
    at_2259 = _known("1990-05-12", "22:59")
    at_2300 = _known("1990-05-12", "23:00")
    at_2359 = _known("1990-05-12", "23:59")
    at_0000 = _known("1990-05-13", "00:00")

    assert at_2259["pillars"]["day"]["pillar_label"] == "丁丑"
    assert at_2300["pillars"]["day"]["pillar_label"] == "丁丑"
    assert at_2359["pillars"]["day"]["pillar_label"] == "丁丑"
    assert at_0000["pillars"]["day"]["pillar_label"] == "戊寅"
    assert at_2259["pillars"]["hour"]["pillar_label"] == "辛亥"
    assert at_2300["pillars"]["hour"]["pillar_label"] == "壬子"


def test_unknown_time_omits_hour_and_hour_dependent_slots():
    chart = build_bazi("1990-05-12", None, "Asia/Bangkok")

    assert chart["time_known"] is False
    assert chart["completeness"] == "three_pillars"
    assert chart["pillars"]["hour"] is None
    assert chart["pillars"]["year"] is not None
    assert chart["pillars"]["month"] is not None
    assert chart["pillars"]["day"] is not None
    assert chart["element_balance"]["total_slots"] == 6
    assert chart["suppressed_fields"] == [
        "pillars.hour",
        "hour_dependent_outputs",
    ]


def test_unknown_time_lichun_day_suppresses_ambiguous_year_month_and_animal():
    chart = build_bazi("1990-02-04", "", "Asia/Bangkok")

    assert chart["completeness"] == "partial_pillars"
    assert chart["pillars"]["year"] is None
    assert chart["pillars"]["month"] is None
    assert chart["pillars"]["day"] is not None
    assert chart["pillars"]["hour"] is None
    assert chart["year_animal"] is None
    assert chart["ambiguities"]["year"] is True
    assert chart["ambiguities"]["month"] is True
    assert chart["element_balance"]["total_slots"] == 2


def test_unknown_time_jie_day_suppresses_only_ambiguous_month():
    chart = build_bazi("1990-03-06", None, "Asia/Bangkok")

    assert chart["pillars"]["year"] is not None
    assert chart["pillars"]["month"] is None
    assert chart["pillars"]["day"] is not None
    assert chart["pillars"]["hour"] is None
    assert chart["year_animal"] is not None
    assert chart["ambiguities"]["year"] is False
    assert chart["ambiguities"]["month"] is True
    assert chart["element_balance"]["total_slots"] == 4


def test_timezone_is_validated_but_same_wall_clock_keeps_same_pillars():
    bangkok = _known(zone="Asia/Bangkok")
    london = _known(zone="Europe/London")

    assert bangkok["pillars"] == london["pillars"]
    assert bangkok["input_hash"] != london["input_hash"]
    with pytest.raises(InvalidBirthDatetime):
        _known(zone="Mars/Olympus_Mons")


def test_coordinates_are_recorded_but_do_not_change_calculation_or_hash():
    bangkok = _known(latitude=13.7563, longitude=100.5018)
    london = _known(latitude=51.5072, longitude=-0.1276)

    assert bangkok["pillars"] == london["pillars"]
    assert bangkok["input_hash"] == london["input_hash"]
    assert bangkok["input"]["coordinates_used_in_calculation"] is False


def test_leap_day_and_repeated_input_are_deterministic():
    first = _known("2000-02-29", "00:00")
    second = _known("2000-02-29", "00:00")

    assert _without_generated_at(first) == _without_generated_at(second)
    assert len(first["input_hash"]) == 64


def test_unknown_none_and_blank_normalize_to_same_hash():
    none_time = build_bazi("1990-05-12", None, "Asia/Bangkok")
    blank_time = build_bazi("1990-05-12", "  ", "Asia/Bangkok")
    assert none_time["input_hash"] == blank_time["input_hash"]


def test_results_snapshot_preserves_projection_and_suppressions():
    chart = build_bazi("1990-03-06", None, "Asia/Bangkok")
    snapshot = build_results_snapshot(chart)

    for key in (
        "contract_id",
        "input_hash",
        "time_known",
        "pillars",
        "element_balance",
        "ambiguities",
        "suppressed_fields",
    ):
        assert snapshot[key] == chart[key]
