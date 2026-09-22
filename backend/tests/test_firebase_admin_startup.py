from pathlib import Path
import subprocess
import sys

from fastapi.testclient import TestClient

from app import main as main_module
from app.services import firebase_admin_service


def test_importing_api_app_keeps_firebase_and_firestore_lazy():
    backend_root = Path(__file__).resolve().parents[1]
    probe = subprocess.run(
        [
            sys.executable,
            "-c",
            """
import sys
import firebase_admin
import app.main

assert "app.services.firebase_service" not in sys.modules
try:
    firebase_admin.get_app()
except ValueError:
    pass
else:
    raise AssertionError("Firebase Admin initialized during module import")
""",
        ],
        cwd=backend_root,
        capture_output=True,
        text=True,
        check=False,
    )

    assert probe.returncode == 0, probe.stdout + probe.stderr


def test_api_startup_initializes_firebase_admin_before_serving(monkeypatch):
    calls = []
    monkeypatch.setattr(
        main_module,
        "initialize_firebase_admin",
        lambda: calls.append("initialized"),
    )
    firestore_client = object()
    monkeypatch.setattr(
        main_module,
        "_firestore_client",
        lambda: calls.append("firestore-client") or firestore_client,
    )
    monkeypatch.setattr(
        main_module,
        "warm_firestore_connection",
        lambda db: calls.append(("firestore-warm", db)),
    )

    with TestClient(main_module.app) as client:
        response = client.get("/health")

    assert response.status_code == 200
    assert calls == [
        "initialized",
        "firestore-client",
        ("firestore-warm", firestore_client),
    ]


def test_initialization_reuses_existing_default_app(monkeypatch):
    existing_app = object()
    monkeypatch.setattr(
        firebase_admin_service.firebase_admin,
        "get_app",
        lambda: existing_app,
    )

    def unexpected_initialize(*_args, **_kwargs):
        raise AssertionError("initialize_app must not run twice")

    monkeypatch.setattr(
        firebase_admin_service.firebase_admin,
        "initialize_app",
        unexpected_initialize,
    )

    assert firebase_admin_service.initialize_firebase_admin() is existing_app


def test_initialization_uses_application_default_credentials_when_file_missing(
    monkeypatch,
):
    initialized_app = object()
    calls = []

    def missing_default_app():
        raise ValueError("default app does not exist")

    monkeypatch.setattr(
        firebase_admin_service.firebase_admin,
        "get_app",
        missing_default_app,
    )
    monkeypatch.setattr(firebase_admin_service.os.path, "isfile", lambda _path: False)
    monkeypatch.setattr(
        firebase_admin_service.firebase_admin,
        "initialize_app",
        lambda: calls.append("application-default") or initialized_app,
    )

    assert firebase_admin_service.initialize_firebase_admin() is initialized_app
    assert calls == ["application-default"]


def test_initialization_uses_configured_service_account_file(monkeypatch):
    initialized_app = object()
    certificate = object()
    calls = []

    def missing_default_app():
        raise ValueError("default app does not exist")

    monkeypatch.setenv("GOOGLE_APPLICATION_CREDENTIALS", "configured-key.json")
    monkeypatch.setattr(
        firebase_admin_service.firebase_admin,
        "get_app",
        missing_default_app,
    )
    monkeypatch.setattr(firebase_admin_service.os.path, "isfile", lambda _path: True)
    monkeypatch.setattr(
        firebase_admin_service.credentials,
        "Certificate",
        lambda path: calls.append(("certificate", path)) or certificate,
    )
    monkeypatch.setattr(
        firebase_admin_service.firebase_admin,
        "initialize_app",
        lambda cred: calls.append(("initialize", cred)) or initialized_app,
    )

    assert firebase_admin_service.initialize_firebase_admin() is initialized_app
    assert calls == [
        ("certificate", "configured-key.json"),
        ("initialize", certificate),
    ]
