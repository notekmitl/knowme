#!/usr/bin/env python3
"""Deterministic Phase D Life Period extraction from Mahabhut OCR pages."""

from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path

OCR = Path(r"D:\MahabhutOCR\txt")
OUT = Path(__file__).resolve().parent / "output" / "phase_d_life_period_units.json"
BLOCKED = Path(__file__).resolve().parent / "output" / "phase_d_ocr_blocked.json"

POS_MAP = {
    "ธงชัย": "thongchai",
    "ขุมทรัพย์": "khumsap",
    "ราชา": "racha",
    "อธิบดี": "athibodi",
    "ภังคะ": "phangkha",
    "มรณะ": "marana",
    "ปูติ": "puti",
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

CHART_RE = re.compile(r"^(ดวง[\u0E00-\u0E7Fa-zA-Zํ]+)")
POS_RE = re.compile(r"เรือน(ธงชัย|ขุมทรัพย์|ราชา|อธิบดี|ภังคะ|มรณะ|ปูติ)")
PERIOD_TOKEN_RE = re.compile(
    r"(แรกเกิด|อายุ?\s*[๐-๙0-9]+\s*(?:ถึง|ตั้ง|ย่าง)\s*[๐-๙0-9]+(?:\s*ขวบ)?|อายุ?\s*[๐-๙0-9]+\s*ขวบ)"
)
RISE_FALL_RE = re.compile(r"ดวงขึ้น|ดวงขน|ดวงตก|ตวงต[กก]")
REMEDY_RE = re.compile(r"วิธีแก้|สะเดาะเคราะห์|แก้ดวง")


def word_count(text: str) -> int:
    return len(text.split())


def find_planet(line: str) -> str | None:
    for pat, pid in PLANETS:
        if re.search(pat, line):
            return pid
    return None


def find_planet_near(lines: list[str], idx: int) -> str | None:
    for j in range(idx, max(-1, idx - 4), -1):
        pl = find_planet(lines[j])
        if pl:
            return pl
    return None


def extract_birth_position_from_header(line: str) -> str | None:
    if "แรกเกิด" not in line:
        return None
    return find_position(line)


def find_position(line: str) -> str | None:
    m = POS_RE.search(line)
    if not m:
        return None
    return POS_MAP.get(m.group(1))


def normalize_status(line: str) -> str | None:
    if re.search(r"ดวงขึ้น|ดวงขน", line):
        return "ดวงขึ้น"
    if re.search(r"ดวงตก|ตวงตก", line):
        return "ดวงตก"
    return None


def period_token_from_line(line: str) -> str | None:
    s = line.strip()
    if REMEDY_RE.search(s):
        return None
    if "แรกเกิด" in s:
        token = "แรกเกิด"
    else:
        m = PERIOD_TOKEN_RE.search(s)
        if not m:
            return None
        token = re.sub(r"\s+", " ", m.group(1)).strip()
    status = normalize_status(s)
    if status:
        token = f"{token} [{status}]"
    if word_count(token) > 6:
        return None
    return token


def is_header_line(line: str) -> bool:
    s = line.strip()
    if len(s) > 70 or len(s) < 3:
        return False
    if REMEDY_RE.search(s):
        return False
    if "แรกเกิด" in s:
        return True
    if PERIOD_TOKEN_RE.search(s) and len(s) < 55:
        return True
    return False


def is_explicit_placement_line(line: str) -> bool:
    s = line.strip()
    if not POS_RE.search(s):
        return False
    if "เกิดในเรือน" in s:
        return True
    if "สถิต" in s and "เรือน" in s:
        return True
    if re.search(r"เข้า.*เรือน|อยู่เรือน|ในเรือน", s):
        return True
    return False


def add_unit(
    units: list[dict],
    *,
    uid: str,
    subject: str,
    relation: str,
    obj: str,
    page: str,
    context_type: str | None = None,
    context_value: str | None = None,
    object_kind: str = "other",
    subject_kind: str = "planet",
    domain: str = "lifePeriodRules",
) -> None:
    units.append(
        {
            "id": uid,
            "subject": subject,
            "subjectKind": subject_kind,
            "relation": relation,
            "object": obj,
            "objectKind": object_kind,
            "domain": domain,
            "context_type": context_type,
            "context_value": context_value,
            "page": page,
        }
    )


def extract_p17_rules(units: list[dict]) -> None:
    rise = [
        "thongchai",
        "khumsap",
        "racha",
        "athibodi",
    ]
    fall = ["phangkha", "marana", "puti"]
    for pos in rise:
        add_unit(
            units,
            uid=f"mahabhut.p17.dueng_khuen_relates_{pos}",
            subject="periodStatus.duengKhuen",
            subject_kind="other",
            relation="relates_to",
            obj=f"mahabhutPosition.{pos}",
            page="17",
            domain="lifePeriodRules",
        )
    for pos in fall:
        add_unit(
            units,
            uid=f"mahabhut.p17.dueng_tok_relates_{pos}",
            subject="periodStatus.duengTok",
            subject_kind="other",
            relation="relates_to",
            obj=f"mahabhutPosition.{pos}",
            page="17",
            domain="lifePeriodRules",
        )


def extract_p18_dasha(units: list[dict], blocked: list[dict]) -> None:
    p18 = (OCR / "page_018.txt").read_text(encoding="utf-8")
    clean = [
        (r"จันทร์.*เสวยอายุ\s*๑๕\s*ปี", "moon", "agePeriod.dasha15y"),
        (r"อังคาร.*เสวยอายุ\s*๕\s*ปี", "mars", "agePeriod.dasha5y"),
        (r"เสวยอาย\s*๑๐\s*ปี", "saturn", "agePeriod.dasha10y"),
        (r"ราห.*เสวยอาย\s*๑๒\s*ปี", "rahu", "agePeriod.dasha12y"),
    ]
    for pat, planet, age_id in clean:
        if re.search(pat, p18):
            add_unit(
                units,
                uid=f"mahabhut.p18.{planet}_relates_{age_id.split('.')[-1]}",
                subject=f"planet.{planet}",
                relation="relates_to",
                obj=age_id,
                page="18",
                domain="lifePeriodRules",
            )
        else:
            blocked.append(
                {
                    "page": "18",
                    "reason": "OCR_BLOCKED",
                    "pattern": pat,
                    "note": "expected dasha age line not recoverable",
                }
            )

    ambiguous = [
        ("sun", r"อาทิตย์.*เสวยอายุ"),
        ("mercury", r"พุธ.*เสวยอายุ"),
        ("jupiter", r"พฤหัส.*เสวยอายุ"),
        ("venus", r"ศุกร์.*เสวยอายุ"),
    ]
    for planet, pat in ambiguous:
        if re.search(pat, p18):
            blocked.append(
                {
                    "page": "18",
                    "reason": "OCR_BLOCKED",
                    "planet": planet,
                    "note": "dasha age digits ambiguous in OCR",
                }
            )


def extract_life_period_placements(
    units: list[dict], blocked: list[dict]
) -> None:
    seen: set[tuple] = set()
    chart: str | None = None
    current_period: str | None = None
    for fp in sorted(OCR.glob("page_*.txt"), key=lambda p: int(p.stem.split("_")[1])):
        page = str(int(fp.stem.split("_")[1]))
        if int(page) < 44:
            continue
        lines = fp.read_text(encoding="utf-8", errors="replace").splitlines()
        for i, line in enumerate(lines):
            s = line.strip()
            m = CHART_RE.match(s)
            if m and len(s) < 35:
                new_chart = m.group(1)
                if chart is not None and new_chart != chart:
                    current_period = None
                chart = new_chart
            if is_header_line(s):
                token = period_token_from_line(s)
                if token:
                    current_period = token
                    birth_pos = extract_birth_position_from_header(s)
                    if birth_pos and current_period:
                        planet = find_planet_near(lines, i) or find_planet_near(
                            lines, min(i + 1, len(lines) - 1)
                        )
                        if planet:
                            key = (page, planet, birth_pos, current_period)
                            if key not in seen:
                                seen.add(key)
                                slug = re.sub(
                                    r"[^\u0E00-\u0E7F0-9]+", "_", current_period
                                )[:40]
                                add_unit(
                                    units,
                                    uid=f"mahabhut.p{page}.{planet}_in_{birth_pos}_{slug}",
                                    subject=f"planet.{planet}",
                                    relation="located_in",
                                    obj=f"mahabhutPosition.{birth_pos}",
                                    page=page,
                                    context_type="life_period",
                                    context_value=current_period,
                                    domain="planetLibrary",
                                )
                elif PERIOD_TOKEN_RE.search(s) or "แรกเกิด" in s:
                    blocked.append(
                        {
                            "page": page,
                            "line": i + 1,
                            "text": s[:120],
                            "reason": "OCR_BLOCKED",
                            "note": "period header not atomic",
                        }
                    )
                continue
            if not is_explicit_placement_line(s):
                continue
            pos = find_position(s)
            if not pos:
                continue
            planet = find_planet_near(lines, i)
            if not planet:
                blocked.append(
                    {
                        "page": page,
                        "line": i + 1,
                        "text": s[:120],
                        "reason": "OCR_BLOCKED",
                        "note": "position stated but planet not resolvable",
                    }
                )
                continue
            if not current_period:
                continue
            key = (page, planet, pos, current_period)
            if key in seen:
                continue
            seen.add(key)
            slug = re.sub(r"[^\u0E00-\u0E7F0-9]+", "_", current_period)[:40]
            uid = f"mahabhut.p{page}.{planet}_in_{pos}_{slug}"
            add_unit(
                units,
                uid=uid,
                subject=f"planet.{planet}",
                relation="located_in",
                obj=f"mahabhutPosition.{pos}",
                page=page,
                context_type="life_period",
                context_value=current_period,
                domain="planetLibrary",
            )


def dedupe_ids(units: list[dict]) -> list[dict]:
    seen: set[str] = set()
    out: list[dict] = []
    for u in units:
        uid = u["id"]
        n = 2
        while uid in seen:
            uid = f"{u['id']}_v{n}"
            n += 1
        u["id"] = uid
        seen.add(uid)
        out.append(u)
    return out


def main() -> None:
    units: list[dict] = []
    blocked: list[dict] = []

    extract_p17_rules(units)
    extract_p18_dasha(units, blocked)
    extract_life_period_placements(units, blocked)

    units = dedupe_ids(units)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(units, ensure_ascii=False, indent=2), encoding="utf-8")
    BLOCKED.write_text(json.dumps(blocked, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"wrote {len(units)} units to {OUT}")
    print(f"wrote {len(blocked)} blocked lines to {BLOCKED}")
    print("by relation", Counter(u["relation"] for u in units))
    print("by context", Counter(u.get("context_type") for u in units))


if __name__ == "__main__":
    main()
