import json

from fastapi.testclient import TestClient

from app import main as main_module
from app.routes import astrology as astrology_route
from app.security.firebase_auth import (
    FirebaseAuthTiming,
    current_firebase_user_with_timing,
)


def test_structured_western_timing_has_required_phases_without_private_data(
    monkeypatch,
    caplog,
):
    monkeypatch.setattr(main_module, "initialize_firebase_admin", lambda: None)
    monkeypatch.setattr(main_module, "_firestore_client", lambda: object())
    monkeypatch.setattr(
        main_module,
        "warm_firestore_connection",
        lambda _db: 1.0,
    )

    def build_chart(*_args, phase_timings=None, **_kwargs):
        phase_timings["astrology_calculation_ms"] = 2.5
        phase_timings["reader_composition_ms"] = 0.01
        return {
            "version": "western_natal_v2",
            "contract_id": "knowme_western_reader_v2",
            "big3": {
                "sun": "Gemini",
                "moon": "Sagittarius",
                "rising": "Pisces",
            },
            "reader": {
                "version": "western_reader_th_v2_r2",
                "overview": {"th": "summary", "en": "summary"},
            },
        }

    monkeypatch.setattr(astrology_route, "build_chart", build_chart)
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
        lambda *_args, **_kwargs: True,
    )
    main_module.app.dependency_overrides[current_firebase_user_with_timing] = (
        lambda: FirebaseAuthTiming(uid="uid-private", duration_ms=12.5)
    )

    payload = {
        "uid": "uid-private",
        "birth_date": "1982-06-06",
        "birth_time": "00:03",
        "timezone": "Asia/Bangkok",
        "latitude": 18.7883,
        "longitude": 98.9853,
        "profile": {
            "name": "Owner Private",
            "gender": "",
            "birthDate": "1982-06-06",
            "birthTime": "00:03",
            "birthPlace": "เชียงใหม่",
            "latitude": 18.7883,
            "longitude": 98.9853,
            "timezone": "Asia/Bangkok",
        },
    }

    try:
        with caplog.at_level("INFO"):
            with TestClient(main_module.app) as client:
                response = client.post(
                    "/v1/generate-chart",
                    headers={"Authorization": "Bearer secret-token"},
                    json=payload,
                )
    finally:
        main_module.app.dependency_overrides.clear()

    assert response.status_code == 200
    timing_records = [
        record
        for record in caplog.records
        if '"event":"western_generation_timing"' in record.message
    ]
    assert len(timing_records) == 1
    message = timing_records[0].message
    timing = json.loads(message)
    assert timing["status"] == 200
    assert set(timing["phases_ms"]) >= {
        "authentication_ms",
        "profile_input_loading_ms",
        "astrology_calculation_ms",
        "reader_composition_ms",
        "response_assembly_ms",
        "firestore_save_ms",
        "response_serialization_ms",
        "total_ms",
    }
    assert timing["phases_ms"]["authentication_ms"] == 12.5
    for private_value in (
        "secret-token",
        "uid-private",
        "Owner Private",
        "1982-06-06",
        "18.7883",
        "98.9853",
        "เชียงใหม่",
    ):
        assert private_value not in message
