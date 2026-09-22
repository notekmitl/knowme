import time

from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, ConfigDict, Field

from app.security.firebase_auth import (
    FirebaseAuthTiming,
    current_firebase_user_with_timing,
)

from app.services.overall_summary_service import (
    generate_overall_summary,
)

from app.services.astrology.builders.chart_builder import (
    build_chart,
)

from app.services.astrology.save_chart_service import (
    build_results_snapshot,
    save_chart,
)
from app.services.bazi.utils.datetime_parser import InvalidBirthDatetime

router = APIRouter()


class WesternCanonicalProfileRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    name: str
    gender: str
    birth_date: str = Field(alias="birthDate")
    birth_time: str = Field(alias="birthTime")
    birth_place: str = Field(alias="birthPlace")
    latitude: float
    longitude: float
    timezone: str

    def firestore_payload(self) -> dict:
        return self.model_dump(by_alias=True)


class GenerateChartRequest(BaseModel):
    uid: str
    birth_date: str
    birth_time: str
    timezone: str = "Asia/Bangkok"
    latitude: float
    longitude: float
    profile: WesternCanonicalProfileRequest | None = None


@router.post("/generate-chart", deprecated=True)
def generate_chart_legacy(
    request: GenerateChartRequest,
    authenticated_uid: FirebaseAuthTiming = Depends(
        current_firebase_user_with_timing
    ),
    raw_request: Request = None,
):
    """Authenticated compatibility alias for the versioned endpoint."""
    return generate_chart_v1(request, authenticated_uid, raw_request)


@router.post("/v1/generate-chart")
def generate_chart_v1(
    request: GenerateChartRequest,
    authenticated_uid: FirebaseAuthTiming = Depends(
        current_firebase_user_with_timing
    ),
    raw_request: Request = None,
):
    auth_timing = _auth_timing(authenticated_uid)
    verified_uid = auth_timing.uid
    if not request.uid.strip():
        raise HTTPException(
            status_code=400,
            detail={"code": "MISSING_UID", "message": "uid is required"},
        )
    if request.uid.strip() != verified_uid:
        raise HTTPException(
            status_code=403,
            detail={
                "code": "UID_MISMATCH",
                "message": "Authenticated user cannot write another user's chart",
            },
        )
    timings = {"authentication_ms": auth_timing.duration_ms}
    response = _generate_chart(
        request,
        write_uid=verified_uid,
        timings=timings,
    )
    timings["_handler_completed"] = time.perf_counter()
    if raw_request is not None:
        raw_request.state.western_timing = timings
    return response


def _generate_chart(
    request: GenerateChartRequest,
    *,
    write_uid: str,
    timings: dict[str, float] | None = None,
):
    timings = timings if timings is not None else {}
    input_started = time.perf_counter()
    if not write_uid:
        raise HTTPException(
            status_code=400,
            detail={"code": "MISSING_UID", "message": "uid is required"},
        )

    if not request.birth_date.strip() or not request.birth_time.strip():
        raise HTTPException(
            status_code=400,
            detail={
                "code": "MISSING_BIRTH_DATETIME",
                "message": "birth_date and birth_time are required",
            },
        )

    profile_data = _validated_profile(request)
    timings["profile_input_loading_ms"] = (
        time.perf_counter() - input_started
    ) * 1000

    try:
        chart = build_chart(
            request.birth_date,
            request.birth_time,
            request.latitude,
            request.longitude,
            request.timezone,
            phase_timings=timings,
        )
    except (InvalidBirthDatetime, ValueError) as exc:
        raise HTTPException(
            status_code=400,
            detail={"code": "INVALID_BIRTH_INPUT", "message": str(exc)},
        ) from exc

    response_assembly_started = time.perf_counter()
    overall_summary = generate_overall_summary(
        chart,
    )

    reader_overview = (chart.get("reader") or {}).get("overview")
    chart["overall_summary"] = (
        reader_overview if isinstance(reader_overview, dict) else overall_summary
    )

    results_snapshot = build_results_snapshot(chart)
    timings["response_assembly_ms"] = (
        time.perf_counter() - response_assembly_started
    ) * 1000

    save_started = time.perf_counter()
    try:
        save_chart(
            write_uid,
            chart,
            results_snapshot,
            profile_data=profile_data,
        )
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail={"code": "FIRESTORE_SAVE_FAILED", "message": str(exc)},
        ) from exc
    timings["firestore_save_ms"] = (time.perf_counter() - save_started) * 1000

    return {
        "success": True,
        "version": chart["version"],
        "chart": chart,
        "saved_paths": {
            "astrology": f"users/{write_uid}/astrology/western_natal",
            "results": f"users/{write_uid}/results/astrology",
        },
    }


def _auth_timing(value) -> FirebaseAuthTiming:
    if isinstance(value, FirebaseAuthTiming):
        return value
    return FirebaseAuthTiming(uid=str(value), duration_ms=0.0)


def _validated_profile(request: GenerateChartRequest) -> dict | None:
    if request.profile is None:
        return None

    profile = request.profile
    expected = {
        "birthDate": request.birth_date.strip(),
        "birthTime": request.birth_time.strip(),
        "latitude": request.latitude,
        "longitude": request.longitude,
        "timezone": request.timezone.strip(),
    }
    actual = {
        "birthDate": profile.birth_date.strip(),
        "birthTime": profile.birth_time.strip(),
        "latitude": profile.latitude,
        "longitude": profile.longitude,
        "timezone": profile.timezone.strip(),
    }
    if actual != expected:
        raise HTTPException(
            status_code=400,
            detail={
                "code": "PROFILE_INPUT_MISMATCH",
                "message": "profile birth fields must match Western calculation input",
            },
        )
    return profile.firestore_payload()
