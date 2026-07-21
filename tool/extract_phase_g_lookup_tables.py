#!/usr/bin/env python3
"""Deterministic Phase G lookup-table extraction from Mahabhut OCR."""

from __future__ import annotations

import json
import re
from pathlib import Path

OCR = Path(r"D:\MahabhutOCR\txt")
OUT_ATOMIC = Path(__file__).resolve().parent / "output" / "phase_g_atomic_units.json"
OUT_REF = Path(__file__).resolve().parent / "output" / "phase_g_reference_cells.json"
BLOCKED = Path(__file__).resolve().parent / "output" / "phase_g_ocr_blocked.json"
GAPS = Path(__file__).resolve().parent / "output" / "phase_g_modeling_gaps.json"

REMAINDER_CHART_P19 = {
    "1": "archetypeChart.kamphra",
    "2": "archetypeChart.naksas",
    "3": "archetypeChart.nakbarihan",
    "4": "archetypeChart.manussachaosamran",
    "5": "archetypeChart.sethi",
    "0": "archetypeChart.mahasethi",
}
REMAINDER_ADJUST = {
    "1": "0",
    "2": "1",
    "3": "2",
    "4": "3",
    "5": "4",
    "6": "5",
    "0": "6",
}
PLACEMENT = {
    "1": [1, 4, 0, 3, 6, 2, 5],
    "2": [2, 5, 1, 4, 0, 3, 6],
    "3": [3, 6, 2, 5, 1, 4, 0],
    "5": [5, 1, 4, 0, 3, 6, 2],
    "6": [6, 2, 5, 1, 4, 0, 3],
    "0": [0, 3, 6, 2, 5, 1, 4],
}
HOUSES = [
    ("phangkha", "เรือนภังคะ"),
    ("marana", "เรือนมรณะ"),
    ("thongchai", "เรือนธงชัย"),
    ("khumsap", "เรือนขุมทรัพย์"),
    ("racha", "เรือนราชา"),
    ("puti", "เรือนปูติ"),
    ("athibodi", "เรือนอธิบดี"),
]

TABLE_TITLE = "คำนวณสำเร็จรูป"
COLUMN_KEY = "เศษ/ดวง"

LOOKUP_ROW_RE = re.compile(
    r"17\s*(?:เม\.?\s*ย\.?|we\.|wwe\.|เมะย\.?)\s*([๐-๙0-9]{4})\s*"
    r"(?:ถึง|fa|£1\)|fia)\s*"
    r"15\s*(?:เม\.?\s*ย\.?|we\.|wwe\.|tne\.|une\.|เม\.?\s*ย,?)\s*([๐-๙0-9]{4})\s*"
    r"[\|\s]*"
    r"([๐-๙0-9])\s+(.+)$"
)
YEAR_LINE_RE = re.compile(r"^([0-9]{4})$")
CELL_LINE_RE = re.compile(r"^([0-9])\s+([\u0E00-\u0E7F].+)$")


def thai_digits(s: str) -> str:
    trans = str.maketrans("๐๑๒๓๔๕๖๗๘๙", "0123456789")
    return s.translate(trans)


def add_atomic(
    units: list[dict],
    *,
    uid: str,
    subject: str,
    relation: str,
    obj: str,
    page: str,
    subject_kind: str = "other",
    object_kind: str = "other",
    condition: str | None = None,
    context_type: str | None = None,
    context_value: str | None = None,
    locator: str | None = None,
    domain: str = "lookupTables",
) -> None:
    unit = {
        "id": uid,
        "subject": subject,
        "subjectKind": subject_kind,
        "relation": relation,
        "object": obj,
        "objectKind": object_kind,
        "domain": domain,
        "page": page,
        **({"condition": condition} if condition else {}),
        **(
            {"context_type": context_type, "context_value": context_value}
            if context_type and context_value
            else {}
        ),
        **({"locator": locator} if locator else {}),
    }
    units.append(unit)


def add_ref(
    cells: list[dict],
    *,
    uid: str,
    table_id: str,
    table_title: str,
    row_key: str,
    column_key: str,
    cell_value: str,
    page: str,
) -> None:
    cells.append(
        {
            "id": uid,
            "tableId": table_id,
            "tableTitle": table_title,
            "rowKey": row_key,
            "columnKey": column_key,
            "cellValue": cell_value,
            "page": page,
        }
    )


