#!/usr/bin/env python3
"""Deterministic Phase F remedy extraction from Mahabhut OCR."""

from __future__ import annotations

import json
import re
from pathlib import Path

OCR = Path(r"D:\MahabhutOCR\txt")
OUT = Path(__file__).resolve().parent / "output" / "phase_f_remedy_units.json"
BLOCKED = Path(__file__).resolve().parent / "output" / "phase_f_ocr_blocked.json"
GAPS = Path(__file__).resolve().parent / "output" / "phase_f_modeling_gaps.json"

REMEDY_START = re.compile(r"วิธีแก้|วิธีแกท้")
PERIOD_RE = re.compile(
    r"(อายุ?\s*[๐-๙0-9]+\s*(?:ถึง|ตั้ง|ย่าง)\s*[๐-๙0-9]+(?:\s*ขวบ)?(?:\s*\([^)]+\))?)"
)
DIRECTION_MAP = {
    "ตะวันออกเฉียงเหนือ": "attribute.direction.ตะวันออกเฉียงเหนือ",
    "ตะวันออก": "attribute.direction.ตะวันออก",
    "ตะวันออกเฉียงใต้": "attribute.direction.ตะวันออกเฉียงใต้",
    "ใต้": "attribute.direction.ใต้",
    "ตะวันตก": "attribute.direction.ตะวันตก",
    "ตะวันตกเฉียงใต้": "attribute.direction.ตะวันตกเฉียงใต้",
    "ตะวันตกเฉียงเหนือ": "attribute.direction.ตะวันตกเฉียงเหนือ",
    "เหนือ": "attribute.direction.เหนือ",
}
WEEKDAY_DIRS = [
    ("sun", "คนเกิดวันอาทิตย์", "ตะวันออกเฉียงเหนือ"),
    ("moon", "คนเกิดวันจันทร์", "ตะวันออก"),
    ("mars", "คนเกิดวันอังคาร", "ตะวันออกเฉียงใต้"),
    ("mercury", "คนเกิดวันพุธ", "ใต้"),
    ("jupiter", "คนเกิดวันพฤหัส", "ตะวันตก"),
    ("venus", "คนเกิดวันศุกร์", "เหนือ"),
    ("saturn", "คนเกิดวันเสาร์", "ตะวันตกเฉียงใต้"),
]
WEEKDAY_SYMBOLS = [
    ("sun", "คนเกิดวันอาทิตย์", "ritualTarget.garuda", "พญาครุฑ"),
    ("moon", "คนเกิดวันจันทร์", "ritualTarget.tiger", "เสือ"),
    ("mars", "คนเกิดวันอังคาร", "ritualTarget.lion", "สิงห์"),
    ("mercury", "คนเกิดวันพุธ", "ritualTarget.elephant", "ช้างฉัทรันต์"),
    ("jupiter", "คนเกิดวันพฤหัส", "ritualTarget.rat", "หนู"),
    ("venus", "คนเกิดวันศุกร์", "ritualTarget.ratPhao", "หนูตะเภา"),
    ("saturn", "คนเกิดวันเสาร์", "ritualTarget.naga", "พญานาค"),
]
BUDDHA_IMAGES = [
    ("298", "sun", "คนเกิดวันอาทิตย์", "ritualTarget.buddhaThawaiNet", ["พระปางถวายเนตร"]),
    ("299", "moon", "คนเกิดวันจันทร์", "ritualTarget.buddhaHamSamut", ["พระปางห้ามสมุทร"]),
    ("301", "mercury", "คนเกิดวันพุธ", "ritualTarget.buddhaUmbat", ["พระปางอัมบาตร"]),
    ("302", "jupiter", "คนเกิดวันพฤหัส", "ritualTarget.buddhaSamathi", ["พระปางสมาธิ", "พระปางสมาชธิ"]),
    ("303", "venus", "คนเกิดวันศุกร์", "ritualTarget.buddhaRampooeng", ["พระปางรำพึง", "พระปางรําพึง"]),
    ("304", "saturn", "คนเกิดวันเสาร์", "ritualTarget.buddhaNakProk", ["พระปางนาคปรก"]),
]
POSTURE_MAP = {
    "ถวายเนตร": "ritualTarget.buddhaThawaiNet",
    "ห้ามสมุทร": "ritualTarget.buddhaHamSamut",
    "อัมบาตร": "ritualTarget.buddhaUmbat",
    "สมาธิ": "ritualTarget.buddhaSamathi",
    "สมาชธิ": "ritualTarget.buddhaSamathi",
    "รำพึง": "ritualTarget.buddhaRampooeng",
    "นาคปรก": "ritualTarget.buddhaNakProk",
}
RITUAL_DAY_RE = re.compile(r"ในวัน(อาทิตย์|จันทร์|อังคาร|พุธ|พฤหัส|ศุกร์|เสาร์)")
DIR_RE = re.compile(r"ทิศ(ตะวันออกเฉียงเหนือ|ตะวันออกเฉียงใต้|ตะวันออก|ตะวันตกเฉียงใต้|ตะวันตกเฉียงเหนือ|ตะวันตก|เหนือ|ใต้)")


