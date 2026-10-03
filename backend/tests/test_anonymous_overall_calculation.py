"""The overall reader must not authenticate or touch Firestore."""

from fastapi.testclient import TestClient

from app.main import app
from app.routes import astrology, bazi


BAZI_INPUT = {
    "birth_date": "2001-01-15",
    "birth_time": "12:34",
    "timezone": "Asia/Bangkok",
    "latitude": 13.7563,
    "longitude": 100.5018,
    "gender": "female",
}
WESTERN_INPUT = {key: value for key, value in BAZI_INPUT.items() if key != "gender"}


def test_anonymous_http_calculations_return_real_charts_without_writes(monkeypatch):
    def forbidden_write(*_args, **_kwargs):
        raise AssertionError("anonymous calculation attempted a Firestore write")

    monkeypatch.setattr(bazi, "save_bazi", forbidden_write)
    monkeypatch.setattr(astrology, "save_chart", forbidden_write)
    client = TestClient(app)

    bazi_response = client.post("/v1/calculate-bazi", json=BAZI_INPUT)
    western_response = client.post("/v1/calculate-chart", json=WESTERN_INPUT)

    assert bazi_response.status_code == 200
    assert western_response.status_code == 200
    bazi_body = bazi_response.json()
    western_body = western_response.json()
    assert bazi_body["chart"]["completeness"] == "four_pillars"
    assert bazi_body["chart"]["pillars"]["hour"] is not None
    assert western_body["chart"]["big3"]["rising"]
    assert western_body["chart"]["reader"]
    for body in (bazi_body, western_body):
        assert body["success"] is True
        assert "saved_paths" not in body
        assert "uid" not in body


def test_anonymous_routes_reject_uid_and_profile_and_keep_saved_routes_private():
    client = TestClient(app)
    for route, birth_input in (
        ("/v1/calculate-bazi", BAZI_INPUT),
        ("/v1/calculate-chart", WESTERN_INPUT),
    ):
        assert client.post(route, json={**birth_input, "uid": "someone"}).status_code == 422
        assert client.post(route, json={**birth_input, "profile": {}}).status_code == 422

    assert client.post("/v1/generate-bazi", json={**BAZI_INPUT, "uid": "someone"}).status_code == 401
    assert client.post("/v1/generate-chart", json={**WESTERN_INPUT, "uid": "someone"}).status_code == 401


def test_existing_authenticated_request_models_keep_ignoring_extra_fields():
    assert bazi.GenerateBaziRequest.model_validate(
        {**BAZI_INPUT, "uid": "existing", "legacy_extension": True}
    ).uid == "existing"
    assert astrology.GenerateChartRequest.model_validate(
        {**WESTERN_INPUT, "uid": "existing", "legacy_extension": True}
    ).uid == "existing"
