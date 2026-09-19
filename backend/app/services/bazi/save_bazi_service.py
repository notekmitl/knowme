"""Persist BaZi chart to Firestore — separate paths from Western Natal."""

from datetime import datetime

def save_bazi(
    uid: str,
    chart_data: dict,
    results_snapshot: dict,
    *,
    profile_data: dict | None = None,
) -> bool:
    # Import lazily so pure calculation/auth tests never initialize Firestore.
    from app.services.firebase_service import db

    user_ref = db.collection("users").document(uid)
    batch = db.batch()
    batch.set(
        user_ref,
        {"updatedAt": datetime.utcnow()},
        merge=True,
    )
    if profile_data is not None:
        batch.set(
            user_ref.collection("profile").document("main"),
            profile_data,
        )
    batch.set(
        user_ref.collection("astrology").document("chinese_bazi"),
        chart_data,
    )
    batch.set(
        user_ref.collection("results").document("chinese_bazi"),
        results_snapshot,
    )
    batch.delete(
        user_ref.collection("results").document("astrology_fusion"),
    )
    batch.commit()

    return True
