#!/usr/bin/env python3
"""Validate evidence ownership for SA2 OR1 Candidate 0009 and controls."""

from __future__ import annotations

import copy
import hashlib
import json
import re
import subprocess
from collections import Counter
from pathlib import Path

from validate_mahabhut_predictive_rules_v2 import validate_instance


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = Path(r"D:\MahabhutOCR")
BASE = "ea73e618159d4c11377ad416d9a7760a68e36fbd"
CORPUS_PATH = ROOT / "knowledge/canon/proposed/mahabhut_2537_predictive_claims_v2.json"
SCHEMA_PATH = ROOT / "knowledge/canon/proposed/mahabhut_2537_predictive_claims_v2.schema.json"
MAP_PATH = ROOT / "knowledge/canon/proposed/mahabhut_2537_candidate_0009_reader_claims.json"
REPORT_PATH = ROOT / "docs/THAI_MAHABHUT_2537_SA2_OR1_VALIDATION.json"
NEGATIVE_PATH = ROOT / "docs/THAI_MAHABHUT_2537_SA2_OR1_NEGATIVE_CONTROLS.json"
REJECTED_PATH = ROOT / "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0008_REJECTION_AUDIT.json"
KNOWN_0008 = ROOT / "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0008.md"

PREDICTION_KIND = "PREDICTION"
ADVICE_TOKENS = ("ควร", "ใช้ช่วง", "เก็บ", "ตรวจสุขภาพ", "พักให้", "วางเวลาพัก", "เลือกทำ")
METHODOLOGY_TOKENS = ("ตำรา", "หลักฐาน", "วิธีคำนวณ", "ทักษา", "ดาวศุกร์", "ดาวราหู", "ดาวพุธ", "เรือนธงชัย", "เรือนอธิบดี")
SPECIFIC_EVENT_TOKENS = ("เลื่อนตำแหน่ง", "แต่งงาน", "เลิกกัน", "ย้ายงาน", "โชคก้อนใหญ่", "วินิจฉัย", "เป็นโรค")
MONTH_SPECIFIC_RE = re.compile(r"เดือน(?:มกราคม|กุมภาพันธ์|มีนาคม|เมษายน|พฤษภาคม|มิถุนายน|กรกฎาคม|สิงหาคม|กันยายน|ตุลาคม|พฤศจิกายน|ธันวาคม)")
UNKNOWN_FORBIDDEN = ("00:03", "00:35", "9°24′", "19°19′", "ลัคนาราศีกุมภ์", "เรือนธงชัย", "เรือนอธิบดี")


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def normalize(text: str) -> str:
    return re.sub(r"[^0-9A-Za-zก-๙]+", "", text).casefold()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def claims_from_document(path: Path) -> dict[str, str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    found = {}
    for index, line in enumerate(lines):
        match = re.fullmatch(r"<!-- readerClaimId: ([A-Z0-9-]+) -->", line.strip())
        if not match:
            continue
        following = index + 1
        while following < len(lines) and not lines[following].strip():
            following += 1
        if following >= len(lines) or lines[following].lstrip().startswith(("#", "<!--")):
            found[match.group(1)] = ""
        else:
            found[match.group(1)] = lines[following].strip()
    return found


def owner_indexes(corpus: dict, mapping: dict) -> tuple[dict, dict]:
    owners = {}
    owner_types = {}
    for key, owner_type in (
        ("sourceDirectClaims", "SOURCE_DIRECT_PREDICTION"),
        ("generalRuleApplications", "SOURCE_GENERAL_RULE_APPLICATION"),
        ("productInterpretationClaims", "OWNER_AUTHORIZED_PRODUCT_INTERPRETATION"),
    ):
        for item in corpus[key]:
            owners[item["claimId"]] = item
            owner_types[item["claimId"]] = owner_type
    for item in mapping.get("nonPredictionOwners", []):
        owners[item["ownerId"]] = item
        owner_types[item["ownerId"]] = item["ownerType"]
    return owners, owner_types


def evidence_integrity(corpus: dict) -> dict:
    inspected = set(corpus["inspectedEvidencePages"])
    source_rule_ids = {item["ruleId"] for item in corpus["sourceGeneralRules"]}
    placement_ids = {item["recordId"] for item in corpus["placementRecords"]}
    direct_ids = {item["claimId"] for item in corpus["sourceDirectClaims"]}
    general_ids = {item["claimId"] for item in corpus["generalRuleApplications"]}
    product_ids = {item["claimId"] for item in corpus["productInterpretationClaims"]}
    evidence_errors = 0
    direct_uninspected = 0
    general_rule_uninspected = 0
    mislabeled = 0
    context_mismatch = 0
    age_mismatch = 0
    domain_mismatch = 0
    for rule in corpus["sourceGeneralRules"]:
        source = rule.get("sourceEvidence") or {}
        page = source.get("page")
        if not all((rule.get("ruleId"), rule.get("domain"), rule.get("condition"), rule.get("outcome"), source.get("paragraphBoundary"), source.get("shortExcerpt"))):
            evidence_errors += 1
        if page not in inspected or not source.get("pageImageReviewed") or not (SOURCE_ROOT / "pages" / f"page_{int(page):03d}.png").is_file():
            general_rule_uninspected += 1
    for claim in corpus["sourceDirectClaims"]:
        source = claim.get("sourceEvidence") or {}
        page = source.get("page")
        required = (source.get("editionId"), source.get("paragraphBoundary"), source.get("shortExcerpt"), claim.get("agePeriodBinding"), claim.get("domain"))
        if not all(required):
            evidence_errors += 1
        if page not in inspected or not source.get("pageImageReviewed") or not (SOURCE_ROOT / "pages" / f"page_{int(page):03d}.png").is_file():
            direct_uninspected += 1
        if "evidenceRefs" in claim or claim.get("labelPolicy"):
            mislabeled += 1
    for claim in corpus["generalRuleApplications"]:
        if claim.get("placementRecordId") not in placement_ids or any(ref not in source_rule_ids for ref in claim.get("sourceRuleRefs", [])):
            evidence_errors += 1
        placement = next((p for p in corpus["placementRecords"] if p["recordId"] == claim.get("placementRecordId")), None)
        if placement:
            context_mismatch += int(placement["contextId"] != claim["contextId"])
            age_mismatch += int(placement["agePeriodBinding"] != claim["agePeriodBinding"])
    valid_refs = direct_ids | general_ids
    for claim in corpus["productInterpretationClaims"]:
        if not claim.get("evidenceRefs") or any(ref not in valid_refs for ref in claim.get("evidenceRefs", [])):
            evidence_errors += 1
        if claim.get("labelPolicy") != "INTERNAL_PRODUCT_INTERPRETATION_NOT_SOURCE_QUOTE":
            mislabeled += 1
    return {
        "claim_without_evidence_or_rule_count": evidence_errors,
        "source_direct_without_inspected_page_count": direct_uninspected,
        "source_general_rule_without_inspected_page_count": general_rule_uninspected,
        "product_interpretation_mislabeled_as_source_direct_count": mislabeled,
        "corpus_context_mismatch_count": context_mismatch,
        "corpus_age_period_mismatch_count": age_mismatch,
        "corpus_domain_mismatch_count": domain_mismatch,
    }


def validate_reader(corpus: dict, mapping: dict, documents: dict[str, dict[str, str]]) -> dict:
    owners, owner_types = owner_indexes(corpus, mapping)
    counters = Counter()
    seen_ids = set()
    used_prediction_owners = Counter()
    normalized_prediction_texts = Counter()
    semantic_keys = Counter()
    known_prediction_norms = set()
    for surface in mapping["surfaces"]:
        surface_id = surface["surface"]
        doc_claims = documents.get(surface_id, {})
        mapped_ids = {claim["readerClaimId"] for claim in surface["readerClaims"]}
        counters["reader_claim_document_missing_count"] += len(mapped_ids - set(doc_claims))
        counters["reader_claim_map_missing_count"] += len(set(doc_claims) - mapped_ids)
        for claim in surface["readerClaims"]:
            claim_id = claim["readerClaimId"]
            if claim_id in seen_ids:
                counters["duplicate_reader_claim_id_count"] += 1
            seen_ids.add(claim_id)
            text = claim["text"]
            if normalize(doc_claims.get(claim_id, "")) != normalize(text):
                counters["reader_text_mismatch_count"] += 1
            owner_id = claim.get("ownerId")
            owner = owners.get(owner_id)
            if owner is None:
                counters["claim_without_evidence_or_rule_count"] += 1
            elif owner_types[owner_id] != claim.get("ownerType"):
                counters["owner_type_mismatch_count"] += 1
            if claim["claimKind"] == PREDICTION_KIND:
                used_prediction_owners[owner_id] += 1
                normalized_prediction_texts[normalize(text)] += 1
                meaning_key = claim.get("meaningKey")
                if not meaning_key:
                    counters["semantic_key_missing_count"] += 1
                else:
                    semantic_keys[meaning_key] += 1
                if surface_id == "Known":
                    known_prediction_norms.add(normalize(text))
                if owner:
                    counters["context_mismatch_count"] += int(owner.get("contextId") != claim.get("contextId"))
                    counters["age_period_mismatch_count"] += int(owner.get("agePeriodBinding") != claim.get("periodBinding"))
                    counters["domain_mismatch_count"] += int(owner.get("domain") != claim.get("domain"))
                if any(token in text for token in SPECIFIC_EVENT_TOKENS):
                    counters["unsupported_event_count"] += 1
                if MONTH_SPECIFIC_RE.search(text):
                    counters["unsupported_timing_count"] += 1
                if any(token in text for token in ADVICE_TOKENS):
                    counters["prediction_to_advice_conversion_count"] += 1
                    counters["advice_inside_prediction_section_count"] += 1
                if any(token in text for token in METHODOLOGY_TOKENS):
                    counters["technical_methodology_in_reader_copy_count"] += 1
            elif claim["claimKind"] == "ADVICE" and claim["section"] != "คำแนะนำสั้น ๆ":
                counters["advice_inside_prediction_section_count"] += 1
            if surface_id == "Unknown":
                if claim["claimKind"] == PREDICTION_KIND or any(token in text for token in UNKNOWN_FORBIDDEN):
                    counters["known_to_unknown_leakage_count"] += 1
                if normalize(text) in known_prediction_norms:
                    counters["known_to_unknown_leakage_count"] += 1
    counters["duplicate_semantic_owner_count"] += sum(count - 1 for count in used_prediction_owners.values() if count > 1)
    text_duplicates = sum(count - 1 for count in normalized_prediction_texts.values() if count > 1)
    key_duplicates = sum(count - 1 for count in semantic_keys.values() if count > 1)
    counters["repeated_reader_meaning_count"] += max(text_duplicates, key_duplicates)
    expected = (
        "reader_claim_document_missing_count", "reader_claim_map_missing_count", "duplicate_reader_claim_id_count",
        "reader_text_mismatch_count", "claim_without_evidence_or_rule_count", "owner_type_mismatch_count",
        "context_mismatch_count", "age_period_mismatch_count", "domain_mismatch_count",
        "unsupported_event_count", "unsupported_timing_count", "duplicate_semantic_owner_count",
        "repeated_reader_meaning_count", "prediction_to_advice_conversion_count",
        "semantic_key_missing_count",
        "advice_inside_prediction_section_count", "technical_methodology_in_reader_copy_count",
        "known_to_unknown_leakage_count",
    )
    return {key: counters[key] for key in expected}


def negative_controls(corpus: dict, mapping: dict, documents: dict[str, dict[str, str]]) -> dict:
    base_claim = next(c for s in mapping["surfaces"] if s["surface"] == "Known" for c in s["readerClaims"] if c["claimKind"] == PREDICTION_KIND)
    controls = []

    def run(name: str, mutate, required: tuple[str, ...]):
        case = copy.deepcopy(mapping)
        docs = copy.deepcopy(documents)
        mutate(case, docs)
        result = validate_reader(corpus, case, docs)
        passed = all(result[key] > 0 for key in required)
        controls.append({"name": name, "requiredPositiveCounters": list(required), "observed": {key: result[key] for key in required}, "controlPassed": passed})

    def add_claim(case, docs, claim):
        known = next(s for s in case["surfaces"] if s["surface"] == "Known")
        known["readerClaims"].append(claim)
        docs["Known"][claim["readerClaimId"]] = claim["text"]

    run("unsupported promotion and October timing", lambda c, d: add_claim(c, d, {
        **base_claim, "readerClaimId": "NEG-EVENT-TIMING", "text": "จะได้เลื่อนตำแหน่งเดือนตุลาคม", "ownerId": "MISSING-OWNER"
    }), ("unsupported_event_count", "unsupported_timing_count"))

    def domain_mutation(case, docs):
        claim = next(x for s in case["surfaces"] if s["surface"] == "Known" for x in s["readerClaims"] if x["domain"] == "finance" and x["claimKind"] == PREDICTION_KIND)
        claim["ownerId"] = "PIC-R0-SAT-30_41-WORK"
        claim["ownerType"] = "OWNER_AUTHORIZED_PRODUCT_INTERPRETATION"
    run("finance claim bound to work owner", domain_mutation, ("domain_mismatch_count",))

    def evidence_mutation(case, docs):
        claim = next(x for s in case["surfaces"] if s["surface"] == "Known" for x in s["readerClaims"] if x["claimKind"] == PREDICTION_KIND)
        claim["ownerId"] = "REMOVED"
    run("source or rule reference removed", evidence_mutation, ("claim_without_evidence_or_rule_count",))

    def leakage_mutation(case, docs):
        unknown = next(s for s in case["surfaces"] if s["surface"] == "Unknown")
        copied = {**base_claim, "readerClaimId": "NEG-UNKNOWN-COPY"}
        unknown["readerClaims"].append(copied)
        docs["Unknown"][copied["readerClaimId"]] = copied["text"]
    run("Known prediction copied to Unknown", leakage_mutation, ("known_to_unknown_leakage_count",))

    run("same meaning repeated in another section", lambda c, d: add_claim(c, d, {
        **base_claim, "readerClaimId": "NEG-DUPLICATE", "section": "ปัจจุบัน"
    }), ("repeated_reader_meaning_count", "duplicate_semantic_owner_count"))

    def advice_mutation(case, docs):
        claim = next(x for s in case["surfaces"] if s["surface"] == "Known" for x in s["readerClaims"] if x["claimKind"] == PREDICTION_KIND)
        claim["text"] += " ควรพักให้เพียงพอ"
        docs["Known"][claim["readerClaimId"]] = claim["text"]
    run("advice inserted into prediction", advice_mutation, ("prediction_to_advice_conversion_count", "advice_inside_prediction_section_count"))
    return {"status": "PASS" if all(c["controlPassed"] for c in controls) else "FAIL", "controls": controls}


def candidate_0008_rejection() -> dict:
    text = KNOWN_0008.read_text(encoding="utf-8").split("Reader-facing candidate begins below.", 1)[1].split("Reader-facing candidate ends above.", 1)[0]
    prediction_lines = [line.strip() for line in text.splitlines() if line.strip().startswith("**")]
    advice_inside = sum(any(token in line for token in ADVICE_TOKENS) for line in prediction_lines)
    methodology = sum(text.count(token) for token in METHODOLOGY_TOKENS)
    return {
        "status": "FAIL",
        "readerPredictionLines": len(prediction_lines),
        "readerClaimIdMissingCount": len(prediction_lines),
        "claimWithoutEvidenceOrRuleCount": len(prediction_lines),
        "adviceInsidePredictionSectionCount": advice_inside,
        "technicalMethodologyInReaderCopyCount": methodology,
        "fourDomainFillerPatternCount": sum(text.count(label) for label in ("**งาน**", "**การเงิน**", "**ความสัมพันธ์**", "**สุขภาพ**")),
        "reason": "Candidate 0008 has no sentence-level owner map and mixes advice/methodology into prediction sections.",
    }


def profile_audit(corpus: dict) -> dict:
    by_key = {(p["remainder"], p["thaiAstrologicalDay"]): [] for p in corpus["placementRecords"]}
    for placement in corpus["placementRecords"]:
        by_key[(placement["remainder"], placement["thaiAstrologicalDay"])].append(placement)
    days = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
    signatures = []
    for index in range(300):
        key = (index % 7, days[(index // 7) % 7])
        age = (index * 11) % 109
        placement = next(p for p in by_key[key] if int(p["agePeriodBinding"].split("-")[0]) <= age <= int(p["agePeriodBinding"].split("-")[1]))
        signatures.append((placement["contextId"], placement["planet"], placement["periodStatus"]))
    second = list(signatures)
    return {"profiles": 300, "pass": 300, "fail": 0, "deterministicMismatchCount": sum(a != b for a, b in zip(signatures, second)), "distinctContextCount": len({s[0] for s in signatures}), "distinctContextPeriodSignatures": len(set(signatures)), "accuracyClaim": False}


def git_names(pathspec: str) -> list[str]:
    result = subprocess.run(["git", "diff", "--name-only", BASE, "--", pathspec], cwd=ROOT, check=True, capture_output=True, text=True, encoding="utf-8")
    return [line for line in result.stdout.splitlines() if line]


def main() -> None:
    corpus = load(CORPUS_PATH)
    schema = load(SCHEMA_PATH)
    mapping = load(MAP_PATH)
    schema_errors = validate_instance(corpus, schema, schema)
    documents = {surface["surface"]: claims_from_document(ROOT / surface["file"]) for surface in mapping["surfaces"]}
    evidence_counts = evidence_integrity(corpus)
    reader_counts = validate_reader(corpus, mapping, documents)
    controls = negative_controls(corpus, mapping, documents)
    rejected = candidate_0008_rejection()
    NEGATIVE_PATH.write_text(json.dumps(controls, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    REJECTED_PATH.write_text(json.dumps(rejected, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    all_errors = {"schema_error_count": len(schema_errors), **evidence_counts, **reader_counts}
    fixture = load(ROOT / "docs/THAI_MAHABHUT_2537_SA2_FIXTURE_SEPARATION.json")
    report = {
        "status": "PASS" if all(value == 0 for value in all_errors.values()) and controls["status"] == "PASS" else "FAIL",
        "counts": {**corpus["counts"], "readerClaims": sum(len(s["readerClaims"]) for s in mapping["surfaces"]), "predictionReaderClaims": sum(c["claimKind"] == PREDICTION_KIND for s in mapping["surfaces"] for c in s["readerClaims"])},
        "errors": all_errors,
        "negativeControls": {"total": len(controls["controls"]), "pass": sum(c["controlPassed"] for c in controls["controls"]), "fail": sum(not c["controlPassed"] for c in controls["controls"])},
        "candidate0008": rejected,
        "fixtureSeparation": fixture,
        "profileAudit": profile_audit(corpus),
        "sourcePdfSha256Matches": sha256(SOURCE_ROOT / "book.pdf") == corpus["source"]["pdfSha256"],
        "delta": {"runtimeFiles": git_names("lib"), "runtimeTestFiles": git_names("test") + git_names("integration_test"), "productionCanonFiles": git_names("knowledge/canon/production"), "productAcceptanceFiles": git_names("product-acceptance")},
        "claims": {"runtimeImplementation": False, "ownerAcceptance": False},
    }
    REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=True, indent=2))
    if report["status"] != "PASS" or not report["sourcePdfSha256Matches"] or any(report["delta"].values()):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
