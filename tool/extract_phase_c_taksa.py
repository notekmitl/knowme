#!/usr/bin/env python3
"""Deterministic Phase C Taksa extraction from Mahabhut OCR pages."""

from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path

OCR = Path(r"D:\MahabhutOCR\txt")
OUT = Path(__file__).resolve().parent / "output" / "phase_c_taksa_units.json"

ROLES = {
    "บริวาร": "boriwan",
    "อายุ": "ayu",
    "เดช": "det",
    "ศรี": "sri",
    "มูละ": "mula",
    "อุตสาหะ": "utsaha",
    "อุสสาหะ": "utsaha",
    "มนตรี": "montri",
    "กาฬกิณี": "kalakini",
}

PLANETS = [
    (r"ดาวอาทิตย์|(?<![\u0E00-\u0E7F])อาทิตย์", "sun"),
    (r"ดาวจันทร์|(?<![\u0E00-\u0E7F])จันทร์", "moon"),
    (r"ดาวอังคาร|อังคาร", "mars"),
    (r"ดาวพุธ|(?<![\u0E00-\u0E7F])พุธ", "mercury"),
    (r"ดาวพฤหัส|พฤหัส", "jupiter"),
    (r"ดาวศุกร์|(?<![\u0E00-\u0E7F])ศุกร์", "venus"),
    (r"ดาวเสาร์|(?<![\u0E00-\u0E7F])เสาร์", "saturn"),
    (r"ดาวราหู|ดาวราห|ราหู|(?<![\u0E00-\u0E7F])ราห(?![\u0E00-\u0E7F])", "rahu"),
]

CHART_RE = re.compile(r"^(ดวง[\u0E00-\u0E7Fa-zA-Z]+)")
LIFE_RE = re.compile(r"แรกเกิด|อายุ\s*[๐-๙0-9]+|อาย\s*[๐-๙0-9]+")


def find_planet(line: str) -> str | None:
    for pat, pid in PLANETS:
        if re.search(pat, line):
            return pid
    return None


def role_in_line(line: str) -> str | None:
    for th, rid in ROLES.items():
        if th == "อุสสาหะ":
            continue
        if f"ดาวแห่ง{th}" in line or f"เป็นดาวแห่ง{th}" in line:
            return rid
    if "อุสสาหะ" in line and "ดาวแห่ง" in line:
        return "utsaha"
    return None


def main() -> None:
    units: list[dict] = []

    # p38 — explicit Tuesday-born rotation (clean OCR prose).
    p38 = (OCR / "page_038.txt").read_text(encoding="utf-8")
    if "วันอังคาร" in p38 and "บริวาร" in p38:
        tuesday = [
            ("mars", "boriwan"),
            ("mercury", "ayu"),
            ("saturn", "det"),
            ("jupiter", "sri"),
            ("rahu", "mula"),
            ("venus", "utsaha"),
            ("sun", "montri"),
            ("moon", "kalakini"),
        ]
        for pl, rl in tuesday:
            units.append(
                {
                    "id": f"mahabhut.p38.{pl}_located_in_{rl}_tuesday_birth",
                    "subject": f"planet.{pl}",
                    "relation": "located_in",
                    "object": f"taksaRole.{rl}",
                    "context_type": "other",
                    "context_value": "คนเกิดวันอังคาร",
                    "page": "38",
                }
            )

    # p39 — role meanings with clean single-domain mapping.
    meanings = [
        ("ayu", "health", "39", "สุขภาพ"),
        ("det", "career", "39", "ตําแหน่งหน้าที่การงาน"),
        ("sri", "finance", "39", "ทรัพย์สินเงินทอง"),
        ("montri", "career", "39", "เจ้านาย"),
    ]
    for role_id, domain, page, _ in meanings:
        units.append(
            {
                "id": f"mahabhut.p{page}.{role_id}_owns_{domain}",
                "subject": f"taksaRole.{role_id}",
                "relation": "owns",
                "object": f"domain.{domain}",
                "objectKind": "domain",
                "context_type": None,
                "context_value": None,
                "page": page,
            }
        )

    # Per-chart role assignments from life-period pages (role phrase only).
    for fp in sorted(OCR.glob("page_*.txt"), key=lambda p: int(p.stem.split("_")[1])):
        page = str(int(fp.stem.split("_")[1]))
        lines = fp.read_text(encoding="utf-8", errors="replace").splitlines()
        chart = None
        for line in lines:
            s = line.strip()
            m = CHART_RE.match(s)
            if m and len(s) < 35:
                chart = m.group(1)
        if not chart:
            continue
        life = None
        for line in lines:
            m = LIFE_RE.search(line)
            if m:
                life = m.group(0).strip()
        for i, line in enumerate(lines):
            role_id = role_in_line(line)
            if not role_id:
                continue
            planet = find_planet(line) or (find_planet(lines[i - 1]) if i else None)
            if not planet:
                continue
            slug = f"{planet}_located_in_{role_id}"
            if life:
                life_slug = re.sub(r"[^\u0E00-\u0E7F0-9]+", "_", life)
                slug += f"_{life_slug}"
            uid = f"mahabhut.p{page}.{slug}"
            ctx_type = "life_period" if life else "archetype_chart"
            ctx_val = life if life else chart
            units.append(
                {
                    "id": uid,
                    "subject": f"planet.{planet}",
                    "relation": "located_in",
                    "object": f"taksaRole.{role_id}",
                    "context_type": ctx_type,
                    "context_value": ctx_val,
                    "page": page,
                    "chart": chart,
                }
            )

    # Unique ids.
    seen: set[str] = set()
    deduped: list[dict] = []
    for u in units:
        uid = u["id"]
        n = 2
        while uid in seen:
            uid = f"{u['id']}_v{n}"
            n += 1
        u["id"] = uid
        seen.add(uid)
        deduped.append(u)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(deduped, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {len(deduped)} units to {OUT}")
    print("by context", Counter((u.get("context_type"), u.get("context_value")) for u in deduped))


if __name__ == "__main__":
    main()
