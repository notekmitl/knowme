"""Edit Profile V1 manual E2E verification (Playwright + Firestore)."""
import json
import os
import sys
import time
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parents[1] / "backend"
os.chdir(BACKEND_DIR)
sys.path.insert(0, str(BACKEND_DIR))

from firebase_admin import auth  # noqa: E402
from app.services.firebase_service import db  # noqa: E402

from playwright.sync_api import sync_playwright

APP_URL = "http://localhost:7358"
PASSWORD = "E2eTestPass123!"
OUT = Path(__file__).resolve().parents[1] / ".e2e_verify_output" / "edit_profile"
OUT.mkdir(parents=True, exist_ok=True)

API_BASE = "127.0.0.1:8000"


def create_user(email: str) -> str:
    try:
        u = auth.create_user(email=email, password=PASSWORD, display_name="E2E Edit Profile")
        return u.uid
    except Exception:
        return auth.get_user_by_email(email).uid


def seed_profile(uid: str, name: str = "E2E Original Name") -> None:
    db.collection("users").document(uid).collection("profile").document("main").set(
        {
            "name": name,
            "gender": "male",
            "birthDate": "1990-05-12T00:00:00.000",
            "birthTime": "15:30",
            "birthPlace": "Bangkok, Thailand",
            "latitude": 13.7563,
            "longitude": 100.5018,
            "timezone": "Asia/Bangkok",
        }
    )


def seed_charts_via_api(uid: str) -> None:
    import urllib.request

    def post(path, payload):
        req = urllib.request.Request(
            f"http://{API_BASE}{path}",
            data=json.dumps(payload).encode(),
            headers={"Content-Type": "application/json", "Origin": APP_URL},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=120) as resp:
            return resp.status

    post(
        "/generate-chart",
        {
            "uid": uid,
            "birth_date": "1990-05-12",
            "birth_time": "15:30",
            "latitude": 13.7563,
            "longitude": 100.5018,
        },
    )
    post(
        "/generate-bazi",
        {
            "uid": uid,
            "birth_date": "1990-05-12",
            "birth_time": "15:30",
            "timezone": "Asia/Bangkok",
            "latitude": 13.7563,
            "longitude": 100.5018,
        },
    )


def get_profile(uid: str):
    doc = db.collection("users").document(uid).collection("profile").document("main").get()
    return doc.to_dict() if doc.exists else None


def has_doc(uid: str, *path_parts: str) -> bool:
    ref = db.collection("users").document(uid)
    for p in path_parts[:-1]:
        ref = ref.collection(p).document(path_parts[path_parts.index(p) + 1]) if False else ref  # noqa
    # simpler
    if path_parts[0] == "astrology":
        doc = (
            db.collection("users")
            .document(uid)
            .collection("astrology")
            .document(path_parts[1])
            .get()
        )
        return doc.exists
    return False


def chart_exists(uid: str, doc_id: str) -> bool:
    return (
        db.collection("users")
        .document(uid)
        .collection("astrology")
        .document(doc_id)
        .get()
        .exists
    )


def login(page, email: str) -> None:
    page.goto(APP_URL, wait_until="domcontentloaded", timeout=120000)
    time.sleep(5)
    page.mouse.click(640, 360)
    page.keyboard.type(email, delay=8)
    page.mouse.click(640, 430)
    page.keyboard.type(PASSWORD, delay=8)
    page.mouse.click(640, 500)
    time.sleep(8)


def open_edit_profile(page) -> None:
    # AppBar: Edit Profile left of Logout
    for x, y in [(980, 28), (1020, 28), (900, 28), (950, 28)]:
        page.mouse.click(x, y)
        time.sleep(1.5)
        if "Edit Profile" in page.content() or page.url != APP_URL:
            pass
    # title bar shows Edit Profile when on page
    page.screenshot(path=str(OUT / "edit_profile_open_attempt.png"), full_page=True)


def click_save(page) -> None:
    page.mouse.click(640, 780)
    time.sleep(0.5)
    page.mouse.click(640, 750)
    time.sleep(0.5)
    page.mouse.click(640, 720)


def filter_api(requests: list[str]) -> dict:
    chart = [r for r in requests if "generate-chart" in r]
    bazi = [r for r in requests if "generate-bazi" in r]
    return {"generate_chart": chart, "generate_bazi": bazi, "all": requests}


