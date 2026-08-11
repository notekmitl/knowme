"""Inspectable PR #89 V1.4 Known/Unknown canonical-text audit."""

from __future__ import annotations

import argparse
import csv
import json
import re
from difflib import SequenceMatcher
from pathlib import Path

THRESHOLD = 0.72

STRUCTURAL_EXACT = {
    "KnowMe — รายงานโหราไทย",
    "รายงานฉบับสำหรับอ่านและบันทึกส่วนตัว",
    "ดูช่วงที่ผ่านมา ช่วงปัจจุบัน และช่วงข้างหน้า เพื่อเข้าใจจังหวะชีวิตในภาพรวม",
    "ลองเทียบแต่ละช่วงกับเหตุการณ์และความรู้สึกที่เกิดขึ้นจริง",
    "คุณอยู่ช่วงไหนของชีวิต",
    "แนวโน้มชีวิตในระยะข้างหน้า",
    "อ่านอนาคตเป็นสามระดับ: ช่วงนี้ 12 เดือนข้างหน้า และจุดเปลี่ยนชีวิตถัดไป แต่ละช่วงแยกการงาน การเงิน ความรัก และสุขภาพให้เห็นตรง ๆ",
    "แนวโน้ม 12 เดือนข้างหน้า",
    "คำแนะนำปิดท้ายช่วงถัดไป",
    "ดูภาพรวมของช่วงถัดไป เพื่อเตรียมสิ่งสำคัญไว้ล่วงหน้า",
    "ข้อมูลวัน เวลา และสถานที่เกิด",
    "วิธีนับวันทางโหราศาสตร์ไทย",
    "คำอ่านข้างต้นจัดลำดับจากแนวโน้มที่มีน้ำหนักเด่นในผลวิเคราะห์ แต่ละส่วนจึงอธิบายความหมายที่เกี่ยวกับชีวิตของคุณโดยตรง",
    "ความหมายและข้อจำกัดของผลลัพธ์",
    "นำข้อมูลวันเกิดของคุณมาประมวลผลตามหลักดวงไทย แล้วแปลงเป็นภาษาที่อ่านเข้าใจง่าย โดยไม่แสดงรายละเอียดเชิงเทคนิค",
}

SAFETY_EXACT = {
    "เป็นแนวทางดูตัวเอง ไม่ใช่คำฟันธง — ชีวิตเปลี่ยนได้เสมอตามการกระทำของคุณ",
    "ผลลัพธ์นี้เป็นมุมมองเพื่อทำความเข้าใจตัวเอง ไม่ใช่คำทำนาย",
    "สิ่งที่อ่านอาจตรงหรือไม่ตรงกับตัวคุณทั้งหมด — ใช้เป็นจุดเริ่มสังเกตตัวเอง",
}


def lines(path: Path) -> list[str]:
    return [line.strip() for line in path.read_text(encoding="utf-8").splitlines() if len(line.strip()) >= 20]


def horizon(text: str) -> str:
    if "12 เดือน" in text or "หนึ่งปี" in text or "ตลอดปี" in text or "ปีข้างหน้า" in text:
        return "next_12_months"
    if "ช่วงถัดไป" in text or "ช่วงชีวิตถัดไป" in text or "เปลี่ยนช่วง" in text:
        return "next_life_period"
    if "อดีต" in text or re.search(r"\(\d+[–-]\d+\)", text):
        return "timeline"
    if "ช่วงนี้" in text or "ตอนนี้" in text or "ช่วงปัจจุบัน" in text:
        return "current"
    return "report"


def domain(text: str) -> str:
    checks = [
        ("fortune", ("โชคลาภ", "โชค", "พนัน")),
        ("health", ("สุขภาพ", "พลังชีวิต", "นอน", "พัก", "ความล้า")),
        ("relationship", ("ความรัก", "ความสัมพันธ์", "ข้อตกลง", "ทั้งสองฝ่าย")),
        ("finance", ("การเงิน", "รายรับ", "รายจ่าย", "เงิน")),
        ("work", ("การงาน", "งาน", "บทบาท", "ส่งมอบ")),
    ]
    for name, needles in checks:
        if any(needle in text for needle in needles):
            return name
    return "structure"


