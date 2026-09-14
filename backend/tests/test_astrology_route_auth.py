import pytest
from fastapi import HTTPException

from app.routes import astrology as astrology_route


def _request(uid="uid-1"):
    return astrology_route.GenerateChartRequest(
        uid=uid,
        birth_date="1990-05-12",
        birth_time="15:30",
        latitude=13.7563,
        longitude=100.5018,
    )


def _stub_calculation(monkeypatch, saved):
    monkeypatch.setattr(
        astrology_route,
        "build_chart",
        lambda *_args: {"planets": {"Sun": {"sign": "Taurus"}}},
    )
    monkeypatch.setattr(
        astrology_route,
        "generate_overall_summary",
        lambda _chart: {"th": "summary", "en": "summary"},
    )
    monkeypatch.setattr(
        astrology_route,
        "save_chart",
        lambda uid, chart: saved.append((uid, chart)),
    )


def test_versioned_route_rejects_authenticated_uid_mismatch():
    with pytest.raises(HTTPException) as mismatch:
        astrology_route.generate_chart_v1(_request(uid="victim"), "attacker")

    assert mismatch.value.status_code == 403
    assert mismatch.value.detail["code"] == "UID_MISMATCH"


def test_versioned_route_writes_only_verified_uid(monkeypatch):
    saved = []
    _stub_calculation(monkeypatch, saved)

    response = astrology_route.generate_chart_v1(_request(), "uid-1")

    assert response["success"] is True
    assert saved[0][0] == "uid-1"
    assert saved[0][1]["overall_summary"]["th"] == "summary"


def test_legacy_route_remains_available_for_released_clients(monkeypatch):
    saved = []
    _stub_calculation(monkeypatch, saved)

    response = astrology_route.generate_chart_legacy(_request(uid="legacy-user"))

    assert response["success"] is True
    assert saved[0][0] == "legacy-user"
