#!/usr/bin/env python3
"""Append Phase D Life Period units to foundation_v1.knowme.json."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOUNDATION = ROOT / "knowledge/canon/production/foundation_v1.knowme.json"
SRC = ROOT / "tool/output/phase_d_life_period_units.json"

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
            "subjectKind": u.get("subjectKind", "planet"),
            "relation": u["relation"],
            "object": u["object"],
            "objectKind": u.get("objectKind", "other"),
            "domain": u.get("domain", "planetLibrary"),
            "strength": "none",
            "confidence": "high",
            "evidence": {"bookId": "mahabhut", "page": u["page"]},
            **({"context": ctx} if ctx else {}),
        }
    )

data = json.loads(FOUNDATION.read_text(encoding="utf-8"))
data["producedUnits"].append(
    {
        "$note": "Phase D Life Period — pp.17–18 rise/fall + dasha rules; per-period mahabhut placements (life_period context). Narrative effects, remedies, and pp.40–41 prediction rules excluded."
    }
)
data["producedUnits"].extend(batch)
old_total = sum(1 for x in data["producedUnits"] if "id" in x)
data["$comment"] = re.sub(
    r"\d+ units",
    f"{old_total} units",
    data.get("$comment", ""),
)
FOUNDATION.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Appended {len(batch)} Phase D units; total {old_total}")
