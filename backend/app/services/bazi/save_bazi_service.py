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

    user_ref.set(
        {"updatedAt": datetime.utcnow()},
        merge=True,
    )

    user_ref.collection("astrology").document("chinese_bazi").set(chart_data)
    user_ref.collection("results").document("chinese_bazi").set(results_snapshot)

    return True