def run_case_a(page, uid: str, email: str) -> dict:
    api_log: list[str] = []

    def on_req(req):
        if API_BASE in req.url:
            api_log.append(f"{req.method} {req.url}")

    page.on("request", on_req)
    login(page, email)
    page.screenshot(path=str(OUT / "case_a_home.png"), full_page=True)

    page.mouse.click(950, 28)
    time.sleep(4)
    page.screenshot(path=str(OUT / "case_a_edit_loaded.png"), full_page=True)

    # name field ~ y=360
    page.mouse.click(640, 360)
    time.sleep(0.3)
    page.keyboard.press("Control+A")
    page.keyboard.type("E2E Name Only Updated", delay=8)

    api_log.clear()
    click_save(page)
    time.sleep(8)
    page.screenshot(path=str(OUT / "case_a_after_save.png"), full_page=True)

    profile = get_profile(uid)
    apis = filter_api(api_log)
    return {
        "case": "A_name_only",
        "profile_name": profile.get("name") if profile else None,
        "name_updated": profile.get("name") == "E2E Name Only Updated" if profile else False,
        "api": apis,
        "no_chart_api": len(apis["generate_chart"]) == 0 and len(apis["generate_bazi"]) == 0,
    }


def run_case_b(page, uid: str, email: str) -> dict:
    api_log: list[str] = []

    def on_req(req):
        if API_BASE in req.url:
            api_log.append(f"{req.method} {req.url}")

    page.on("request", on_req)
    login(page, email)
    page.mouse.click(950, 28)
    time.sleep(4)

    # birth time row ~ y=570
    page.mouse.click(640, 570)
    time.sleep(2)
    page.screenshot(path=str(OUT / "case_b_time_picker.png"), full_page=True)
    # try OK / confirm on time picker (center-bottom of dialog)
    page.mouse.click(640, 520)
    time.sleep(0.5)
    page.keyboard.press("Enter")
    time.sleep(1)

    api_log.clear()
    click_save(page)
    time.sleep(15)
    page.screenshot(path=str(OUT / "case_b_after_save.png"), full_page=True)

    profile = get_profile(uid)
    apis = filter_api(api_log)
    return {
        "case": "B_birth_time",
        "profile_birth_time": profile.get("birthTime") if profile else None,
        "api": apis,
        "chart_api_called": len(apis["generate_chart"]) > 0,
        "bazi_api_called": len(apis["generate_bazi"]) > 0,
    }


def run_case_c(uid: str, email: str) -> dict:
    # profile only, no chinese_bazi
    seed_profile(uid, "E2E No Bazi User")
    western_exists = chart_exists(uid, "western_natal")
    if western_exists:
        db.collection("users").document(uid).collection("astrology").document("western_natal").delete()
    if chart_exists(uid, "chinese_bazi"):
        db.collection("users").document(uid).collection("astrology").document("chinese_bazi").delete()

    api_log: list[str] = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1280, "height": 900})

        def on_req(req):
            if API_BASE in req.url:
                api_log.append(f"{req.method} {req.url}")

        page.on("request", on_req)
        login(page, email)
        page.mouse.click(950, 28)
        time.sleep(4)
        page.mouse.click(640, 570)
        time.sleep(2)
        page.keyboard.press("Enter")
        time.sleep(1)
        api_log.clear()
        click_save(page)
        time.sleep(15)
        page.screenshot(path=str(OUT / "case_c_after_save.png"), full_page=True)
        browser.close()

    bazi_exists = chart_exists(uid, "chinese_bazi")
    apis = filter_api(api_log)
    return {
        "case": "C_no_prior_bazi",
        "chinese_bazi_created": bazi_exists,
        "api": apis,
    }


def run_regression(page, email: str) -> dict:
    login(page, email)
    # Western QA ~ y=470 scan
    for y in range(440, 520, 15):
        page.mouse.click(640, y)
        time.sleep(0.3)
    time.sleep(5)
    page.screenshot(path=str(OUT / "regression_western.png"), full_page=True)
    page.mouse.click(24, 52)
    time.sleep(2)
    for y in range(550, 700, 15):
        page.mouse.click(640, y)
        time.sleep(0.3)
    time.sleep(5)
    page.screenshot(path=str(OUT / "regression_bazi.png"), full_page=True)
    return {"western_screenshot": str(OUT / "regression_western.png"), "bazi_screenshot": str(OUT / "regression_bazi.png")}


def main():
    ts = int(time.time())
    email_ab = f"e2e.edit.profile.{ts}@knowme.test"
    uid_ab = create_user(email_ab)
    seed_profile(uid_ab)
    seed_charts_via_api(uid_ab)

    email_c = f"e2e.edit.profile.nobazi.{ts}@knowme.test"
    uid_c = create_user(email_c)

    results = {"environment": {"app": APP_URL, "api": f"http://{API_BASE}"}, "uids": {"ab": uid_ab, "c": uid_c}}

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1280, "height": 900})
        results["case_a"] = run_case_a(page, uid_ab, email_ab)
        browser.close()

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1280, "height": 900})
        # reset name for case b user still has updated name from A - birth time test on same user
        results["case_b"] = run_case_b(page, uid_ab, email_ab)
        browser.close()

    results["case_c"] = run_case_c(uid_c, email_c)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1280, "height": 900})
        results["regression"] = run_regression(page, email_ab)
        browser.close()

    # preload check from case_a screenshot + firestore
    preload = get_profile(uid_ab)
    results["preload_firestore"] = preload

    out_path = OUT / "results.json"
    out_path.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(results, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