def read_page(num: int) -> str:
    path = OCR / f"page_{num:03d}.txt"
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def extract_p19(units: list[dict]) -> None:
    title = "เศษ/ดวง"
    for rem, chart in REMAINDER_CHART_P19.items():
        add_atomic(
            units,
            uid=f"mahabhut.p19.remainder_{rem}_chart",
            subject=f"rotationIndex.remainder{rem}",
            relation="relates_to",
            obj=chart,
            page="19",
            context_type="other",
            context_value=title,
            locator="เศษ/ดวง",
        )
    ctx = "1 ม.ค.–15 เม.ย."
    for src, dst in REMAINDER_ADJUST.items():
        add_atomic(
            units,
            uid=f"mahabhut.p19.adjust_remainder_{src}_to_{dst}",
            subject=f"rotationIndex.remainder{src}",
            relation="relates_to",
            obj=f"rotationIndex.remainder{dst}",
            page="19",
            condition="ลดหนึ่งแต้ม",
            context_type="other",
            context_value=ctx,
            locator="หมายเหตุ",
        )


def extract_p20(units: list[dict], blocked: list[dict]) -> None:
    title = "หลักการวางเลขลงในเรือนดวงชะตา"
    text = read_page(20)
    if "1-4-0-3-6-2-5" not in text.replace(" ", ""):
        blocked.append(
            {
                "page": "20",
                "tableTitle": title,
                "reason": "OCR_BLOCKED: remainder placement sequences unreadable",
            }
        )
        return
    if re.search(r"เศษ\s*4", text) and "625" in text:
        blocked.append(
            {
                "page": "20",
                "tableTitle": title,
                "rowKey": "เศษ 4",
                "reason": "OCR_BLOCKED: เศษ 4 digit sequence corrupted",
            }
        )
    for rem, digits in PLACEMENT.items():
        for (house, house_th), digit in zip(HOUSES, digits):
            add_atomic(
                units,
                uid=f"mahabhut.p20.rem{rem}_{house}_d{digit}",
                subject=f"mahabhutPosition.{house}",
                relation="relates_to",
                obj=f"placementDigit.d{digit}",
                page="20",
                condition=f"เศษ {rem}",
                context_type="other",
                context_value=house_th,
                locator=title,
            )


def normalize_chart_cell(raw: str) -> str | None:
    s = raw.strip()
    s = re.sub(r"\s+", " ", s)
    if not s or len(s) > 40:
        return None
    if re.search(r"[A-Za-z]", s):
        return None
    if not re.search(r"[\u0E00-\u0E7F]{2,}", s):
        return None
    return s


def parse_lookup_line(line: str) -> tuple[str, str, str, str] | None:
    for pat in (LOOKUP_ROW_RE,):
        m = pat.search(line)
        if not m:
            continue
        y1 = thai_digits(m.group(1))
        y2 = thai_digits(m.group(2))
        rem = thai_digits(m.group(3))
        chart = normalize_chart_cell(m.group(4))
        if chart is None:
            return None
        return y1, y2, rem, chart
    return None


def extract_p24_split(cells: list[dict], blocked: list[dict], seen: set[str]) -> None:
    table_id = "lookupTable.birthDateChart"
    text = read_page(24)
    if "เศษ/ดวง" not in text:
        blocked.append(
            {
                "page": "24",
                "tableTitle": TABLE_TITLE,
                "reason": "OCR_BLOCKED: split-column lookup layout unreadable",
            }
        )
        return
    lines = [ln.strip() for ln in text.splitlines()]
    start_years: list[str] = []
    end_years: list[str] = []
    cell_rows: list[tuple[str, str]] = []
    phase = None
    for ln in lines:
        if ln == "เศษ/ดวง":
            phase = "cells"
            continue
        ym = YEAR_LINE_RE.match(thai_digits(ln))
        if ym and phase != "cells":
            if len(start_years) <= len(end_years):
                start_years.append(ym.group(1))
            else:
                end_years.append(ym.group(1))
            continue
        cm = CELL_LINE_RE.match(ln)
        if cm and phase == "cells":
            chart = normalize_chart_cell(cm.group(2))
            if chart:
                cell_rows.append((thai_digits(cm.group(1)), chart))
    if not start_years or not end_years or not cell_rows:
        blocked.append(
            {
                "page": "24",
                "tableTitle": TABLE_TITLE,
                "reason": "OCR_BLOCKED: split-column rows could not be aligned",
            }
        )
        return
    pairs = min(len(start_years), len(end_years), len(cell_rows))
    for i in range(pairs):
        y1, y2 = start_years[i], end_years[i]
        rem, chart = cell_rows[i]
        row_key = f"17 เม.ย. {y1} ถึง 15 เม.ย. {y2}"
        if row_key in seen:
            continue
        seen.add(row_key)
        add_ref(
            cells,
            uid=f"mahabhut.p24.lookup_{y1}_{y2}",
            table_id=table_id,
            table_title=TABLE_TITLE,
            row_key=row_key,
            column_key=COLUMN_KEY,
            cell_value=f"{rem} {chart}",
            page="24",
        )


