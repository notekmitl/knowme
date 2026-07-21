#!/usr/bin/env python3
"""Append Phase F remedy units to foundation_v1.knowme.json."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOUNDATION = ROOT / "knowledge/canon/production/foundation_v1.knowme.json"
SRC = ROOT / "tool/output/phase_f_remedy_units.json"

units = json.loads(SRC.read_text(encoding="utf-8"))
batch = []
for u in units:
    ctx = None
    if u.get("context_type") and u.get("context_value"):
        ctx = {"type": u["context_type"], "value": u["context_value"]}
    batch.append(
        {
            "id": u["id"],
            "subject": u["subject"],
            "subjectKind": u.get("subjectKind", "remedy"),
            "relation": u["relation"],
            "object": u["object"],
            "objectKind": u.get("objectKind", "other"),
            "domain": "remedies",
            "strength": "none",
            "confidence": "high",
            "evidence": {"bookId": "mahabhut", "page": u["page"]},
            **({"condition": u["condition"]} if u.get("condition") else {}),
            **({"context": ctx} if ctx else {}),
        }
    )

data = json.loads(FOUNDATION.read_text(encoding="utf-8"))
data["producedUnits"].append(
    {
        "$note": "Phase F Remedies — p294 universal procedure, weekday directions/symbols, buddha-day images, embedded life-period remedy facts. Mantras and compound procedures excluded (modeling gap / OCR)."
    }
)
data["producedUnits"].extend(batch)
old_total = sum(1 for x in data["producedUnits"] if "id" in x)
data["$comment"] = re.sub(r"\d+ units", f"{old_total} units", data.get("$comment", ""))
FOUNDATION.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Appended {len(batch)} Phase F units; total {old_total}")
