"""Edit Profile V1 — Final Manual Smoke Verification (Playwright + Firestore)."""
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

for port in (7358, 7357):
    import urllib.request

    try:
        urllib.request.urlopen(f"http://localhost:{port}", timeout=3)
        APP_URL = f"http://localhost:{port}"
        break
    except Exception:
        continue
else:
    raise SystemExit("Flutter web not reachable on 7358 or 7357")

PASSWORD = "E2eTestPass123!"
OUT = Path(__file__).resolve().parents[1] / ".e2e_verify_output" / "edit_profile" / "final_smoke"
OUT.mkdir(parents=True, exist_ok=True)
API_HOST = "127.0.0.1:8000"

# Calibrated for 1280x900 viewport (from ui_preload.png)
EDIT_PROFILE_BTN = (1120, 28)
NAME_FIELD = (640, 198)
TIME_FIELD = (640, 455)
SAVE_BTN = (640, 703)
WESTERN_BTN = (640, 372)
BAZI_BTN = (640, 492)
BACK_BTN = (24, 52)


def create_user(email: str) -> str:
    try:
        return auth.create_user(email=email, password=PASSWORD).uid
    except Exception:
        return auth.get_user_by_email(email).uid


def seed_profile(uid: str) -> None:
    db.collection("users").document(uid).collection("profile").document("main").set(
        {
            "name": "Smoke Original Name",
            "gender": "male",
            "birthDate": "1990-05-12T00:00:00.000",
            "birthTime": "15:30",
            "birthPlace": "Bangkok, Thailand",
            "latitude": 13.7563,
            "longitude": 100.5018,
            "timezone": "Asia/Bangkok",
        }
    )


