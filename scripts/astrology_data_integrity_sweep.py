#!/usr/bin/env python3
"""Audit and repair missing astrology artifacts for users with complete birth profiles."""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
BACKEND_DIR = REPO_ROOT / "backend"
OUTPUT_DIR = REPO_ROOT / "tool" / "output" / "astrology_integrity_sweep"
API_BASE = (
    Path(REPO_ROOT / "config" / "astrology_api_base_url.txt").read_text(encoding="utf-8").strip()
    if (REPO_ROOT / "config" / "astrology_api_base_url.txt").exists()
    else "https://knowme-astrology-api-avbyttircq-as.a.run.app"
)
ORIGIN = "https://knowme-app-694e1.web.app"


def _flutter_executable() -> str:
    for candidate in ("flutter", "flutter.bat"):
        found = shutil.which(candidate)
        if found:
            return found
    raise RuntimeError("flutter not found on PATH; install Flutter SDK or add to PATH")


@dataclass
class ProfileRecord:
    uid: str
    email: str
    profile: dict[str, Any]
    western: bool
    bazi: bool
    fusion: bool
    thai_ready: bool
    missing: list[str] = field(default_factory=list)


def _init_firebase():
    os.chdir(BACKEND_DIR)
    sys.path.insert(0, str(BACKEND_DIR))
    from firebase_admin import auth, credentials, initialize_app
    import firebase_admin

    if not firebase_admin._apps:
        cred = credentials.Certificate(str(BACKEND_DIR / "firebase" / "serviceAccountKey.json"))
        initialize_app(cred)
    from app.services.firebase_service import db

    return auth, db


def _parse_date(raw: str) -> bool:
    raw = (raw or "").strip()
    if not raw:
        return False
    if re.fullmatch(r"\d{4}-\d{2}-\d{2}", raw):
        return True
    try:
        datetime.fromisoformat(raw.replace("Z", "+00:00"))
        return True
    except ValueError:
        return False


def _api_birth_date(profile: dict[str, Any]) -> str:
    raw = str(profile.get("birthDate", "")).strip()
    if re.fullmatch(r"\d{4}-\d{2}-\d{2}", raw):
        return raw
    parsed = datetime.fromisoformat(raw.replace("Z", "+00:00"))
    return parsed.strftime("%Y-%m-%d")


def is_complete_profile(profile: dict[str, Any] | None) -> bool:
    if not profile:
        return False
    birth_date = str(profile.get("birthDate", "")).strip()
    birth_time = str(profile.get("birthTime", "")).strip()
    birth_place = str(profile.get("birthPlace", "")).strip()
    lat = float(profile.get("latitude") or 0)
    lng = float(profile.get("longitude") or 0)
    if not _parse_date(birth_date):
        return False
    if not birth_time or birth_time.lower() == "unknown":
        return False
    if not birth_place:
        return False
    if lat == 0 and lng == 0:
        return False
    return True


def is_automation_email(email: str | None) -> bool:
    if not email:
        return True
    lowered = email.lower()
    markers = ("@knowme.test", "e2e.", "e2e@", "verify@", "cors@", "audit@")
    return any(m in lowered for m in markers)


