import pytest
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials

from app.routes import bazi as bazi_route
from app.security import firebase_auth


def _credentials(token="valid-token", scheme="Bearer"):
    return HTTPAuthorizationCredentials(scheme=scheme, credentials=token)


def _request(uid="uid-1", birth_time="15:30"):
    return bazi_route.GenerateBaziRequest(
        uid=uid,
        birth_date="1990-05-12",
        birth_time=birth_time,
        timezone="Asia/Bangkok",
    )


def test_missing_or_invalid_bearer_token_is_unauthorized(monkeypatch):
    with pytest.raises(HTTPException) as missing:
        firebase_auth.verify_firebase_user(None)
    assert missing.value.status_code == 401
    assert missing.value.detail["code"] == "AUTH_REQUIRED"

    def reject(*_args, **_kwargs):
        raise ValueError("invalid")

    monkeypatch.setattr(firebase_auth.auth, "verify_id_token", reject)
    with pytest.raises(HTTPException) as invalid:
        firebase_auth.verify_firebase_user(_credentials("invalid-token"))
    assert invalid.value.status_code == 401
    assert invalid.value.detail["code"] == "AUTH_REQUIRED"


def test_verified_token_returns_uid_and_checks_revocation(monkeypatch):
    calls = []

    def verify(token, *, check_revoked):
        calls.append((token, check_revoked))
        return {"uid": "uid-1"}

    monkeypatch.setattr(firebase_auth.auth, "verify_id_token", verify)

    assert firebase_auth.verify_firebase_user(_credentials()) == "uid-1"
    assert calls == [("valid-token", True)]


def test_route_rejects_authenticated_uid_mismatch():
    with pytest.raises(HTTPException) as mismatch:
        bazi_route.generate_bazi(_request(uid="victim"), "attacker")

    assert mismatch.value.status_code == 403
    assert mismatch.value.detail["code"] == "UID_MISMATCH"


def test_route_writes_only_verified_uid_and_supports_unknown_time(monkeypatch):
    saved = []

    def save(uid, chart, snapshot):
        saved.append((uid, chart, snapshot))
        return True

    monkeypatch.setattr(bazi_route, "save_bazi", save)
    response = bazi_route.generate_bazi(_request(birth_time=None), "uid-1")

    assert response["success"] is True
    assert response["chart"]["time_known"] is False
    assert response["chart"]["pillars"]["hour"] is None
    assert response["saved_paths"] == {
        "astrology": "users/uid-1/astrology/chinese_bazi",
        "results": "users/uid-1/results/chinese_bazi",
    }
    assert saved[0][0] == "uid-1"
    assert saved[0][1]["input_hash"] == saved[0][2]["input_hash"]
