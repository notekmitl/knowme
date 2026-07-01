#!/usr/bin/env python3
"""Append Batch 9 direction units to foundation_v1.knowme.json."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOUNDATION = ROOT / "knowledge/canon/production/foundation_v1.knowme.json"

BATCH9 = [
    {
        "id": "mahabhut.p37.sun_relates_attribute_direction_ตะวันออกเฉียงเหนือ",
        "subject": "planet.sun",
        "subjectKind": "planet",
        "relation": "relates_to",
        "object": "attribute.direction.ตะวันออกเฉียงเหนือ",
        "objectKind": "keyword",
        "domain": "planetLibrary",
        "strength": "none",
        "confidence": "high",
        "evidence": {"bookId": "mahabhut", "page": "37"},
    },
    {
        "id": "mahabhut.p37.moon_relates_attribute_direction_ตะวันออก",
        "subject": "planet.moon",
        "subjectKind": "planet",
        "relation": "relates_to",
        "object": "attribute.direction.ตะวันออก",
        "objectKind": "keyword",
        "domain": "planetLibrary",
        "strength": "none",
        "confidence": "high",
        "evidence": {"bookId": "mahabhut", "page": "37"},
    },
    {
        "id": "mahabhut.p37.mars_relates_attribute_direction_ตะวันออกเฉียงใต้",
        "subject": "planet.mars",
        "subjectKind": "planet",
        "relation": "relates_to",
        "object": "attribute.direction.ตะวันออกเฉียงใต้",
        "objectKind": "keyword",
        "domain": "planetLibrary",
        "strength": "none",
        "confidence": "high",
        "evidence": {"bookId": "mahabhut", "page": "37"},
    },
    {
        "id": "mahabhut.p37.mercury_relates_attribute_direction_ใต้",
        "subject": "planet.mercury",
        "subjectKind": "planet",
        "relation": "relates_to",
        "object": "attribute.direction.ใต้",
        "objectKind": "keyword",
        "domain": "planetLibrary",
        "strength": "none",
        "confidence": "high",
        "evidence": {"bookId": "mahabhut", "page": "37"},
    },
    {
        "id": "mahabhut.p37.saturn_relates_attribute_direction_ตะวันตกเฉียงใต้",
        "subject": "planet.saturn",
        "subjectKind": "planet",
        "relation": "relates_to",
        "object": "attribute.direction.ตะวันตกเฉียงใต้",
        "objectKind": "keyword",
        "domain": "planetLibrary",
        "strength": "none",
        "confidence": "high",
        "evidence": {"bookId": "mahabhut", "page": "37"},
    },
    {
        "id": "mahabhut.p37.jupiter_relates_attribute_direction_ตะวันตก",
        "subject": "planet.jupiter",
        "subjectKind": "planet",
        "relation": "relates_to",
        "object": "attribute.direction.ตะวันตก",
        "objectKind": "keyword",
        "domain": "planetLibrary",
        "strength": "none",
        "confidence": "high",
        "evidence": {"bookId": "mahabhut", "page": "37"},
    },
    {
        "id": "mahabhut.p37.rahu_relates_attribute_direction_ตะวันตกเฉียงเหนือ",
        "subject": "planet.rahu",
        "subjectKind": "planet",
        "relation": "relates_to",
        "object": "attribute.direction.ตะวันตกเฉียงเหนือ",
        "objectKind": "keyword",
        "domain": "planetLibrary",
        "strength": "none",
        "confidence": "high",
        "evidence": {"bookId": "mahabhut", "page": "37"},
    },
    {
        "id": "mahabhut.p37.venus_relates_attribute_direction_เหนือ",
        "subject": "planet.venus",
        "subjectKind": "planet",
        "relation": "relates_to",
        "object": "attribute.direction.เหนือ",
        "objectKind": "keyword",
        "domain": "planetLibrary",
        "strength": "none",
        "confidence": "high",
        "evidence": {"bookId": "mahabhut", "page": "37"},
    },
]

data = json.loads(FOUNDATION.read_text(encoding="utf-8"))
data["producedUnits"].append(
    {
        "$note": "Production Batch 9 — planet directions (p37). ครองทิศ… lines only; symbols on same lines not extracted."
    }
)
data["producedUnits"].extend(BATCH9)
data["$comment"] = re.sub(
    r"Batch 4 \+ 5 \+ 6 \+ 7 \+ 8; \d+ units",
    "Batch 4 + 5 + 6 + 7 + 8 + 9; 357 units",
    data["$comment"],
)
FOUNDATION.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("Appended 8 Batch 9 units")
