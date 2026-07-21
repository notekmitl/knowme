#!/usr/bin/env python3
"""Read-only Firestore export for Real User Runtime Validation V1."""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore

ROOT = Path(__file__).resolve().parents[4]
SERVICE_ACCOUNT = ROOT / "backend" / "firebase" / "serviceAccountKey.json"
OUTPUT_DIR = ROOT / "test" / "validation" / "real_user_runtime_v1" / "output"
OUTPUT_PATH = OUTPUT_DIR / "firestore_user_export.json"


def _serialize(value):
    if isinstance(value, datetime):
        if value.tzinfo is None:
            value = value.replace(tzinfo=timezone.utc)
        return value.isoformat()
    if isinstance(value, dict):
        return {str(k): _serialize(v) for k, v in value.items()}
    if isinstance(value, list):
        return [_serialize(v) for v in value]
    return value


def _doc_data(doc) -> dict | None:
    if not doc.exists:
        return None
    data = doc.to_dict()
    if data is None:
        return None
    return _serialize(data)


def export_users(db) -> dict:
    users_ref = db.collection("users")
    user_docs = list(users_ref.stream())
    records = []

    for index, user_doc in enumerate(user_docs, start=1):
        uid = user_doc.id
        user_root = _doc_data(user_doc) or {}

        profile_doc = users_ref.document(uid).collection("profile").document("main").get()
        profile = _doc_data(profile_doc)

        results = {}
        for result_doc in users_ref.document(uid).collection("results").stream():
            data = _doc_data(result_doc)
            if data is not None:
                results[result_doc.id] = data

        astrology = {}
        for astro_doc in users_ref.document(uid).collection("astrology").stream():
            data = _doc_data(astro_doc)
            if data is not None:
                astrology[astro_doc.id] = data

        records.append(
            {
                "uid": uid,
                "userRoot": user_root,
                "profile": profile,
                "results": results,
                "astrology": astrology,
            }
        )
        print(f"Exported {index}/{len(user_docs)}: {uid}", flush=True)

    return {
        "exportedAt": datetime.now(timezone.utc).isoformat(),
        "populationSize": len(records),
        "users": records,
    }


def main() -> int:
    if not SERVICE_ACCOUNT.exists():
        print(f"Missing service account: {SERVICE_ACCOUNT}", file=sys.stderr)
        return 1

    if not firebase_admin._apps:
        cred = credentials.Certificate(str(SERVICE_ACCOUNT))
        firebase_admin.initialize_app(cred)

    db = firestore.client()
    payload = export_users(db)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"Wrote {OUTPUT_PATH} ({payload['populationSize']} users)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
