"""The standalone calculator accepts only explicitly configured web origins."""

import importlib

from fastapi.testclient import TestClient

from app import preview_main


def test_public_trial_origins_and_only_calculation_routes(monkeypatch):
    origins = (
        "https://knowme-app-694e1.web.app,"
        "https://knowme-app-694e1.firebaseapp.com"
    )
    monkeypatch.setenv("CALCULATOR_ALLOWED_ORIGINS", origins)
    try:
        calculator = importlib.reload(preview_main)
        paths = {route.path for route in calculator.app.routes}
        assert "/v1/calculate-bazi" in paths
        assert "/v1/calculate-chart" in paths
        assert "/v1/generate-bazi" not in paths
        assert "/v1/generate-chart" not in paths
        client = TestClient(calculator.app)
        for origin in origins.split(","):
            response = client.options(
                "/v1/calculate-bazi",
                headers={
                    "Origin": origin,
                    "Access-Control-Request-Method": "POST",
                    "Access-Control-Request-Headers": "content-type",
                },
            )
            assert response.status_code == 200
            assert response.headers["access-control-allow-origin"] == origin

        denied = client.options(
            "/v1/calculate-bazi",
            headers={
                "Origin": "https://untrusted.example",
                "Access-Control-Request-Method": "POST",
            },
        )
        assert denied.status_code == 400
    finally:
        monkeypatch.delenv("CALCULATOR_ALLOWED_ORIGINS")
        importlib.reload(preview_main)


def test_calculator_rejects_wildcard_cors(monkeypatch):
    monkeypatch.setenv("CALCULATOR_ALLOWED_ORIGINS", "https://*.example.com")
    try:
        try:
            importlib.reload(preview_main)
        except ValueError as exc:
            assert "exact HTTPS origins" in str(exc)
        else:
            raise AssertionError("Wildcard origin accepted")
    finally:
        monkeypatch.delenv("CALCULATOR_ALLOWED_ORIGINS")
        importlib.reload(preview_main)
