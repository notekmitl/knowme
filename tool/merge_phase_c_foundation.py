#!/usr/bin/env python3
"""Append Phase C Taksa units to foundation_v1.knowme.json."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOUNDATION = ROOT / "knowledge/canon/production/foundation_v1.knowme.json"
SRC = ROOT / "tool/output/phase_c_taksa_units.json"

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
            "subjectKind": "planet" if u["subject"].startswith("planet.") else "other",
            "relation": u["relation"],
            "object": u["object"],
            "objectKind": u.get("objectKind", "other"),
            "domain": "planetLibrary",
            "strength": "none",
            "confidence": "high",
            "evidence": {"bookId": "mahabhut", "page": u["page"]},
            **({"context": ctx} if ctx else {}),
        }
    )

data = json.loads(FOUNDATION.read_text(encoding="utf-8"))
data["producedUnits"].append(
    {
        "$note": "Phase C Taksa — role meanings (p39), Tuesday rotation (p38), per-chart role assignments (ดาวแห่ง… lines). Prediction rules pp.40–41 deferred to Phase E."
    }
)
data["producedUnits"].extend(batch)
data["$comment"] = re.sub(
    r"357 units",
    "452 units",
    data["$comment"],
)
FOUNDATION.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Appended {len(batch)} Phase C units")
