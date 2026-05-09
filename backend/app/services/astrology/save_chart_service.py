from datetime import datetime

from app.services.firebase_service import db


def save_chart(
    uid,
    chart_data
):

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