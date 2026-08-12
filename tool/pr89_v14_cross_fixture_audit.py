"""Complete PR #89 V1.4 cross-report and within-report narrative audit."""

from __future__ import annotations

import argparse
import csv
import json
import re
from difflib import SequenceMatcher
from itertools import combinations
from pathlib import Path

THRESHOLD = 0.72
CLAUSE_THRESHOLD = 0.58
MIN_LINE = 20
MIN_CLAUSE = 18

ADVICE_CONCEPTS = (
    "ค่าใช้จ่าย",
    "ภาระระยะยาว",
    "ผูกพัน",
    "ตารางชีวิต",
    "ร่วมกัน",
    "วันทำงาน",
    "วันพัก",
    "ทดลอง",
    "จำลอง",
)

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
    "การงานจากลัคนาและเรือนการงาน — ไม่มีเวลาเกิด จึงคำนวณลัคนาและเรือนที่ใช้วิเคราะห์หัวข้อนี้ไม่ได้",
    "การเงินจากลัคนาและเรือนการเงิน — ไม่มีเวลาเกิด จึงคำนวณลัคนาและเรือนที่ใช้วิเคราะห์หัวข้อนี้ไม่ได้",
    "ความรักและความสัมพันธ์จากลัคนาและเรือนคู่ครอง — ไม่มีเวลาเกิด จึงคำนวณลัคนาและเรือนที่ใช้วิเคราะห์หัวข้อนี้ไม่ได้",
    "สุขภาพและพลังชีวิตจากลัคนาและเรือนสุขภาพ — ไม่มีเวลาเกิด จึงคำนวณลัคนาและเรือนที่ใช้วิเคราะห์หัวข้อนี้ไม่ได้",
}


def records(path: Path, fixture: str) -> list[dict[str, object]]:
    return [
        {"fixture": fixture, "line": number, "text": text.strip()}
        for number, text in enumerate(path.read_text(encoding="utf-8").splitlines(), 1)
        if len(text.strip()) >= MIN_LINE
    ]


def horizon(text: str) -> str:
    if any(token in text for token in ("12 เดือน", "หนึ่งปี", "ตลอดปี", "ปีข้างหน้า")):
        return "next_12_months"
    if any(token in text for token in ("ช่วงถัดไป", "ช่วงชีวิตถัดไป", "เปลี่ยนช่วง")):
        return "next_life_period"
    if "อดีต" in text or re.search(r"\(\d+[–-]\d+\)", text):
        return "timeline"
    if any(token in text for token in ("ช่วงนี้", "ตอนนี้", "ช่วงปัจจุบัน")):
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
    return next((name for name, needles in checks if any(token in text for token in needles)), "structure")


def family(text: str) -> str:
    value = re.sub(r"\d+", "#", text.lower())
    for token in ("น้ำ", "ดิน", "ลม", "ไฟ", "การงาน", "การเงิน", "ความรัก", "สุขภาพ"):
        value = value.replace(token, "<slot>")
    return re.sub(r"\s+", " ", value).strip()


def classify(left: str, right: str, score: float) -> tuple[str, bool, str]:
    exact = left == right
    if exact and left in STRUCTURAL_EXACT:
        return "structural_boilerplate", True, "Explicitly enumerated navigation, heading, or report explanation."
    if exact and left in SAFETY_EXACT:
        return "required_safety_text", True, "Explicitly enumerated mandatory safety limitation."
    if left in SAFETY_EXACT and right in SAFETY_EXACT:
        return "required_safety_text", True, "Pair of explicitly enumerated fail-closed omission lines."
    if not exact and re.fullmatch(r"ช่วง.+ \(\d+[–-]\d+\)", left) and re.fullmatch(r"ช่วง.+ \(\d+[–-]\d+\)", right):
        return "structural_boilerplate", True, "Canonical phase label with different factual age bounds."
    if not exact and left.startswith("ด้านที่มีแรงสนับสนุนในช่วงถัดไป:") and right.startswith("ด้านที่มีแรงสนับสนุนในช่วงถัดไป:"):
        return "structural_boilerplate", True, "Typed support label with inspectable domain values."
    if not exact and left.startswith("ตอนนี้คุณอายุ") and right.startswith("ตอนนี้คุณอายุ"):
        return "supported_shared_evidence", True, "Shared civil age with different period facts."
    if exact:
        return "substantive_exact", False, "Unenumerated reader-visible exact repetition."
    if score >= THRESHOLD:
        return "substantive_near_duplicate", False, "Near-identical semantic family without an enumerated exception."
    return "distinct", True, "Below the review threshold."


