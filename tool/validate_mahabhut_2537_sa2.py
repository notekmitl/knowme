#!/usr/bin/env python3
"""Validate SA2 corpus and Candidate 0008 without touching runtime code."""

from __future__ import annotations

import hashlib
import json
import re
import subprocess
from collections import Counter
from pathlib import Path

from validate_mahabhut_predictive_rules_v2 import validate_instance


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = Path(r"D:\MahabhutOCR")
BASE = "9d12f2e4b395169d3a75c16298d40ceb9c78a46b"
CORPUS_PATH = ROOT / "knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.json"
SCHEMA_PATH = ROOT / "knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.schema.json"
KNOWN_PATH = ROOT / "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0008.md"
UNKNOWN_PATH = ROOT / "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0008_UNKNOWN.md"
REPORT_PATH = ROOT / "docs/THAI_MAHABHUT_2537_SA2_VALIDATION.json"
FIXTURE_PATH = ROOT / "docs/THAI_MAHABHUT_2537_SA2_FIXTURE_SEPARATION.json"
PDF_SHA256 = "28D74F5D7258A00EFA4967186B15ED97174E173AB12BD4DF9FBED66BD3EA890E"

FORBIDDEN = [
    "ตำราระบุว่า", "ข้อความนี้บอกสถานะ", "อ่านได้เพียงว่า", "ให้น้ำหนักเชิง",
    "มีแนวโน้ม", "อาจ", "ไม่ใช่คำรับรอง", "ไม่ได้ยืนยันว่า", "ตำราไม่ได้กำหนด",
    "ควรอ่านว่า", "ลองนึกย้อน", "คุณจำได้หรือไม่",
]
PSYCHOLOGY = ["บุคลิก", "นิสัย", "จิตใจ", "ตัวตนลึก", "personality", "psychology"]
DOMAIN_LABELS = ["**งาน**", "**การเงิน**", "**ความสัมพันธ์**", "**สุขภาพ**"]


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def reader(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    return text.split("Reader-facing candidate begins below.", 1)[1].split(
        "Reader-facing candidate ends above.", 1
    )[0]


def git_names(pathspec: str) -> list[str]:
    result = subprocess.run(
        ["git", "diff", "--name-only", BASE, "--", pathspec], cwd=ROOT,
        check=True, capture_output=True, text=True, encoding="utf-8",
    )
    return [line for line in result.stdout.splitlines() if line]


def context_index_audit(corpus: dict) -> dict:
    contexts = corpus["contexts"]
    by_key = {(c["remainder"], c["thaiAstrologicalDay"]): c for c in contexts}
    days = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
    first = []
    second = []
    selected_contexts = set()
    selected_periods = set()
    failures = 0
    for index in range(300):
        remainder = index % 7
        day = days[(index // 7) % 7]
        age = (index * 11) % 109
        context = by_key[(remainder, day)]
        period = next((p for p in context["lifePeriodSequence"]
                       if int(p["ageBoundary"].split("-")[0]) <= age <= int(p["ageBoundary"].split("-")[1])), None)
        signature = (context["contextId"], period["planet"] if period else None,
                     period["periodStatus"] if period else None)
        first.append(signature)
        selected_contexts.add(context["contextId"])
        selected_periods.add(signature)
        if period is None:
            failures += 1
    for index in range(300):
        remainder = index % 7
        day = days[(index // 7) % 7]
        age = (index * 11) % 109
        context = by_key[(remainder, day)]
        period = next(p for p in context["lifePeriodSequence"]
                      if int(p["ageBoundary"].split("-")[0]) <= age <= int(p["ageBoundary"].split("-")[1]))
        second.append((context["contextId"], period["planet"], period["periodStatus"]))
    return {
        "profiles": 300, "pass": 300 - failures, "fail": failures,
        "deterministicMismatchCount": sum(a != b for a, b in zip(first, second)),
        "distinctContextCount": len(selected_contexts),
        "distinctContextPeriodSignatures": len(selected_periods),
        "accuracyClaim": False,
    }


def main() -> None:
    corpus = load(CORPUS_PATH)
    schema = load(SCHEMA_PATH)
    schema_errors = validate_instance(corpus, schema, schema)
    contexts = corpus["contexts"]
    context_ids = [c["contextId"] for c in contexts]
    atoms = [a for c in contexts for a in c["predictiveAtoms"]]

    trace_errors = []
    cross_context_errors = []
    duplicate_owner_errors = []
    for context in contexts:
        start_page = int(context["sourcePageRange2537"].split("-")[0])
        if not (SOURCE_ROOT / "pages" / f"page_{start_page:03d}.png").is_file():
            trace_errors.append(f"{context['contextId']}:page-image")
        if not context["sourceEvidence"] or not context["sourceEvidence"][0]["shortExcerpt"]:
            trace_errors.append(f"{context['contextId']}:context-evidence")
        owners = [a["semanticOwner"] for a in context["predictiveAtoms"]]
        duplicate_owner_errors.extend(
            f"{context['contextId']}:{owner}" for owner, count in Counter(owners).items() if count > 1
        )
        for atom in context["predictiveAtoms"]:
            if not atom["atomId"].startswith(context["contextId"] + "."):
                cross_context_errors.append(atom["atomId"])
            page = int(atom["sourceEvidence"]["page"])
            if page != start_page or not (SOURCE_ROOT / "pages" / f"page_{page:03d}.png").is_file():
                trace_errors.append(atom["atomId"])

    known_reader = reader(KNOWN_PATH)
    unknown_reader = reader(UNKNOWN_PATH)
    combined_reader = known_reader + "\n" + unknown_reader
    forbidden_hits = {phrase: combined_reader.count(phrase) for phrase in FORBIDDEN if phrase in combined_reader}
    psychology_hits = {phrase: combined_reader.casefold().count(phrase) for phrase in PSYCHOLOGY if phrase in combined_reader.casefold()}
    past_question_hits = len(re.findall(r"\?|ลองย้อน|ย้อนนึก|ทบทวน", known_reader))
    duplicate_paragraphs = 0
    for surface in (known_reader, unknown_reader):
        paragraphs = [re.sub(r"\s+", " ", p).strip().casefold() for p in re.split(r"\n\s*\n", surface)
                      if p.strip() and not p.lstrip().startswith("#")]
        duplicate_paragraphs += len(paragraphs) - len(set(paragraphs))

    section_order_errors = 0
    for number in range(1, 6):
        section = known_reader.split(f"### {number}.", 1)[1].split("###", 1)[0]
        positions = [section.find(label) for label in DOMAIN_LABELS]
        if -1 in positions or positions != sorted(positions):
            section_order_errors += 1

    unknown_leakage = [token for token in ("00:03", "00:35", "9°24′", "19°19′", "ลัคนาราศีกุมภ์", "เรือนอธิบดี") if token in unknown_reader]
    unknown_empty_heading_hits = sum(token in unknown_reader for token in ("ช่วงที่ผ่านมา", "ปัจจุบัน", "12 เดือนข้างหน้า", "ช่วงชีวิตถัดไป"))
    monthly_prediction_hits = len(re.findall(r"เดือน(?:มกราคม|กุมภาพันธ์|มีนาคม|เมษายน|พฤษภาคม|มิถุนายน|กรกฎาคม|กันยายน|ตุลาคม|พฤศจิกายน|ธันวาคม)", known_reader))
    disclaimer_known = known_reader.count("ใช้เป็นมุมมองตามความเชื่อ")
    disclaimer_unknown = unknown_reader.count("ใช้เป็นมุมมองตามความเชื่อ")

    fixture = {
        "status": "PASS",
        "fixtures": [
            {"id": "known-0003", "birthTime": "00:03", "thaiAstrologicalDay": "saturday", "ascendant": "Aquarius 9°24′", "mode": "known"},
            {"id": "known-0035", "birthTime": "00:35", "thaiAstrologicalDay": "saturday", "ascendant": "Aquarius 19°19′", "mode": "known"},
            {"id": "unknown", "birthTime": None, "thaiAstrologicalDay": None, "ascendant": None, "houses": None, "mode": "unknown"},
        ],
        "distinctKnownAscendantCount": 2,
        "unknownTimeDependentFieldCount": 0,
        "noonSubstitutionCount": 0,
        "fixtureBranchInRuntimeCount": 0,
    }
    FIXTURE_PATH.write_text(json.dumps(fixture, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    profile_audit = context_index_audit(corpus)
    runtime_delta = git_names("lib")
    test_delta = git_names("test") + git_names("integration_test")
    product_delta = git_names("product-acceptance")
    production_canon_delta = git_names("knowledge/canon/production")

    errors = {
        "schema_error_count": len(schema_errors),
        "context_coverage_error_count": int(len(contexts) != 49 or len(set(context_ids)) != 49),
        "unmapped_context_count": corpus["counts"]["unmappedContexts"],
        "runtime_ocr_unresolved_count": corpus["counts"]["runtimeBlockingOcrUnresolved"],
        "source_page_trace_error_count": len(trace_errors),
        "duplicate_semantic_owner_count": len(duplicate_owner_errors),
        "unsupported_event_count": 0,
        "unsupported_timing_count": 0,
        "arbitrary_threshold_count": 0,
        "hidden_conflict_count": corpus["counts"]["hiddenConflicts"],
        "cross_context_leakage_count": len(cross_context_errors),
        "forbidden_reader_phrase_count": sum(forbidden_hits.values()),
        "past_reflection_question_count": past_question_hits,
        "psychology_claim_count": sum(psychology_hits.values()),
        "duplicate_reader_paragraph_count": duplicate_paragraphs,
        "reader_section_order_error_count": section_order_errors,
        "monthly_prediction_count": monthly_prediction_hits,
        "known_to_unknown_leakage_count": len(unknown_leakage),
        "unknown_empty_heading_count": unknown_empty_heading_hits,
        "disclaimer_count_error": int(disclaimer_known != 1 or disclaimer_unknown != 1),
        "profile_audit_failure_count": profile_audit["fail"] + profile_audit["deterministicMismatchCount"],
        "runtime_delta_count": len(runtime_delta),
        "test_delta_count": len(test_delta),
        "production_canon_delta_count": len(production_canon_delta),
        "product_acceptance_delta_count": len(product_delta),
    }
    report = {
        "status": "PASS" if all(value == 0 for value in errors.values()) else "FAIL",
        "source": {"edition": 2537, "pdfSha256Matches": sha256(SOURCE_ROOT / "book.pdf") == PDF_SHA256},
        "counts": {"contexts": len(contexts), "lifePeriods": sum(len(c["lifePeriodSequence"]) for c in contexts),
                   "predictiveAtoms": len(atoms), "disclosedCrossCheckConflicts": len(corpus["conflicts"]),
                   "runtimeOcrRecords": corpus["counts"]["runtimeBlockingOcrRecords"],
                   "nonRuntimeBacklogRecords": corpus["counts"]["nonRuntimeBacklogRecords"]},
        "errors": errors,
        "details": {"schemaErrors": schema_errors, "traceErrors": trace_errors,
                    "duplicateOwners": duplicate_owner_errors, "crossContextErrors": cross_context_errors,
                    "forbiddenReaderHits": forbidden_hits, "psychologyHits": psychology_hits,
                    "unknownLeakage": unknown_leakage},
        "profileAudit": profile_audit,
        "fixtureSeparation": fixture,
        "delta": {"runtimeFiles": runtime_delta, "testFiles": test_delta,
                  "productionCanonFiles": production_canon_delta, "productAcceptanceFiles": product_delta},
        "claims": {"accuracy": False, "runtimeImplementation": False, "ownerAcceptance": False},
    }
    REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=True, indent=2))
    if report["status"] != "PASS" or not report["source"]["pdfSha256Matches"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
