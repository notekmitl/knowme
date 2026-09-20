"""Atomic persistence for Western Natal V2 and its Fusion snapshot."""

from datetime import datetime, timezone

from app.services.astrology.analysis import SIGN_META


def build_results_snapshot(chart_data: dict) -> dict:
    big3 = chart_data.get("big3") or {}
    elements = {key: 0 for key in ("fire", "earth", "air", "water")}
    modalities = {key: 0 for key in ("cardinal", "fixed", "mutable")}
    for value in (big3.get("sun"), big3.get("moon"), big3.get("rising")):
        meta = SIGN_META.get(value)
        if meta is None:
            continue
        elements[meta[0]] += 1
        modalities[meta[1]] += 1

    return {
        "version": chart_data.get("version"),
        "contract_id": chart_data.get("contract_id"),
        "engine_version": chart_data.get("engine_version"),
        "input_hash": chart_data.get("input_hash"),
        "big3": big3,
        "planets": chart_data.get("planets") or {},
        "insight": chart_data.get("insight") or {},
        "overall_summary": chart_data.get("overall_summary") or {},
        "element_summary": elements,
        "modality_summary": modalities,
        "mirrored_from": "astrology/western_natal",
        "mirrored_at": datetime.now(timezone.utc),
    }


def save_chart(
    uid: str,
    chart_data: dict,
    results_snapshot: dict,
    *,
    profile_data: dict | None = None,
) -> bool:
    # Keep Firebase initialization outside pure calculation/auth imports.
    from app.services.firebase_service import db

    user_ref = db.collection("users").document(uid)
    batch = db.batch()
    batch.set(user_ref, {"updatedAt": datetime.now(timezone.utc)}, merge=True)
    if profile_data is not None:
        batch.set(
            user_ref.collection("profile").document("main"),
            profile_data,
        )
    batch.set(
        user_ref.collection("astrology").document("western_natal"),
        chart_data,
    )
    batch.set(
        user_ref.collection("results").document("astrology"),
        results_snapshot,
    )
    batch.delete(
        user_ref.collection("results").document("astrology_fusion"),
    )
    batch.commit()
    return True
