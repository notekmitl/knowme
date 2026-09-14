from datetime import datetime


def save_chart(
    uid,
    chart_data
):
    # Firestore must not initialize merely because an API route is imported.
    # This keeps calculation/auth unit tests offline and defers credentials to
    # the actual persistence call.
    from app.services.firebase_service import db

    user_ref = db.collection(
        "users"
    ).document(uid)

    user_ref.set({
        "updatedAt": datetime.utcnow()
    }, merge=True)

    chart_ref = user_ref.collection(
        "astrology"
    ).document("western_natal")

    chart_ref.set(chart_data)

    return True
