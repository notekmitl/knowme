import pytest
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials

from app.routes import bazi as bazi_route
from app.security import firebase_auth


def _credentials(token="valid-token", scheme="Bearer"):
    return HTTPAuthorizationCredentials(scheme=scheme, credentials=token)


def _profile(birth_time="15:30"):
    return bazi_route.CanonicalProfileRequest(
        name="Test User",
        gender="male",
        birthDate="1990-05-12",
        birthTime=birth_time or "",
        birthPlace="Bangkok",
        latitude=13.7563,
        longitude=100.5018,
        timezone="Asia/Bangkok",
    )


def _request(uid="uid-1", birth_time="15:30", profile=None):
    return bazi_route.GenerateBaziRequest(
        uid=uid,
        birth_date="1990-05-12",
        birth_time=birth_time,
        timezone="Asia/Bangkok",
        latitude=13.7563,
        longitude=100.5018,
        gender="male",
        profile=profile,
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
        bazi_route.generate_bazi_v1(_request(uid="victim"), "attacker")

    assert mismatch.value.status_code == 403
    assert mismatch.value.detail["code"] == "UID_MISMATCH"


def test_route_writes_only_verified_uid_and_supports_unknown_time(monkeypatch):
    saved = []

    def save(uid, chart, snapshot, *, profile_data=None):
        saved.append((uid, chart, snapshot, profile_data))
        return True

    monkeypatch.setattr(bazi_route, "save_bazi", save)
    response = bazi_route.generate_bazi_v1(_request(birth_time=None), "uid-1")

    assert response["success"] is True
    assert response["chart"]["time_known"] is False
    assert response["chart"]["pillars"]["hour"] is None
    assert response["chart"]["input"]["gender"] == "male"
    assert response["chart"]["luck"] is None
    assert response["chart"]["solar_time"]["status"] == (
        "not_computed_unknown_birth_time"
    )
    assert response["saved_paths"] == {
        "astrology": "users/uid-1/astrology/chinese_bazi",
        "results": "users/uid-1/results/chinese_bazi",
    }
    assert saved[0][0] == "uid-1"
    assert saved[0][1]["input_hash"] == saved[0][2]["input_hash"]
    assert saved[0][3] is None


def test_route_saves_matching_profile_in_the_authenticated_batch(monkeypatch):
    saved = []

    def save(uid, chart, snapshot, *, profile_data=None):
        saved.append((uid, profile_data))
        return True

    monkeypatch.setattr(bazi_route, "save_bazi", save)
    response = bazi_route.generate_bazi_v1(
        _request(profile=_profile()),
        "uid-1",
    )

    assert response["success"] is True
    assert saved == [
        (
            "uid-1",
            {
                "name": "Test User",
                "gender": "male",
                "birthDate": "1990-05-12",
                "birthTime": "15:30",
                "birthPlace": "Bangkok",
                "latitude": 13.7563,
                "longitude": 100.5018,
                "timezone": "Asia/Bangkok",
            },
        )
    ]


def test_route_rejects_profile_that_disagrees_with_calculation_input(monkeypatch):
    mismatched = _profile()
    mismatched.birth_date = "1991-01-01"

    with pytest.raises(HTTPException) as error:
        bazi_route.generate_bazi_v1(
            _request(profile=mismatched),
            "uid-1",
        )

    assert error.value.status_code == 400
    assert error.value.detail["code"] == "PROFILE_INPUT_MISMATCH"


def test_legacy_route_remains_available_for_released_clients(monkeypatch):
    saved = []

    def save(uid, chart, snapshot, *, profile_data=None):
        saved.append(uid)
        return True

    monkeypatch.setattr(bazi_route, "save_bazi", save)
    response = bazi_route.generate_bazi_legacy(
        _request(uid="legacy-user"), "legacy-user"
    )

    assert response["success"] is True
    assert saved == ["legacy-user"]
