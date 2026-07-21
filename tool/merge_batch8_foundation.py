#!/usr/bin/env python3
"""Append Batch 8 units to foundation_v1.knowme.json."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOUNDATION = ROOT / "knowledge/canon/production/foundation_v1.knowme.json"
BATCH8 = ROOT / "tool/output/batch8_foundation_units.json"

data = json.loads(FOUNDATION.read_text(encoding="utf-8"))
batch8 = json.loads(BATCH8.read_text(encoding="utf-8"))

note = {
    "$note": "Production Batch 8 — Planet Library attributes pp.30–36. planet --relates_to--> attribute.* (D-072); one explicit list item or scalar per unit."
}
data["producedUnits"].append(note)
data["producedUnits"].extend(batch8)

data["$comment"] = re.sub(
    r"Batch 4 \+ 5 \+ 6 \+ 7; \d+ units",
    "Batch 4 + 5 + 6 + 7 + 8; 349 units",
    data["$comment"],
)
data["$comment"] = data["$comment"].replace(
    "Optional `condition` (verbatim from source) scopes a general signification without chart context (Batch 7, p16).",
    "Optional `condition` (verbatim from source) scopes a general signification without chart context (Batch 7, p16). "
    "Planet Library attributes use `relates_to` → `attribute.*` value tokens (Batch 8, D-072).",
)

FOUNDATION.write_text(
    json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
print(f"foundation_v1 now has {len(data['producedUnits'])} top-level entries")
