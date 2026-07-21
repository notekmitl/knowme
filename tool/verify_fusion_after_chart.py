"""Simulate FusionAstrologyMirror + FusionLoader read for E2E uid."""
import os
import sys
from datetime import datetime, timezone

BACKEND_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend"))
os.chdir(BACKEND_DIR)
sys.path.insert(0, BACKEND_DIR)

from app.services.firebase_service import db  # noqa: E402

UID = sys.argv[1] if len(sys.argv) > 1 else "6hMSm2JtAfVlzZMPQSnMkOxLmHq1"


def mirror(uid: str):
    doc = (
        db.collection("users")
        .document(uid)
        .collection("astrology")
        .document("western_natal")
        .get()
    )
    if not doc.exists:
        print("NO_WESTERN_NATAL")
        return False
    chart = doc.to_dict() or {}
    big3 = chart.get("big3") or {}
    sign_meta = {
        "Aries": ("fire", "cardinal"),
        "Taurus": ("earth", "fixed"),
        "Gemini": ("air", "mutable"),
        "Cancer": ("water", "cardinal"),
        "Leo": ("fire", "fixed"),
        "Virgo": ("earth", "mutable"),
        "Libra": ("air", "cardinal"),
        "Scorpio": ("water", "fixed"),
        "Sagittarius": ("fire", "mutable"),
        "Capricorn": ("earth", "cardinal"),
        "Aquarius": ("air", "fixed"),
        "Pisces": ("water", "mutable"),
    }
    elem = {"fire": 0, "earth": 0, "air": 0, "water": 0}
    mod = {"cardinal": 0, "fixed": 0, "mutable": 0}
    for k in ("sun", "moon", "rising"):
        s = big3.get(k)
        if isinstance(s, str) and s in sign_meta:
            e, m = sign_meta[s]
            elem[e] += 1
            mod[m] += 1
    db.collection("users").document(uid).collection("results").document("astrology").set(
        {
            "big3": big3,
            "planets": chart.get("planets") or {},
            "insight": {},
            "overall_summary": {},
            "element_summary": elem,
            "modality_summary": mod,
            "mirrored_from": "astrology/western_natal",
            "mirrored_at": datetime.now(timezone.utc),
        },
        merge=True,
    )
    print("MIRROR_OK")
    return True


def fusion_load(uid: str):
    snap = (
        db.collection("users")
        .document(uid)
        .collection("results")
        .document("astrology")
        .get()
    )
    print(f"FUSION_ASTROLOGY exists={snap.exists}")
    if snap.exists:
        d = snap.to_dict() or {}
        print(f"  big3={d.get('big3')}")
        print(f"  element_summary={d.get('element_summary')}")
        print(f"  mirrored_from={d.get('mirrored_from')}")


if __name__ == "__main__":
    if mirror(UID):
        fusion_load(UID)