def family(text: str) -> str:
    value = text.lower()
    value = re.sub(r"\d+", "#", value)
    for token in ("น้ำ", "ดิน", "ลม", "ไฟ", "การงาน", "การเงิน", "ความรัก", "สุขภาพ"):
        value = value.replace(token, "<slot>")
    value = re.sub(r"\s+", " ", value).strip()
    return value


def classify(left: str, right: str, score: float) -> tuple[str, bool, str]:
    exact = left == right
    if exact and left in STRUCTURAL_EXACT:
        return "structural_boilerplate", True, "Shared report navigation, heading, or explanation; no astrological claim."
    if exact and left in SAFETY_EXACT:
        return "required_safety_text", True, "Mandatory non-deterministic/safety limitation shared verbatim."
    if not exact and re.fullmatch(r"ช่วง.+ \(\d+[–-]\d+\)", left) and re.fullmatch(r"ช่วง.+ \(\d+[–-]\d+\)", right):
        return "structural_boilerplate", True, "Life-period display label shares a canonical phase name but retains different factual age bounds."
    if not exact and left.startswith("ด้านที่มีแรงสนับสนุนในช่วงถัดไป:") and right.startswith("ด้านที่มีแรงสนับสนุนในช่วงถัดไป:"):
        return "structural_boilerplate", True, "Typed next-period support label; the supplied domain set remains inspectable."
    if not exact and left.startswith("ตอนนี้คุณอายุ") and right.startswith("ตอนนี้คุณอายุ"):
        return "supported_shared_evidence", True, "Same civil age is supported in both fixtures; period name, position, and remaining years differ."
    if exact:
        return "substantive_exact", False, "Exact reader-facing line is not an enumerated structural or safety exception."
    if score >= THRESHOLD:
        return "substantive_near_duplicate", False, "Near-identical semantic family is not an enumerated evidence-backed exception."
    return "distinct", True, "Below the semantic review threshold."


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--known", type=Path, required=True)
    parser.add_argument("--unknown", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    known = lines(args.known)
    unknown = lines(args.unknown)
    rows: list[dict[str, object]] = []
    for ki, left in enumerate(known, 1):
        for ui, right in enumerate(unknown, 1):
            score = 1.0 if left == right else SequenceMatcher(None, left, right).ratio()
            classification, permitted, reason = classify(left, right, score)
            rows.append({
                "known_evidence_key": f"known.line.{ki:03d}",
                "unknown_evidence_key": f"unknown.line.{ui:03d}",
                "domain": domain(left) if domain(left) == domain(right) else f"{domain(left)}|{domain(right)}",
                "horizon": horizon(left) if horizon(left) == horizon(right) else f"{horizon(left)}|{horizon(right)}",
                "source_ownership": "shared-structure" if classification in {"structural_boilerplate", "required_safety_text"} else "known-vs-unknown",
                "normalized_semantic_family": family(left) if family(left) == family(right) else f"{family(left)} || {family(right)}",
                "similarity_score": round(score, 6),
                "classification": classification,
                "permitted": permitted,
                "reason": reason,
                "known_text": left,
                "unknown_text": right,
            })
    args.output.mkdir(parents=True, exist_ok=True)
    json_path = args.output / "cross-fixture-audit.json"
    csv_path = args.output / "cross-fixture-audit.csv"
    json_path.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with csv_path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    reviewed = [row for row in rows if row["similarity_score"] >= THRESHOLD]
    exact = [row for row in rows if row["similarity_score"] == 1.0]
    violations = [row for row in reviewed if not row["permitted"]]
    summary = {
        "threshold": THRESHOLD,
        "known_lines": len(known),
        "unknown_lines": len(unknown),
        "total_compared_pairs": len(rows),
        "exact_shared_lines": len(exact),
        "near_pairs": len(reviewed) - len(exact),
        "allowed_boilerplate_or_evidence": sum(1 for row in reviewed if row["permitted"]),
        "substantive_violations": len(violations),
        "result": "PASS" if not violations else "FAIL",
    }
    (args.output / "narrative-audit-summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(summary, ensure_ascii=False))
    return 0 if not violations else 1


if __name__ == "__main__":
    raise SystemExit(main())
