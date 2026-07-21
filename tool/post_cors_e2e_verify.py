"""Post-CORS E2E: profile save + browser-like POST + Firestore + loadChart fields."""
import json
import os
import sys
import time
import urllib.request
from datetime import datetime, timezone

BACKEND_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend"))
os.chdir(BACKEND_DIR)
sys.path.insert(0, BACKEND_DIR)

from app.services.firebase_service import db  # noqa: E402

API_BASE = "http://127.0.0.1:8000"
FLUTTER_ORIGIN = "http://localhost:7357"
TEST_UID = f"e2e-post-cors-{int(time.time())}"


def cors_post_generate_chart(uid: str, birth_date: str, birth_time: str, lat: float, lng: float):
    payload = {
        "uid": uid,
        "birth_date": birth_date,
        "birth_time": birth_time,
        "latitude": lat,
        "longitude": lng,
    }
    req = urllib.request.Request(
        f"{API_BASE}/generate-chart",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Origin": FLUTTER_ORIGIN,
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        headers = dict(resp.headers)
        body = json.loads(resp.read().decode())
        return resp.status, headers, body


def get_doc(path_parts):
    ref = db
    for p in path_parts[:-1]:
        ref = ref.collection(p[0]).document(p[1]) if isinstance(p, tuple) else ref
    # simpler
    doc = (
        db.collection("users")
        .document(path_parts[0])
        .collection(path_parts[1])
        .document(path_parts[2])
        .get()
    )
    return doc.exists, doc.to_dict() if doc.exists else None


def main():
    uid = TEST_UID
    birth_date = "1992-08-20"
    birth_time = "09:30"
    lat, lng = 13.7563, 100.5018

    print(f"TEST_UID={uid}")
    print(f"FLUTTER_ORIGIN={FLUTTER_ORIGIN}")

    # Step 1: profile/main (ProfileSetupPage)
    db.collection("users").document(uid).collection("profile").document("main").set(
        {
            "name": "E2E Post CORS",
            "gender": "male",
            "birthDate": "1992-08-20T00:00:00.000",
            "birthTime": birth_time,
            "birthPlace": "Bangkok, Thailand",
            "latitude": lat,
            "longitude": lng,
            "timezone": "Asia/Bangkok",
        }
    )
    print("STEP profile/main: OK")

    w0, _ = get_doc((uid, "astrology", "western_natal"))
    print(f"STEP before API western_natal exists={w0}")

    # Step 2: POST like Flutter Web (with Origin)
    status, headers, body = cors_post_generate_chart(uid, birth_date, birth_time, lat, lng)
    acao = headers.get("access-control-allow-origin") or headers.get("Access-Control-Allow-Origin")
    print(f"STEP POST /generate-chart status={status} ACAO={acao} success={body.get('success')}")

    w1, wdata = get_doc((uid, "astrology", "western_natal"))
    print(f"STEP western_natal exists={w1}")
    if wdata:
        print(f"  big3={wdata.get('big3')}")
        print(f"  planets_keys={list((wdata.get('planets') or {}).keys())[:12]}")
        print(f"  has_houses={'houses' in wdata} has_aspects={'aspects' in wdata}")
        if wdata.get("houses"):
            print(f"  houses_count={len(wdata['houses'])}")
        if wdata.get("aspects"):
            print(f"  aspects_count={len(wdata['aspects'])}")

    r1, rdata = get_doc((uid, "results", "astrology"))
    print(f"STEP results/astrology exists={r1} (mirror runs in Flutter only)")
    if rdata:
        print(f"  mirrored_from={rdata.get('mirrored_from')}")
        print(f"  element_summary={rdata.get('element_summary')}")

    # Step 3: simulate FusionAstrologyMirror (Flutter generateChart tail)
    if wdata:
        from app.services.astrology.save_chart_service import save_chart  # noqa: F401

        big3 = wdata.get("big3") or {}
        placements = []
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
                "planets": wdata.get("planets") or {},
                "insight": {},
                "overall_summary": {},
                "element_summary": elem,
                "modality_summary": mod,
                "mirrored_from": "astrology/western_natal",
                "mirrored_at": datetime.now(timezone.utc),
            },
            merge=True,
        )
        print("STEP mirror simulated (Flutter FusionAstrologyMirror)")

    r2, rdata2 = get_doc((uid, "results", "astrology"))
    print(f"STEP results/astrology after mirror exists={r2}")
    if rdata2:
        print(f"  big3={rdata2.get('big3')}")
        print(f"  element_summary={rdata2.get('element_summary')}")

    # Step 4: reload loadChart
    w3, wdata3 = get_doc((uid, "astrology", "western_natal"))
    print(f"STEP reload western_natal exists={w3}")
    if wdata3:
        b = wdata3.get("big3") or {}
        print(f"  sun={b.get('sun')} moon={b.get('moon')} rising={b.get('rising')}")
        print(f"  has_overall_summary={bool(wdata3.get('overall_summary'))}")
        print(f"  has_insight={bool(wdata3.get('insight'))}")

    print("---PASS_CRITERIA---")
    print(f"cors_acao_ok={acao == FLUTTER_ORIGIN}")
    print(f"api_ok={status == 200 and body.get('success')}")
    print(f"western_natal_ok={w3}")
    print(f"big3_nonempty={bool((wdata3 or {}).get('big3'))}")


if __name__ == "__main__":
    main()