def add(
    units: list[dict],
    *,
    uid: str,
    subject: str = "remedy.sadoeKhroh",
    relation: str,
    obj: str,
    page: str,
    subject_kind: str = "remedy",
    object_kind: str = "other",
    condition: str | None = None,
    context_type: str | None = None,
    context_value: str | None = None,
) -> None:
    units.append(
        {
            "id": uid,
            "subject": subject,
            "subjectKind": subject_kind,
            "relation": relation,
            "object": obj,
            "objectKind": object_kind,
            "page": page,
            **({"condition": condition} if condition else {}),
            **(
                {"context_type": context_type, "context_value": context_value}
                if context_type and context_value
                else {}
            ),
        }
    )


def read_page(num: int) -> list[str]:
    path = OCR / f"page_{num:03d}.txt"
    if not path.exists():
        return []
    return path.read_text(encoding="utf-8", errors="replace").splitlines()


def find_life_period(lines: list[str], start_idx: int) -> str | None:
    for j in range(start_idx, max(-1, start_idx - 25), -1):
        m = PERIOD_RE.search(lines[j])
        if m:
            return m.group(1).strip()
    return None


def normalize_direction(text: str) -> str | None:
    m = DIR_RE.search(text)
    if not m:
        return None
    return DIRECTION_MAP.get(m.group(1))


def parse_remedy_block(block: str) -> dict:
    facts: dict[str, object] = {"items": set(), "target": None, "direction": None, "timing": None}
    if re.search(r"แจกัน\s*๓|แจกัน ๓", block):
        facts["items"].add("remedyItem.vase3")
    if re.search(r"ดอกมะลิ|กุหลาบ", block):
        facts["items"].add("remedyItem.jasmineRose")
    if re.search(r"ยอดหน้าว|ยอดหว้า|ยอดมะพร้าว", block):
        facts["items"].add("remedyItem.tropicaShoot")
    if re.search(r"ดอกไม้เกินอายุ", block):
        facts["items"].add("remedyItem.flowersPerVase")
    if re.search(r"เทียนขี้ผึ้ง", block):
        facts["items"].add("remedyItem.incensePerAge")
    if re.search(r"พระประจำวัน|พระประธาน|พระเจดีย์", block):
        facts["items"].add("remedyItem.buddhaDayImage")
    for key, tid in POSTURE_MAP.items():
        if key in block:
            facts["target"] = tid
            break
    facts["direction"] = normalize_direction(block)
    tm = RITUAL_DAY_RE.search(block)
    if tm:
        facts["timing"] = f"ในวัน{tm.group(1)}"
    return facts


def extract_chapter_294(units: list[dict]) -> None:
    add(
        units,
        uid="mahabhut.p294.sadoe_trigger_dueng_tok",
        relation="relates_to",
        obj="periodStatus.duengTok",
        page="294",
        condition="ดวงตกหนัก",
    )
    for item, slug in [
        ("remedyItem.buddhaDayImage", "requires_buddha_day_image"),
        ("remedyItem.vase3", "requires_vase3"),
        ("remedyItem.flowersPerVase", "requires_flowers_per_vase"),
        ("remedyItem.incensePerAge", "requires_incense_per_age"),
    ]:
        add(
            units,
            uid=f"mahabhut.p294.{slug}",
            relation="requires",
            obj=item,
            page="294",
            object_kind="other",
        )
    for slug, ctx, direction in WEEKDAY_DIRS:
        add(
            units,
            uid=f"mahabhut.p294.direction_{slug}",
            relation="relates_to",
            obj=DIRECTION_MAP[direction],
            page="294",
            context_type="other",
            context_value=ctx,
        )


def extract_weekday_symbols(units: list[dict]) -> None:
    for slug, ctx, target, symbol in WEEKDAY_SYMBOLS:
        add(
            units,
            uid=f"mahabhut.p295.symbol_{slug}",
            relation="relates_to",
            obj=target,
            page="295" if slug in {"sun", "moon", "mars"} else "296" if slug in {"mercury", "jupiter", "venus"} else "297",
            condition=f"มี{symbol}เป็นสัญลักษณ์",
            context_type="other",
            context_value=ctx,
        )