def extract_lookup_tables(cells: list[dict], blocked: list[dict]) -> None:
    table_id = "lookupTable.birthDateChart"
    seen: set[str] = set()
    extract_p24_split(cells, blocked, seen)
    for page in range(23, 28):
        if page == 24:
            continue
        text = read_page(page)
        for line in text.splitlines():
            line = line.strip()
            if not line.startswith("17"):
                continue
            parsed = parse_lookup_line(line)
            if not parsed:
                if re.search(r"17\s*เม|17\s*we", line) and re.search(r"24[789]|25[0-6]", line):
                    blocked.append(
                        {
                            "page": str(page),
                            "tableTitle": TABLE_TITLE,
                            "rowKey": line[:70],
                            "reason": "OCR_BLOCKED: birth-date lookup row unreadable",
                        }
                    )
                continue
            y1, y2, rem, chart = parsed
            row_key = f"17 เม.ย. {y1} ถึง 15 เม.ย. {y2}"
            if row_key in seen:
                continue
            seen.add(row_key)
            cell_value = f"{rem} {chart}"
            uid = f"mahabhut.p{page}.lookup_{y1}_{y2}"
            add_ref(
                cells,
                uid=uid,
                table_id=table_id,
                table_title=TABLE_TITLE,
                row_key=row_key,
                column_key=COLUMN_KEY,
                cell_value=cell_value,
                page=str(page),
            )


def record_gaps(gaps: list[dict], blocked: list[dict]) -> None:
    gaps.extend(
        [
            {
                "material": "p19 เศษ 6 → ดวง mapping",
                "reason": "Not stated on p19 prose list — not inferred from lookup-table rows",
            },
            {
                "material": "p18 planet dasha ages (Sun, Mercury, Jupiter, Venus)",
                "reason": "OCR_BLOCKED — digits corrupted on p18",
            },
            {
                "material": "p18 planet transit rotation order",
                "reason": "Procedural orbit sequence — not a static lookup cell",
            },
            {
                "material": "p38 Sun/Mon Taksa direction grids",
                "reason": "OCR_BLOCKED — planet tokens not recoverable (Phase C carryover)",
            },
            {
                "material": "p22 split birth-date lookup layout",
                "reason": "Column alignment broken in OCR — rows recovered from pp.23–27 only",
            },
        ]
    )
    blocked.append(
        {
            "page": "18",
            "tableTitle": "กำลังอายุที่ดาวเคราะห์ทั้ง ๘ เสวย",
            "reason": "OCR_BLOCKED: Sun/Mercury/Jupiter/Venus dasha digits corrupted",
        }
    )


def main() -> None:
    units: list[dict] = []
    cells: list[dict] = []
    blocked: list[dict] = []
    gaps: list[dict] = []
    extract_p19(units)
    extract_p20(units, blocked)
    extract_lookup_tables(cells, blocked)
    record_gaps(gaps, blocked)
    OUT_ATOMIC.parent.mkdir(parents=True, exist_ok=True)
    OUT_ATOMIC.write_text(json.dumps(units, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    OUT_REF.write_text(json.dumps(cells, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    BLOCKED.write_text(json.dumps(blocked, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    GAPS.write_text(json.dumps(gaps, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {len(units)} atomic, {len(cells)} reference cells, {len(blocked)} blocked, {len(gaps)} gaps")


if __name__ == "__main__":
    main()
