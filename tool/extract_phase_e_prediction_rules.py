#!/usr/bin/env python3
"""Deterministic Phase E prediction-rule extraction from Mahabhut OCR."""

from __future__ import annotations

import json
import re
from pathlib import Path

OCR = Path(r"D:\MahabhutOCR\txt")
OUT = Path(__file__).resolve().parent / "output" / "phase_e_prediction_units.json"
BLOCKED = Path(__file__).resolve().parent / "output" / "phase_e_ocr_blocked.json"

COND_FALL = "อยู่เรือนภังคะ-มรณะ-ปูติ"
COND_RISE = "อยู่เรือนธงชัย-ขุมทรัพย์-ราชา-อธิบดี"
REMEDY_RE = re.compile(r"วิธีแก้|สะเดาะเคราะห์|แก้ดวง")


def add(
    units: list[dict],
    *,
    uid: str,
    subject: str,
    relation: str,
    obj: str,
    page: str,
    subject_kind: str = "other",
    object_kind: str = "other",
    condition: str | None = None,
    strength: str | None = None,
    context_type: str | None = None,
    context_value: str | None = None,
) -> None:
    units.append(
        {
            "id": uid,
            "subject": subject,
            "subjectKind": subject_kind,
            "relation": relation,
            "object": obj,
            "objectKind": object_kind,
            "domain": "lifePeriodRules",
            "condition": condition,
            "strength": strength or "none",
            "context_type": context_type,
            "context_value": context_value,
            "page": page,
        }
    )


def extract_pp40_41(units: list[dict], blocked: list[dict]) -> None:
    p40 = (OCR / "page_040.txt").read_text(encoding="utf-8")
    p41 = (OCR / "page_041.txt").read_text(encoding="utf-8")

    if "อ่อนแอ" in p40 and "ภังคะ" in p40:
        add(
            units,
            uid="mahabhut.p40.dueng_tok_produces_weak",
            subject="periodStatus.duengTok",
            relation="produces",
            obj="predictionEffect.weak",
            page="40",
        )
    else:
        blocked.append({"page": "40", "reason": "OCR_BLOCKED", "note": "fall weakness rule"})

    if "เข้มแข็ง" in p41 and "ธงชัย" in p41:
        add(
            units,
            uid="mahabhut.p41.dueng_khuen_produces_strong",
            subject="periodStatus.duengKhuen",
            relation="produces",
            obj="predictionEffect.strong",
            page="41",
        )
    else:
        blocked.append({"page": "41", "reason": "OCR_BLOCKED", "note": "rise strength rule"})

    if re.search(r"กาฬกิณี.*ภังคะ", p40):
        add(
            units,
            uid="mahabhut.p40.kalakini_opposes_dueng_tok",
            subject="taksaRole.kalakini",
            relation="opposes",
            obj="periodStatus.duengTok",
            page="40",
            condition=COND_FALL,
        )
    else:
        blocked.append({"page": "40", "reason": "OCR_BLOCKED", "note": "kalakini fall exception"})

    if re.search(r"กาฬกิณี.*ธงชัย", p41):
        add(
            units,
            uid="mahabhut.p41.kalakini_opposes_dueng_khuen",
            subject="taksaRole.kalakini",
            relation="opposes",
            obj="periodStatus.duengKhuen",
            page="41",
            condition=COND_RISE,
        )
    else:
        blocked.append({"page": "41", "reason": "OCR_BLOCKED", "note": "kalakini rise exception"})

    if re.search(r"พฤหัส.*ภังคะ", p40) and "การเรียน" in p40:
        add(
            units,
            uid="mahabhut.p40.jupiter_learning_fall",
            subject="planet.jupiter",
            subject_kind="planet",
            relation="produces",
            obj="domain.learning",
            object_kind="domain",
            page="40",
            condition=COND_FALL,
            strength="low",
        )
    else:
        blocked.append({"page": "40", "reason": "OCR_BLOCKED", "note": "jupiter learning fall example"})

    if re.search(r"พฤหัส", p41) and re.search(r"การศึกษา|การเรียน", p41):
        add(
            units,
            uid="mahabhut.p41.jupiter_learning_rise",
            subject="planet.jupiter",
            subject_kind="planet",
            relation="produces",
            obj="domain.learning",
            object_kind="domain",
            page="41",
            condition=COND_RISE,
            strength="high",
        )
    else:
        blocked.append({"page": "41", "reason": "OCR_BLOCKED", "note": "jupiter learning rise example"})


def main() -> None:
    units: list[dict] = []
    blocked: list[dict] = []
    extract_pp40_41(units, blocked)
    blocked.append(
        {
            "page": "44+",
            "reason": "MODELING_GAP",
            "note": "per-period domain effects are compound narrative; no atomic extraction without inference",
        }
    )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(units, ensure_ascii=False, indent=2), encoding="utf-8")
    BLOCKED.write_text(json.dumps(blocked, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {len(units)} units to {OUT}")
    print(f"blocked notes {len(blocked)}")


if __name__ == "__main__":
    main()
