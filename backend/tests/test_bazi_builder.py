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
    gender=None,
):
    return build_bazi(date, time, zone, latitude, longitude, gender)


def _without_generated_at(chart):
    result = copy.deepcopy(chart)
    result.pop("generated_at", None)
    return result


def test_known_time_four_pillars_and_contract_metadata():
    chart = _known()

    assert chart["version"] == "knowme_bazi_reader_v3"
    assert chart["contract_id"] == "knowme_bazi_reader_v3"
    assert chart["contract_name"] == "KnowMe BaZi Reader V3"
    assert chart["engine_version"] == (
        "lunar_python@1.4.8+tzdata@2025.2+noaa_eot_v1"
    )
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
    assert chart["input"]["coordinates_used_in_calculation"] is True
    assert chart["solar_time"] == {
        "status": "computed",
        "method": "noaa_fractional_year_eot_v1",
        "local_civil_datetime": "1990-05-12T15:30:00+07:00",
        "timezone": "Asia/Bangkok",
        "historical_utc_offset_minutes": 420.0,
        "standard_meridian_degrees": 105.0,
        "latitude_degrees": 13.7563,
        "longitude_degrees": 100.5018,
        "longitude_correction_minutes": -17.9928,
        "equation_of_time_minutes": 3.897586,
        "total_correction_minutes": -14.095214,
        "apparent_solar_datetime": "1990-05-12T15:15:54",
        "rounding": "nearest_second_half_up",
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


def test_reader_v3_reference_profile_has_structured_facts_and_current_timing():
    chart = _known(
        gender="male",
    )

    assert [
        chart["pillars"][key]["pillar_label"]
        for key in ("year", "month", "day", "hour")
    ] == ["庚午", "辛巳", "丁丑", "戊申"]
    assert chart["day_master"]["stem"] == "丁"
    assert chart["pillars"]["year"]["hidden_stems"] == ["丁", "己"]
    assert chart["pillars"]["month"]["hidden_ten_gods"] == [
        "劫财",
        "正财",
        "伤官",
    ]
    assert chart["ten_god_balance"]["family_weight"] == {
        "resource": 0,
        "peer": 2,
        "output": 6,
        "wealth": 7,
        "authority": 2,
    }
    assert chart["ten_god_balance"]["top_families"] == ["wealth"]
    assert chart["day_master_support"] == {
        "score": 4,
        "max_score": 9,
        "band": "balanced",
        "season_score": 3,
        "ground_score": 1,
        "visible_support_score": 0,
        "resource_element": "wood",
        "method": "three_gains_primary_qi_v2",
    }
    assert [relation["kind"] for relation in chart["natal_relations"]] == [
        "branch_harm",
        "branch_combine",
    ]
    assert chart["luck"]["direction"] == "forward"
    assert chart["luck"]["onset"] == {
        "years": 8,
        "months": 2,
        "days": 10,
        "date": "1998-07-22",
    }
    current = next(
        cycle
        for cycle in chart["luck"]["cycles"]
        if cycle["start_year"] <= 2026 <= cycle["end_year"]
    )
    assert current["pillar_label"] == "甲申"
    assert current["stem_ten_god"] == "正印"
    annual = next(item for item in current["annual"] if item["year"] == 2026)
    assert annual["pillar_label"] == "丙午"
    assert annual["stem_ten_god"] == "劫财"
    assert [relation["kind"] for relation in annual["natal_relations"]] == [
        "branch_self_punishment",
        "stem_combine",
        "branch_harm",
    ]
    assert chart["input_hash"] == (
        "a30a41564cbfccc72891e75bb463c7157622f8c5832a4625dd4bc81d072bd287"
    )


def test_lichun_exact_minute_changes_year_and_month():
    before = _known("1990-02-04", "10:45")
    at_boundary = _known("1990-02-04", "10:46")

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
    before = _known("1990-03-06", "04:49")
    at_boundary = _known("1990-03-06", "04:50")

    assert before["pillars"]["month"]["pillar_label"] == "戊寅"
    assert at_boundary["pillars"]["month"]["pillar_label"] == "己卯"
    assert before["pillars"]["year"] == at_boundary["pillars"]["year"]


def test_sect_two_changes_day_at_apparent_solar_midnight():
    before = _known("1990-05-13", "00:14")
    after = _known("1990-05-13", "00:15")

    assert before["solar_time"]["apparent_solar_datetime"] == (
        "1990-05-12T23:59:55"
    )
    assert after["solar_time"]["apparent_solar_datetime"] == (
        "1990-05-13T00:00:55"
    )
    assert before["pillars"]["day"]["pillar_label"] == "丁丑"
    assert after["pillars"]["day"]["pillar_label"] == "戊寅"


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
    assert chart["solar_time"] == {
        "status": "not_computed_unknown_birth_time",
        "method": "noaa_fractional_year_eot_v1",
        "timezone": "Asia/Bangkok",
        "apparent_solar_datetime": None,
    }
    assert chart["input"]["coordinates_used_in_calculation"] is False
    assert chart["luck"] is None


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


def test_historical_timezone_offset_changes_true_solar_correction():
    bangkok = _known(
        zone="Asia/Bangkok",
        latitude=13.7563,
        longitude=100.5018,
    )
    london = _known(
        zone="Europe/London",
        latitude=51.5072,
        longitude=-0.1276,
    )

    assert bangkok["solar_time"]["historical_utc_offset_minutes"] == 420.0
    assert london["solar_time"]["historical_utc_offset_minutes"] == 60.0
    assert bangkok["solar_time"] != london["solar_time"]
    assert bangkok["input_hash"] != london["input_hash"]
    with pytest.raises(InvalidBirthDatetime):
        _known(zone="Mars/Olympus_Mons")


def test_coordinates_change_true_solar_calculation_and_hash():
    bangkok = _known(latitude=13.7563, longitude=100.5018)
    london = _known(latitude=51.5072, longitude=-0.1276)

    assert bangkok["solar_time"]["apparent_solar_datetime"] != (
        london["solar_time"]["apparent_solar_datetime"]
    )
    assert bangkok["pillars"] != london["pillars"]
    assert bangkok["input_hash"] != london["input_hash"]
    assert bangkok["input"]["coordinates_used_in_calculation"] is True


def test_known_time_requires_valid_coordinates():
    with pytest.raises(InvalidBirthDatetime, match="latitude and longitude"):
        build_bazi("1990-05-12", "15:30", "Asia/Bangkok")
    with pytest.raises(InvalidBirthDatetime, match="latitude"):
        _known(latitude=91.0)
    with pytest.raises(InvalidBirthDatetime, match="longitude"):
        _known(longitude=181.0)


def test_historical_dst_gap_and_fold_fail_closed_instead_of_guessing():
    with pytest.raises(InvalidBirthDatetime, match="does not exist"):
        build_bazi(
            "2020-03-08",
            "02:30",
            "America/New_York",
            40.7128,
            -74.006,
        )
    with pytest.raises(InvalidBirthDatetime, match="ambiguous"):
        build_bazi(
            "2020-11-01",
            "01:30",
            "America/New_York",
            40.7128,
            -74.006,
        )


def test_gender_is_normalized_and_changes_reader_v3_fingerprint_and_luck():
    male = _known(gender="ชาย")
    female = _known(gender="female")

    assert male["input"]["gender"] == "male"
    assert female["input"]["gender"] == "female"
    assert male["input_hash"] != female["input_hash"]
    assert male["luck"]["direction"] != female["luck"]["direction"]


def test_leap_day_and_repeated_input_are_deterministic():
    first = _known("2000-02-29", "00:00")
    second = _known("2000-02-29", "00:00")

    assert _without_generated_at(first) == _without_generated_at(second)
    assert len(first["input_hash"]) == 64


def test_unknown_none_and_blank_normalize_to_same_hash():
    none_time = build_bazi("1990-05-12", None, "Asia/Bangkok")
    blank_time = build_bazi("1990-05-12", "  ", "Asia/Bangkok")
    assert none_time["input_hash"] == blank_time["input_hash"]


def test_unknown_time_coordinates_do_not_change_hash_or_invent_solar_time():
    missing = build_bazi("1990-05-12", None, "Asia/Bangkok")
    supplied = build_bazi(
        "1990-05-12",
        None,
        "Asia/Bangkok",
        13.7563,
        100.5018,
    )
    assert missing["input_hash"] == supplied["input_hash"]
    assert supplied["solar_time"]["apparent_solar_datetime"] is None
    assert supplied["pillars"]["hour"] is None


def test_results_snapshot_preserves_projection_and_suppressions():
    chart = build_bazi("1990-03-06", None, "Asia/Bangkok")
    snapshot = build_results_snapshot(chart)

    for key in (
        "contract_id",
        "input_hash",
        "time_known",
        "solar_time",
        "pillars",
        "element_balance",
        "ten_god_balance",
        "day_master_support",
        "natal_relations",
        "luck",
        "ambiguities",
        "suppressed_fields",
    ):
        assert snapshot[key] == chart[key]
