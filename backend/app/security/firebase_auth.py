"""Firebase ID-token verification for UID-bound API operations."""

from dataclasses import dataclass
import time

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from firebase_admin import auth

_bearer = HTTPBearer(auto_error=False)


@dataclass(frozen=True)
class FirebaseAuthTiming:
    uid: str
    duration_ms: float


def verify_firebase_user(
    credentials: HTTPAuthorizationCredentials | None,
) -> str:
    """Return the verified Firebase UID or raise a non-disclosing 401."""
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise _unauthorized()

    token = credentials.credentials.strip()
    if not token:
        raise _unauthorized()

    try:
        decoded = auth.verify_id_token(token, check_revoked=True)
    except Exception as exc:
        raise _unauthorized() from exc

    uid = str(decoded.get("uid") or decoded.get("sub") or "").strip()
    if not uid:
        raise _unauthorized()
    return uid


def current_firebase_uid(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
) -> str:
    """FastAPI dependency wrapper around [verify_firebase_user]."""
    return verify_firebase_user(credentials)


def current_firebase_user_with_timing(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
) -> FirebaseAuthTiming:
    """Verify the caller and retain only non-sensitive elapsed-time metadata."""
    started = time.perf_counter()
    uid = verify_firebase_user(credentials)
    return FirebaseAuthTiming(
        uid=uid,
        duration_ms=(time.perf_counter() - started) * 1000,
    )


def _unauthorized() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail={
            "code": "AUTH_REQUIRED",
            "message": "A valid Firebase ID token is required",
        },
        headers={"WWW-Authenticate": "Bearer"},
    )
