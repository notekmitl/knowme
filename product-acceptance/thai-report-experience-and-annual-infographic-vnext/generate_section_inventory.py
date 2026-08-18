from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent
manifest = json.loads((ROOT / "cross-runtime-vm-manifest.json").read_text(encoding="utf-8"))

lines = [
    "# Web/PDF shared section inventory",
    "",
    "Generated from the final VM manifest. Web, dedicated PDF and browser print consume the same row; renderer differences are layout-only.",
    "",
    "| Mode | Order | Section ID | Heading | Paragraph IDs | Field source | Visibility | Known/Unknown rule | Renderers |",
    "|---|---:|---|---|---|---|---|---|---|",
]

for case in manifest["cases"]:
    for order, section in enumerate(case["sections"], start=1):
        values = [
            case["mode"],
            str(order),
            section["id"],
            section["title"],
            ", ".join(section["paragraphIds"]),
            section["fieldSource"],
            section["visibilityRule"],
            section["knownUnknownRule"],
            "Web / dedicated PDF / browser print",
        ]
        escaped = [str(value).replace("|", "\\|").replace("\n", " ") for value in values]
        lines.append("| " + " | ".join(escaped) + " |")

lines += [
    "",
    "Infographic insertion index is 2 for both Known and Unknown, immediately after the summary boundary. The infographic uses the same annual fields and is omitted only when the shared model lacks a supported annual window.",
    "",
]

(ROOT / "web-pdf-section-inventory.md").write_text(
    "\n".join(lines), encoding="utf-8", newline="\n"
)