def extract_buddha_images(units: list[dict], blocked: list[dict]) -> None:
    for page, slug, ctx, target, aliases in BUDDHA_IMAGES:
        lines = read_page(int(page))
        text = "\n".join(lines)
        if not lines or not any(a in text for a in aliases):
            blocked.append(
                {
                    "page": page,
                    "reason": f"OCR_BLOCKED: buddha day image caption unreadable ({aliases[0]})",
                }
            )
            continue
        add(
            units,
            uid=f"mahabhut.p{page}.buddha_image_{slug}",
            relation="relates_to",
            obj=target,
            page=page,
            context_type="other",
            context_value=ctx,
        )
    # Tuesday image page — OCR blocked.
    lines = read_page(300)
    text = "\n".join(lines)
    if not re.search(r"พระปาง|อาทิตย์|อังคาร", text) or len(text) < 40:
        blocked.append(
            {
                "page": "300",
                "reason": "OCR_BLOCKED: พระประจำวันอังคาร image caption unreadable",
            }
        )


def extract_embedded(units: list[dict], blocked: list[dict]) -> None:
    seen: set[tuple] = set()
    for num in range(44, 293):
        lines = read_page(num)
        if not lines:
            continue
        text = "\n".join(lines)
        if not REMEDY_START.search(text):
            continue
        for i, line in enumerate(lines):
            if not REMEDY_START.search(line):
                continue
            block = "\n".join(lines[i : min(len(lines), i + 12)])
            if "คำอธิษฐาน" in block and block.index("คำอธิษฐาน") < 80:
                # Mantra prose follows immediately — items/targets still in opening lines.
                block = block.split("คำอธิษฐาน")[0]
            facts = parse_remedy_block(block)
            if not facts["items"] and not facts["target"] and not facts["direction"]:
                blocked.append(
                    {
                        "page": str(num),
                        "line": i + 1,
                        "reason": "OCR_BLOCKED: embedded remedy block unreadable",
                    }
                )
                continue
            period = find_life_period(lines, i)
            ctx_type = "life_period" if period else "other"
            ctx_val = period or "ว่าด้วยการแก้ดวง=สะเดาะเคราะห์"
            for item in sorted(facts["items"]):
                key = (num, ctx_val, "requires", item, facts.get("timing"))
                if key in seen:
                    continue
                seen.add(key)
                slug = item.split(".", 1)[1]
                cond = facts["timing"] if isinstance(facts["timing"], str) else None
                add(
                    units,
                    uid=f"mahabhut.p{num}.embedded_{slug}",
                    relation="requires",
                    obj=item,
                    page=str(num),
                    object_kind="other",
                    condition=cond,
                    context_type=ctx_type,
                    context_value=ctx_val,
                )
            if facts["target"]:
                key = (num, ctx_val, "target", facts["target"], facts.get("timing"))
                if key not in seen:
                    seen.add(key)
                    slug = str(facts["target"]).split(".", 1)[1]
                    add(
                        units,
                        uid=f"mahabhut.p{num}.embedded_target_{slug}",
                        relation="relates_to",
                        obj=str(facts["target"]),
                        page=str(num),
                        condition=facts["timing"] if isinstance(facts["timing"], str) else None,
                        context_type=ctx_type,
                        context_value=ctx_val,
                    )
            if facts["direction"]:
                key = (num, ctx_val, "direction", facts["direction"], facts.get("timing"))
                if key not in seen:
                    seen.add(key)
                    dslug = facts["direction"].split(".")[-1]
                    add(
                        units,
                        uid=f"mahabhut.p{num}.embedded_dir_{dslug}",
                        relation="relates_to",
                        obj=str(facts["direction"]),
                        page=str(num),
                        condition=facts["timing"] if isinstance(facts["timing"], str) else None,
                        context_type=ctx_type,
                        context_value=ctx_val,
                    )


def record_gaps(gaps: list[dict]) -> None:
    gaps.extend(
        [
            {
                "material": "pp.295–297 คำอธิษฐาน per weekday",
                "reason": "Multi-clause ritual prose / mantra text — not splittable without losing meaning",
            },
            {
                "material": "p293 remedy intro",
                "reason": "OCR_BLOCKED — page text unreadable",
            },
            {
                "material": "Embedded remedy multi-step fallback procedures",
                "reason": "Compound instructions (e.g. alternate direction if image missing) — not atomic",
            },
        ]
    )


def main() -> None:
    units: list[dict] = []
    blocked: list[dict] = []
    gaps: list[dict] = []
    extract_chapter_294(units)
    extract_weekday_symbols(units)
    extract_buddha_images(units, blocked)
    extract_embedded(units, blocked)
    record_gaps(gaps)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(units, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    BLOCKED.write_text(json.dumps(blocked, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    GAPS.write_text(json.dumps(gaps, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {len(units)} units, {len(blocked)} blocked, {len(gaps)} gaps")


if __name__ == "__main__":
    main()
