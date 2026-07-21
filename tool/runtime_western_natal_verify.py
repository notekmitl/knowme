"""Runtime verification: Profile setup vs Western Natal pipeline. Run from repo root."""
import json
import os
import sys
import time
import urllib.request
from datetime import datetime, timezone

# Run with backend venv (cwd must be backend/ for service account path)
BACKEND_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend"))
os.chdir(BACKEND_DIR)
sys.path.insert(0, BACKEND_DIR)

from app.services.firebase_service import db  # noqa: E402

API_BASE = "http://127.0.0.1:8000"
TEST_UID = f"runtime-verify-{int(time.time())}"


def http_post_generate_chart(uid: str, birth_date: str, birth_time: str, lat: float, lng: float):
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
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.status, json.loads(resp.read().decode())


def get_western_natal(uid: str):
    doc = (
        db.collection("users")
        .document(uid)
        .collection("astrology")
        .document("western_natal")
        .get()
    )
    return doc.exists, doc.to_dict() if doc.exists else None


def get_results_astrology(uid: str):
    doc = (
        db.collection("users")
        .document(uid)
        .collection("results")
        .document("astrology")
        .get()
    )
    return doc.exists, doc.to_dict() if doc.exists else None


def simulate_profile_setup_save(uid: str):
    """Mirrors ProfileSetupPage.saveProfile Firestore write only."""
    profile = {
        "name": "Runtime Verify User",
        "gender": "male",
        "birthDate": "1992-08-20T00:00:00.000",
        "birthTime": "9:30",
        "birthPlace": "Bangkok, Thailand",
        "latitude": 13.7563,
        "longitude": 100.5018,
        "timezone": "Asia/Bangkok",
    }
    db.collection("users").document(uid).collection("profile").document("main").set(profile)
    return profile


def mirror_results_astrology(uid: str, chart: dict):
    """Minimal mirror matching fusion_astrology_mirror big3 element/modality."""
    big3 = chart.get("big3") or {}
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
    for k in ("sun", "moon", "rising"):
        raw = big3.get(k)
        if isinstance(raw, str) and raw in sign_meta:
            placements.append(raw)
    elem = {"fire": 0, "earth": 0, "air": 0, "water": 0}
    mod = {"cardinal": 0, "fixed": 0, "mutable": 0}
    for s in placements:
        e, m = sign_meta[s]
        elem[e] += 1
        mod[m] += 1
    payload = {
        "big3": big3,
        "planets": chart.get("planets") or {},
        "insight": {},
        "overall_summary": {},
        "element_summary": elem,
        "modality_summary": mod,
        "mirrored_from": "astrology/western_natal",
        "mirrored_at": datetime.now(timezone.utc),
    }
    db.collection("users").document(uid).collection("results").document("astrology").set(
        payload, merge=True
    )


def main():
    log = []
    birth_date_api = "1992-08-20"
    birth_time_api = "09:30"
    lat, lng = 13.7563, 100.5018

    log.append(f"TEST_UID={TEST_UID}")

    # --- Phase 1: Simulate new user Save Profile (ProfileSetupPage only) ---
    profile = simulate_profile_setup_save(TEST_UID)
    log.append("PHASE1: profile/main written (ProfileSetupPage equivalent)")

    exists_w, data_w = get_western_natal(TEST_UID)
    exists_r, data_r = get_results_astrology(TEST_UID)
    log.append(f"PHASE1_AFTER_SAVE: western_natal exists={exists_w}")
    log.append(f"PHASE1_AFTER_SAVE: results/astrology exists={exists_r}")

    # --- Phase 1b: Post-fix ProfileSetup (profile + generateChart pipeline) ---
    uid_post = f"{TEST_UID}-postfix"
    profile2 = simulate_profile_setup_save(uid_post)
    log.append(f"PHASE1B: profile/main written uid={uid_post}")
    status_b, body_b = http_post_generate_chart(
        uid_post,
        birth_date_api,
        birth_time_api,
        lat,
        lng,
    )
    log.append(f"PHASE1B: generateChart API status={status_b} success={body_b.get('success')}")
    if body_b.get("chart"):
        mirror_results_astrology(uid_post, body_b["chart"])
        log.append("PHASE1B: FusionAstrologyMirror equivalent executed")
    w_b, _ = get_western_natal(uid_post)
    r_b, r_data_b = get_results_astrology(uid_post)
    log.append(f"PHASE1B_AFTER_PIPELINE: western_natal exists={w_b}")
    log.append(f"PHASE1B_AFTER_PIPELINE: results/astrology exists={r_b}")
    if r_b and r_data_b:
        log.append(f"PHASE1B_FIELDS: mirrored_from={r_data_b.get('mirrored_from')}")
    load_b, load_data_b = get_western_natal(uid_post)
    log.append(f"PHASE1B_LOAD_CHART: exists={load_b} has_big3={bool((load_data_b or {}).get('big3'))}")

    # --- Phase 2: Explicit generate-chart (generateChart + API equivalent) ---
    status, body = http_post_generate_chart(TEST_UID, birth_date_api, birth_time_api, lat, lng)
    log.append(f"PHASE2: POST /generate-chart status={status} success={body.get('success')}")

    exists_w2, data_w2 = get_western_natal(TEST_UID)
    exists_r2, data_r2 = get_results_astrology(TEST_UID)
    log.append(f"PHASE2_AFTER_API: western_natal exists={exists_w2}")
    if exists_w2 and data_w2:
        log.append(f"PHASE2_FIELDS: big3={list((data_w2.get('big3') or {}).keys())}")
        log.append(f"PHASE2_FIELDS: planets={list((data_w2.get('planets') or {}).keys())}")
        log.append(f"PHASE2_HAS: houses={'houses' in data_w2} aspects={'aspects' in data_w2}")

    log.append(f"PHASE2_AFTER_API: results/astrology exists={exists_r2} (before Flutter mirror)")

    # --- Phase 3: Simulate Flutter generateChart mirror step ---
    if exists_w2 and data_w2:
        mirror_results_astrology(TEST_UID, data_w2)
        log.append("PHASE3: FusionAstrologyMirror equivalent executed")
    exists_r3, data_r3 = get_results_astrology(TEST_UID)
    log.append(f"PHASE3_AFTER_MIRROR: results/astrology exists={exists_r3}")
    if exists_r3 and data_r3:
        log.append(f"PHASE3_FIELDS: mirrored_from={data_r3.get('mirrored_from')}")

    # --- Phase 4: Reload simulation (loadChart reads western_natal again) ---
    exists_w4, data_w4 = get_western_natal(TEST_UID)
    log.append(f"PHASE4_RELOAD: western_natal exists={exists_w4}")
    if exists_w4 and data_w4:
        big3 = data_w4.get("big3") or {}
        log.append(f"PHASE4_RELOAD: sun={big3.get('sun')} moon={big3.get('moon')} rising={big3.get('rising')}")

    # --- Cleanup optional ---
    # db.collection("users").document(TEST_UID).delete()

    for line in log:
        print(line)

    # Exit codes for automation
    phase1_ok_no_chart = not exists_w
    phase2_ok_chart = exists_w2
    print("---SUMMARY---")
    print(f"auto_after_profile_only_creates_chart={not phase1_ok_no_chart}")
    print(f"api_creates_western_natal={phase2_ok_chart}")
    print(f"mirror_needed_for_results={exists_r3}")


if __name__ == "__main__":
    main()