def seed_charts(uid: str) -> None:
    import urllib.request

    def post(path, payload):
        req = urllib.request.Request(
            f"http://{API_HOST}{path}",
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
    doc = (
        db.collection("users").document(uid).collection("profile").document("main").get()
    )
    return doc.to_dict() if doc.exists else None


def doc_exists(uid: str, collection: str, doc_id: str) -> bool:
    return (
        db.collection("users")
        .document(uid)
        .collection(collection)
        .document(doc_id)
        .get()
        .exists
    )


class ApiMonitor:
    def __init__(self):
        self.events: list[dict] = []

    def on_response(self, response):
        url = response.url
        if API_HOST not in url:
            return
        if "generate-chart" in url or "generate-bazi" in url:
            self.events.append(
                {
                    "url": url,
                    "status": response.status,
                    "method": response.request.method,
                }
            )

    def clear(self):
        self.events.clear()

    def chart_calls(self):
        return [e for e in self.events if "generate-chart" in e["url"]]

    def bazi_calls(self):
        return [e for e in self.events if "generate-bazi" in e["url"]]


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
    page.mouse.click(*EDIT_PROFILE_BTN)
    time.sleep(4)


def save_profile(page) -> None:
    page.mouse.click(*SAVE_BTN)
    time.sleep(10)


def change_name(page, new_name: str) -> None:
    page.mouse.click(*NAME_FIELD)
    time.sleep(0.4)
    page.keyboard.press("Control+A")
    time.sleep(0.1)
    page.keyboard.press("Backspace")
    time.sleep(0.1)
    page.keyboard.type(new_name, delay=10)


def change_birth_time(page) -> None:
    page.mouse.click(*TIME_FIELD)
    time.sleep(2)
    page.screenshot(path=str(OUT / "case2_time_picker.png"), full_page=True)
    # keyboard input mode icon (top-left of dialog) then type 09:00
    for kx, ky in [(520, 380), (480, 400), (560, 360)]:
        page.mouse.click(kx, ky)
        time.sleep(0.3)
    page.keyboard.type("0900", delay=80)
    time.sleep(0.5)
    # OK on time picker
    for ox, oy in [(720, 560), (680, 540), (640, 520), (700, 580)]:
        page.mouse.click(ox, oy)
        time.sleep(0.3)
    page.keyboard.press("Enter")
    time.sleep(1)


def is_edit_profile_page(page) -> bool:
    # After navigation, title area shows "Edit Profile" in semantics-less canvas;
    # rely on screenshot file size change or back navigation test
    return True


def is_western_page(page) -> bool:
    return False  # verified via screenshot visually


def main():
    ts = int(time.time())
    email = f"e2e.smoke.final.{ts}@knowme.test"
    uid = create_user(email)
    seed_profile(uid)
    seed_charts(uid)

    results = {
        "environment": {"app": APP_URL, "api": f"http://{API_HOST}", "email": email, "uid": uid},
        "cases": {},
    }

    monitor = ApiMonitor()

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1280, "height": 900})
        page.on("response", monitor.on_response)

        # --- Case 1 ---
        login(page, email)
        page.screenshot(path=str(OUT / "case1_home.png"), full_page=True)
        open_edit_profile(page)
        page.screenshot(path=str(OUT / "case1_edit_preload.png"), full_page=True)
        change_name(page, "Smoke Name Updated")
        page.screenshot(path=str(OUT / "case1_name_typed.png"), full_page=True)
        monitor.clear()
        save_profile(page)
        page.screenshot(path=str(OUT / "case1_after_save.png"), full_page=True)

        prof1 = get_profile(uid)
        case1 = {
            "profile_name": prof1.get("name") if prof1 else None,
            "name_updated": prof1 and prof1.get("name") == "Smoke Name Updated",
            "generate_chart_calls": monitor.chart_calls(),
            "generate_bazi_calls": monitor.bazi_calls(),
            "no_regen_api": len(monitor.chart_calls()) == 0 and len(monitor.bazi_calls()) == 0,
        }
        case1["pass"] = case1["name_updated"] and case1["no_regen_api"]
        results["cases"]["case1_name_only"] = case1

        # --- Case 2 (same session, back to edit) ---
        open_edit_profile(page)
        page.screenshot(path=str(OUT / "case2_edit_open.png"), full_page=True)
        monitor.clear()
        change_birth_time(page)
        page.screenshot(path=str(OUT / "case2_time_changed.png"), full_page=True)
        save_profile(page)
        page.screenshot(path=str(OUT / "case2_after_save.png"), full_page=True)

        prof2 = get_profile(uid)
        chart_calls = monitor.chart_calls()
        bazi_calls = monitor.bazi_calls()
        case2 = {
            "profile_birth_time": prof2.get("birthTime") if prof2 else None,
            "birth_time_updated": prof2 and prof2.get("birthTime") == "09:00",
            "generate_chart_calls": chart_calls,
            "generate_bazi_calls": bazi_calls,
            "chart_200": any(c["status"] == 200 for c in chart_calls),
            "bazi_200": any(c["status"] == 200 for c in bazi_calls),
            "western_natal_exists": doc_exists(uid, "astrology", "western_natal"),
            "chinese_bazi_exists": doc_exists(uid, "astrology", "chinese_bazi"),
        }
        case2["pass"] = (
            case2["birth_time_updated"]
            and case2["chart_200"]
            and case2["bazi_200"]
            and case2["western_natal_exists"]
            and case2["chinese_bazi_exists"]
        )
        results["cases"]["case2_birth_time"] = case2

        # --- Case 3 Western ---
        page.mouse.click(*BACK_BTN)
        time.sleep(2)
        page.mouse.click(*BACK_BTN)
        time.sleep(2)
        page.screenshot(path=str(OUT / "case3_home.png"), full_page=True)
        page.mouse.click(*WESTERN_BTN)
        time.sleep(10)
        page.screenshot(path=str(OUT / "case3_western.png"), full_page=True)
        results["cases"]["case3_western"] = {
            "screenshot": str(OUT / "case3_western.png"),
            "pass": None,  # set after visual / heuristic
        }

        # --- Case 4 BaZi ---
        page.mouse.click(*BACK_BTN)
        time.sleep(2)
        page.mouse.click(*BAZI_BTN)
        time.sleep(10)
        page.screenshot(path=str(OUT / "case4_bazi.png"), full_page=True)
        results["cases"]["case4_bazi"] = {
            "screenshot": str(OUT / "case4_bazi.png"),
            "pass": None,
        }

        browser.close()

    out_json = OUT / "results.json"
    out_json.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(results, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