def _post(path: str, payload: dict[str, Any]) -> tuple[bool, str]:
    req = urllib.request.Request(
        f"{API_BASE}{path}",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Origin": ORIGIN,
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            return 200 <= resp.status < 300, body[:500]
    except urllib.error.HTTPError as exc:
        return False, exc.read().decode("utf-8", errors="replace")[:500]
    except Exception as exc:
        return False, str(exc)


def repair_western(uid: str, profile: dict[str, Any]) -> tuple[bool, str]:
    ok, body = _post(
        "/generate-chart",
        {
            "uid": uid,
            "birth_date": _api_birth_date(profile),
            "birth_time": str(profile.get("birthTime", "")).strip(),
            "latitude": float(profile.get("latitude")),
            "longitude": float(profile.get("longitude")),
        },
    )
    return ok, body


def repair_bazi(uid: str, profile: dict[str, Any]) -> tuple[bool, str]:
    ok, body = _post(
        "/generate-bazi",
        {
            "uid": uid,
            "birth_date": _api_birth_date(profile),
            "birth_time": str(profile.get("birthTime", "")).strip(),
            "timezone": str(profile.get("timezone") or "Asia/Bangkok"),
            "latitude": float(profile.get("latitude")),
            "longitude": float(profile.get("longitude")),
        },
    )
    return ok, body


def _fusion_input_path(uid: str) -> Path:
    return OUTPUT_DIR / f"fusion_input_{uid}.json"


def _fusion_output_path(uid: str) -> Path:
    return OUTPUT_DIR / f"fusion_output_{uid}.json"


def repair_fusion(uid: str, profile: dict[str, Any], western: dict | None, bazi: dict | None) -> tuple[bool, str]:
    if western is None or bazi is None:
        return False, "missing western or bazi for fusion generation"

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    payload = {"uid": uid, "profile": profile, "western": western, "bazi": bazi}
    _fusion_input_path(uid).write_text(json.dumps(payload), encoding="utf-8")
    out_path = _fusion_output_path(uid)
    if out_path.exists():
        out_path.unlink()

    env = os.environ.copy()
    env["FUSION_INPUT_PATH"] = str(_fusion_input_path(uid))
    env["FUSION_OUTPUT_PATH"] = str(out_path)

    proc = subprocess.run(
        [
            _flutter_executable(),
            "test",
            "test/validation/astrology_data_integrity/fusion_repair_export_test.dart",
            "--plain-name",
            "exports fusion snapshot for repair batch",
        ],
        cwd=REPO_ROOT,
        env=env,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        return False, (proc.stderr or proc.stdout)[-800:]

    if not out_path.exists():
        return False, "fusion export test did not write output file"

    fusion_map = json.loads(out_path.read_text(encoding="utf-8"))
    _write_fusion_doc(uid, fusion_map)
    return True, "fusion generated via AstrologyFusionGenerator"


def _write_fusion_doc(uid: str, fusion_map: dict[str, Any]) -> None:
    from app.services.firebase_service import db
    from google.cloud import firestore

    generated = fusion_map.get("generatedAt")
    if isinstance(generated, str):
        fusion_map["generatedAt"] = datetime.fromisoformat(
            generated.replace("Z", "+00:00")
        )

    db.collection("users").document(uid).collection("results").document(
        "astrology_fusion"
    ).set(fusion_map)


def scan_users(auth, db) -> list[ProfileRecord]:
    records: list[ProfileRecord] = []
    for user in auth.list_users().iterate_all():
        email = user.email or ""
        if is_automation_email(email):
            continue

        uid = user.uid
        profile_snap = (
            db.collection("users").document(uid).collection("profile").document("main").get()
        )
        profile = profile_snap.to_dict() if profile_snap.exists else None
        if not is_complete_profile(profile):
            continue

        western_exists = (
            db.collection("users")
            .document(uid)
            .collection("astrology")
            .document("western_natal")
            .get()
            .exists
        )
        bazi_exists = (
            db.collection("users")
            .document(uid)
            .collection("astrology")
            .document("chinese_bazi")
            .get()
            .exists
        )
        fusion_exists = (
            db.collection("users")
            .document(uid)
            .collection("results")
            .document("astrology_fusion")
            .get()
            .exists
        )

        missing: list[str] = []
        if not western_exists:
            missing.append("western_natal")
        if not bazi_exists:
            missing.append("chinese_bazi")
        if not fusion_exists:
            missing.append("astrology_fusion")

        records.append(
            ProfileRecord(
                uid=uid,
                email=email,
                profile=profile or {},
                western=western_exists,
                bazi=bazi_exists,
                fusion=fusion_exists,
                thai_ready=True,
                missing=missing,
            )
        )
    return records


def load_doc(db, uid: str, col: str, doc: str) -> dict[str, Any] | None:
    snap = db.collection("users").document(uid).collection(col).document(doc).get()
    if not snap.exists:
        return None
    return snap.to_dict()


def main() -> int:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    auth, db = _init_firebase()

    scanned = scan_users(auth, db)
    needs_repair = [r for r in scanned if r.missing]

    repaired: list[dict[str, Any]] = []
    failed: list[dict[str, Any]] = []

    for record in needs_repair:
        actions: list[str] = []
        errors: list[str] = []

        if "western_natal" in record.missing:
            ok, msg = repair_western(record.uid, record.profile)
            actions.append("western_natal")
            if ok:
                record.western = True
            else:
                errors.append(f"western: {msg}")

        if "chinese_bazi" in record.missing:
            ok, msg = repair_bazi(record.uid, record.profile)
            actions.append("chinese_bazi")
            if ok:
                record.bazi = True
            else:
                errors.append(f"bazi: {msg}")

        if "astrology_fusion" in record.missing or (
            record.western and record.bazi and not record.fusion
        ):
            western_doc = load_doc(db, record.uid, "astrology", "western_natal")
            bazi_doc = load_doc(db, record.uid, "astrology", "chinese_bazi")
            ok, msg = repair_fusion(record.uid, record.profile, western_doc, bazi_doc)
            actions.append("astrology_fusion")
            if ok:
                record.fusion = True
            else:
                errors.append(f"fusion: {msg}")

        entry = {
            "uid": record.uid,
            "email": record.email,
            "actions": actions,
        }
        if errors:
            entry["errors"] = errors
            failed.append(entry)
        else:
            repaired.append(entry)

    # Post-repair verification
    post_scan = scan_users(auth, db)
    incomplete = [
        {
            "uid": r.uid,
            "email": r.email,
            "missing": {
                "western_natal": not r.western,
                "chinese_bazi": not r.bazi,
                "astrology_fusion": not r.fusion,
                "thai_ready": not r.thai_ready,
            },
        }
        for r in post_scan
        if not r.western or not r.bazi or not r.fusion or not r.thai_ready
    ]

    report = {
        "ran_at": datetime.now(timezone.utc).isoformat(),
        "api_base": API_BASE,
        "users_scanned": len(scanned),
        "users_needing_repair": len(needs_repair),
        "users_repaired": len(repaired),
        "users_failed": len(failed),
        "repaired": repaired,
        "failed": failed,
        "post_verification_incomplete": incomplete,
        "success": len(incomplete) == 0,
    }

    report_path = OUTPUT_DIR / "report.json"
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False))
    return 0 if report["success"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
