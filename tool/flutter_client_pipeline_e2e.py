"""Simulates Flutter client: Auth sign-in + profile save + generateChart HTTP + Firestore reads."""
import json
import os
import sys
import time
import urllib.parse
import urllib.request

BACKEND_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend"))
os.chdir(BACKEND_DIR)
sys.path.insert(0, BACKEND_DIR)

from app.services import firebase_service  # noqa: E402, F401
from app.services.firebase_service import db  # noqa: E402

# Firebase Web API key from lib (same project as app)
# lib/firebase_options.dart — web
API_KEY = os.environ.get(
    "FIREBASE_WEB_API_KEY", "AIzaSyDKHuN35ud0E3f_CcnupFjqjr4j9RCVTrQ"
)

FLUTTER_ORIGIN = "http://localhost:7357"
ASTRO_API = "http://127.0.0.1:8000"


def firebase_sign_in(email: str, password: str) -> dict:
    url = (
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword"
        f"?key={API_KEY}"
    )
    payload = {"email": email, "password": password, "returnSecureToken": True}
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode())


def cors_generate_chart(uid: str, birth_date: str, birth_time: str, lat: float, lng: float):
    payload = {
        "uid": uid,
        "birth_date": birth_date,
        "birth_time": birth_time,
        "latitude": lat,
        "longitude": lng,
    }
    req = urllib.request.Request(
        f"{ASTRO_API}/generate-chart",
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json", "Origin": FLUTTER_ORIGIN},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        return resp.status, dict(resp.headers), json.loads(resp.read().decode())


def get_chart(uid: str):
    doc = (
        db.collection("users")
        .document(uid)
        .collection("astrology")
        .document("western_natal")
        .get()
    )
    return doc.exists, doc.to_dict() if doc.exists else None


def get_results(uid: str):
    doc = (
        db.collection("users")
        .document(uid)
        .collection("results")
        .document("astrology")
        .get()
    )
    return doc.exists, doc.to_dict() if doc.exists else None


def main():
    if len(sys.argv) < 3:
        print("Usage: flutter_client_pipeline_e2e.py EMAIL PASSWORD")
        sys.exit(2)
    email, password = sys.argv[1], sys.argv[2]

    auth = firebase_sign_in(email, password)
    uid = auth["localId"]
    print(f"AUTH_OK uid={uid}")

    birth_date_iso = "1992-08-20T00:00:00.000"
    birth_time = "09:30"
    lat, lng = 13.7563, 100.5018

    db.collection("users").document(uid).collection("profile").document("main").set(
        {
            "name": "Flutter Web E2E",
            "gender": "male",
            "birthDate": birth_date_iso,
            "birthTime": birth_time,
            "birthPlace": "Bangkok, Thailand",
            "latitude": lat,
            "longitude": lng,
            "timezone": "Asia/Bangkok",
        }
    )
    print("PROFILE_SAVE_OK")

    status, headers, body = cors_generate_chart(uid, "1992-08-20", birth_time, lat, lng)
    acao = headers.get("access-control-allow-origin") or headers.get("Access-Control-Allow-Origin")
    print(f"GENERATE_CHART status={status} ACAO={acao} success={body.get('success')}")

    w_ok, w = get_chart(uid)
    print(f"WESTERN_NATAL exists={w_ok}")
    if w:
        print(f"  big3={w.get('big3')}")
        print(f"  houses={len(w.get('houses') or [])} aspects={len(w.get('aspects') or [])}")

    r_ok, r = get_results(uid)
    print(f"RESULTS_ASTROLOGY exists={r_ok} (after Flutter mirror only)")

    # Reload simulation
    w2_ok, w2 = get_chart(uid)
    print(f"RELOAD_CHART exists={w2_ok} big3={((w2 or {}).get('big3'))}")

    print("---UI_CHECKLIST---")
    print("Open http://localhost:7357, login with same credentials, Home debug -> Astrology Result")
    print(f"EMAIL={email}")
    print(f"PASSWORD={password}")


if __name__ == "__main__":
    main()
