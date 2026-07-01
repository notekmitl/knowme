#!/usr/bin/env python3
"""Append Phase E prediction units to foundation_v1.knowme.json."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOUNDATION = ROOT / "knowledge/canon/production/foundation_v1.knowme.json"
SRC = ROOT / "tool/output/phase_e_prediction_units.json"

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
            "subjectKind": u.get("subjectKind", "other"),
            "relation": u["relation"],
            "object": u["object"],
            "objectKind": u.get("objectKind", "other"),
            "domain": "lifePeriodRules",
            "strength": u.get("strength", "none"),
            "confidence": "high",
            "evidence": {"bookId": "mahabhut", "page": u["page"]},
            **({"condition": u["condition"]} if u.get("condition") else {}),
            **({"context": ctx} if ctx else {}),
        }
    )

data = json.loads(FOUNDATION.read_text(encoding="utf-8"))
data["producedUnits"].append(
    {
        "$note": "Phase E Prediction Rules — pp.40–41 universal rise/fall effects, kalakini exceptions, Jupiter learning examples. Per-period narrative effects excluded (modeling gap)."
    }
)
data["producedUnits"].extend(batch)
old_total = sum(1 for x in data["producedUnits"] if "id" in x)
data["$comment"] = re.sub(r"\d+ units", f"{old_total} units", data.get("$comment", ""))
FOUNDATION.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Appended {len(batch)} Phase E units; total {old_total}")
