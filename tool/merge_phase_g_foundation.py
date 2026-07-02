#!/usr/bin/env python3
"""Append Phase G lookup knowledge to foundation_v1.knowme.json."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOUNDATION = ROOT / "knowledge/canon/production/foundation_v1.knowme.json"
ATOMIC = ROOT / "tool/output/phase_g_atomic_units.json"
REF = ROOT / "tool/output/phase_g_reference_cells.json"

atomic = json.loads(ATOMIC.read_text(encoding="utf-8"))
ref = json.loads(REF.read_text(encoding="utf-8"))
batch = []
for u in atomic:
    ctx = None
    if u.get("context_type") and u.get("context_value"):
        ctx = {"type": u["context_type"], "value": u["context_value"]}
    evidence = {"bookId": "mahabhut", "page": u["page"]}
    if u.get("locator"):
        evidence["locator"] = u["locator"]
    batch.append(
        {
            "id": u["id"],
            "subject": u["subject"],
            "subjectKind": u.get("subjectKind", "other"),
            "relation": u["relation"],
            "object": u["object"],
            "objectKind": u.get("objectKind", "other"),
            "domain": "lookupTables",
            "strength": "none",
            "confidence": "high",
            "evidence": evidence,
            **({"condition": u["condition"]} if u.get("condition") else {}),
            **({"context": ctx} if ctx else {}),
        }
    )

ref_batch = []
for c in ref:
    ref_batch.append(
        {
            "id": c["id"],
            "tableId": c["tableId"],
            "tableTitle": c["tableTitle"],
            "rowKey": c["rowKey"],
            "columnKey": c["columnKey"],
            "cellValue": c["cellValue"],
            "evidence": {
                "bookId": "mahabhut",
                "page": c["page"],
                "locator": c["tableTitle"],
            },
        }
    )

data = json.loads(FOUNDATION.read_text(encoding="utf-8"))
data["producedUnits"].append(
    {
        "$note": "Phase G Lookup Tables — p19 remainder/chart + adjustment, p20 house-digit placement (42 cells), atomic only. p18 dasha OCR + p20 เศษ 4 excluded."
    }
)
data["producedUnits"].extend(batch)
if "producedReferenceTableCells" not in data:
    data["producedReferenceTableCells"] = []
data["producedReferenceTableCells"].append(
    {
        "$note": "Phase G birth-date chart lookup rows (pp.23–27) — reference-table cells only; OCR-blocked rows excluded."
    }
)
data["producedReferenceTableCells"].extend(ref_batch)
old_total = sum(1 for x in data["producedUnits"] if "id" in x)
data["$comment"] = re.sub(r"\d+ units", f"{old_total} units", data.get("$comment", ""))
FOUNDATION.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Appended {len(batch)} atomic + {len(ref_batch)} reference cells; total {old_total} units")