def pair_row(scope: str, left: dict[str, object], right: dict[str, object]) -> dict[str, object]:
    left_text, right_text = str(left["text"]), str(right["text"])
    score = 1.0 if left_text == right_text else SequenceMatcher(None, left_text, right_text).ratio()
    classification, permitted, reason = classify(left_text, right_text, score)
    return {
        "scope": scope,
        "left_location": f"{left['fixture']}.line.{int(left['line']):03d}",
        "right_location": f"{right['fixture']}.line.{int(right['line']):03d}",
        "domain": domain(left_text) if domain(left_text) == domain(right_text) else f"{domain(left_text)}|{domain(right_text)}",
        "horizon": horizon(left_text) if horizon(left_text) == horizon(right_text) else f"{horizon(left_text)}|{horizon(right_text)}",
        "normalized_semantic_family": family(left_text) if family(left_text) == family(right_text) else f"{family(left_text)} || {family(right_text)}",
        "similarity_score": round(score, 6),
        "classification": classification,
        "permitted": permitted,
        "reason": reason,
        "left_text": left_text,
        "right_text": right_text,
    }


def clause_rows(items: list[dict[str, object]]) -> list[dict[str, object]]:
    output: list[dict[str, object]] = []
    for item in items:
        text = str(item["text"])
        clauses = [part.strip(" —–-,:;") for part in re.split(r"[\n.!?]+|\s{1,}", text) if len(part.strip(" —–-,:;")) >= MIN_CLAUSE]
        for left_index, right_index in combinations(range(len(clauses)), 2):
            left, right = clauses[left_index], clauses[right_index]
            score = 1.0 if left == right else SequenceMatcher(None, family(left), family(right)).ratio()
            left_concepts = {token for token in ADVICE_CONCEPTS if token in left}
            right_concepts = {token for token in ADVICE_CONCEPTS if token in right}
            shared_concepts = left_concepts & right_concepts
            repeats_advice_stem = len(shared_concepts) >= 2
            if score < CLAUSE_THRESHOLD and not repeats_advice_stem:
                continue
            permitted = left == right and left in STRUCTURAL_EXACT | SAFETY_EXACT
            output.append({
                "scope": f"{item['fixture']}_same_paragraph",
                "left_location": f"{item['fixture']}.line.{int(item['line']):03d}.clause.{left_index + 1}",
                "right_location": f"{item['fixture']}.line.{int(item['line']):03d}.clause.{right_index + 1}",
                "domain": domain(text),
                "horizon": horizon(text),
                "normalized_semantic_family": f"{family(left)} || {family(right)}",
                "similarity_score": round(max(score, CLAUSE_THRESHOLD) if repeats_advice_stem else score, 6),
                "classification": "allowed_boilerplate" if permitted else "same_paragraph_duplicate_clause",
                "permitted": permitted,
                "reason": "Explicitly enumerated boilerplate." if permitted else (
                    "Two clauses repeat an advice stem: " + ", ".join(sorted(shared_concepts))
                    if repeats_advice_stem else
                    "Two clauses in one reader-visible passage repeat the same instruction or semantic stem."
                ),
                "left_text": left,
                "right_text": right,
            })
    return output


def scope_counts(rows: list[dict[str, object]], scope: str) -> dict[str, int]:
    selected = [row for row in rows if row["scope"] == scope and float(row["similarity_score"]) >= THRESHOLD]
    exact = sum(float(row["similarity_score"]) == 1.0 for row in selected)
    return {"exact": exact, "near": len(selected) - exact,
            "allowed": sum(bool(row["permitted"]) for row in selected),
            "violations": sum(not bool(row["permitted"]) for row in selected)}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--known", type=Path, required=True)
    parser.add_argument("--unknown", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    known, unknown = records(args.known, "known"), records(args.unknown, "unknown")
    rows = [pair_row("cross_fixture", left, right) for left in known for right in unknown]
    rows += [pair_row("known_internal", left, right) for left, right in combinations(known, 2)]
    rows += [pair_row("unknown_internal", left, right) for left, right in combinations(unknown, 2)]
    clauses = clause_rows(known) + clause_rows(unknown)
    rows += clauses
    violations = [row for row in rows if not row["permitted"] and (
        float(row["similarity_score"]) >= THRESHOLD or row["classification"] == "same_paragraph_duplicate_clause")]
    summary = {
        "line_similarity_threshold": THRESHOLD,
        "same_paragraph_clause_threshold": CLAUSE_THRESHOLD,
        "known_lines": len(known),
        "unknown_lines": len(unknown),
        "comparison_scopes": {
            scope: scope_counts(rows, scope)
            for scope in ("cross_fixture", "known_internal", "unknown_internal")
        },
        "same_paragraph_duplicate_clauses": sum(row["classification"] == "same_paragraph_duplicate_clause" for row in clauses),
        "allowed_boilerplate": sum(bool(row["permitted"]) and float(row["similarity_score"]) >= THRESHOLD for row in rows),
        "substantive_violations": len(violations),
        "result": "PASS" if not violations else "FAIL",
    }
    args.output.mkdir(parents=True, exist_ok=True)
    json_path = args.output / "complete-narrative-audit.json"
    csv_path = args.output / "complete-narrative-audit.csv"
    json_path.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with csv_path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    (args.output / "narrative-audit-summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False))
    return 0 if not violations else 1


if __name__ == "__main__":
    raise SystemExit(main())
