#!/usr/bin/env python3
"""Apply Post-Freeze Patch 002 — Monday Taksa rotation units."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CANON = ROOT / "knowledge/canon/production/foundation_v1.knowme.json"

MONDAY = [
    ("sun", "kalakini", "p38.monday.grid.1"),
    ("moon", "boriwan", "p38.monday.grid.2"),
    ("mars", "ayu", "p38.monday.grid.3"),
    ("venus", "montri", "p38.monday.grid.6"),
    ("mercury", "det", "p38.monday.grid.4"),
    ("rahu", "utsaha", "p38.monday.grid.8"),
    ("jupiter", "mula", "p38.monday.grid.5"),
    ("saturn", "sri", "p38.monday.grid.7"),
]


def main() -> None:
    data = json.loads(CANON.read_text(encoding="utf-8"))
    units = data["producedUnits"]
    before = sum(1 for u in units if isinstance(u, dict) and "id" in u)

    patch_units: list[dict] = [
        {
            "$note": (
                "Post-Freeze Patch 002 — Monday Taksa rotation "
                "(p38, source forensics 96f57d2)."
            )
        }
    ]
    for planet, role, locator in MONDAY:
        patch_units.append(
            {
                "id": f"taksa.p38.monday.{planet}_{role}",
                "subject": f"planet.{planet}",
                "subjectKind": "planet",
                "relation": "located_in",
                "object": f"taksaRole.{role}",
                "objectKind": "other",
                "domain": "planetLibrary",
                "strength": "none",
                "confidence": "high",
                "evidence": {
                    "bookId": "mahabhut",
                    "page": "38",
                    "locator": locator,
                },
                "context": {
                    "type": "taksa_chart",
                    "value": "คนเกิดวันจันทร์",
                },
            }
        )

    idx = next(
        i
        for i, u in enumerate(units)
        if isinstance(u, dict)
        and str(u.get("$note", "")).startswith("Phase C Taksa")
    )
    data["producedUnits"] = units[:idx] + patch_units + units[idx:]
    comment = data.get("$comment", "")
    data["$comment"] = comment.replace(
        "Post-Freeze Patch 001 (826 units)",
        "Post-Freeze Patch 001 + Patch 002 (834 units)",
    )
    CANON.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    after = sum(1 for u in data["producedUnits"] if isinstance(u, dict) and "id" in u)
    print(f"before={before} after={after} inserted_at={idx}")


if __name__ == "__main__":
    main()
