"""Persist BaZi chart to Firestore — separate paths from Western Natal."""

from datetime import datetime

def save_bazi(
    uid: str,
    chart_data: dict,
    results_snapshot: dict,
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
    batch.set(
        user_ref.collection("astrology").document("chinese_bazi"),
        chart_data,
    )
    batch.set(
        user_ref.collection("results").document("chinese_bazi"),
        results_snapshot,
    )
    batch.commit()

    return True
