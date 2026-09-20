import pytest
from fastapi import HTTPException

from app.routes import astrology as astrology_route


def _request(uid="uid-1", *, with_profile=False):
    profile = None
    if with_profile:
        profile = astrology_route.WesternCanonicalProfileRequest(
            name="Owner QA",
            gender="male",
            birthDate="1990-05-12",
            birthTime="15:30",
            birthPlace="กรุงเทพมหานคร",
            latitude=13.7563,
            longitude=100.5018,
            timezone="Asia/Bangkok",
        )
    return astrology_route.GenerateChartRequest(
        uid=uid,
        birth_date="1990-05-12",
        birth_time="15:30",
        timezone="Asia/Bangkok",
        latitude=13.7563,
        longitude=100.5018,
        profile=profile,
    )


def _stub_calculation(monkeypatch, saved):
    monkeypatch.setattr(
        astrology_route,
        "build_chart",
        lambda *_args: {
            "version": "western_natal_v2",
            "big3": {"sun": "Taurus", "moon": "Sagittarius", "rising": "Libra"},
            "reader": {"overview": {"th": "summary", "en": "summary"}},
        },
    )
    monkeypatch.setattr(
        astrology_route,
        "generate_overall_summary",
        lambda _chart: {"th": "legacy", "en": "legacy"},
    )
    monkeypatch.setattr(
        astrology_route,
        "build_results_snapshot",
        lambda chart: {"version": chart["version"]},
    )
    monkeypatch.setattr(
        astrology_route,
        "save_chart",
        lambda uid, chart, results, profile_data=None: saved.append(
            (uid, chart, results, profile_data)
        ),
    )


def test_versioned_route_rejects_authenticated_uid_mismatch():
    with pytest.raises(HTTPException) as mismatch:
        astrology_route.generate_chart_v1(_request(uid="victim"), "attacker")

    assert mismatch.value.status_code == 403
    assert mismatch.value.detail["code"] == "UID_MISMATCH"


def test_versioned_route_writes_only_verified_uid_and_returns_chart(monkeypatch):
    saved = []
    _stub_calculation(monkeypatch, saved)

    response = astrology_route.generate_chart_v1(
        _request(with_profile=True),
        "uid-1",
    )

    assert response["success"] is True
    assert response["version"] == "western_natal_v2"
    assert response["chart"]["overall_summary"]["th"] == "summary"
    assert saved[0][0] == "uid-1"
    assert saved[0][2]["version"] == "western_natal_v2"
    assert saved[0][3]["birthDate"] == "1990-05-12"


def test_legacy_route_is_an_authenticated_alias(monkeypatch):
    saved = []
    _stub_calculation(monkeypatch, saved)

    response = astrology_route.generate_chart_legacy(
        _request(uid="legacy-user"),
        "legacy-user",
    )

    assert response["success"] is True
    assert saved[0][0] == "legacy-user"


def test_profile_fields_must_match_calculation_input():
    request = _request(with_profile=True)
    request.timezone = "Asia/Tokyo"

    with pytest.raises(HTTPException) as mismatch:
        astrology_route.generate_chart_v1(request, "uid-1")

    assert mismatch.value.status_code == 400
    assert mismatch.value.detail["code"] == "PROFILE_INPUT_MISMATCH"
