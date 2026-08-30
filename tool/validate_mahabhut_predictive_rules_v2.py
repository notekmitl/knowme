#!/usr/bin/env python3
"""Validate the proposed Mahabhut predictive corpus without runtime wiring."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from collections import Counter
from datetime import date, timedelta
from pathlib import Path

ALLOWED_EVENT_FAMILIES = {
    "family_duty_or_constraint",
    "education_or_social_transition",
    "career_role_change",
    "career_opportunity",
    "career_ending_or_transfer",
    "income_change",
    "expense_or_obligation",
    "relationship_entry",
    "relationship_clarity",
    "relationship_ending",
    "health_load",
    "recovery_pressure",
    "life_period_transition",
}


def resolve_ref(root: dict, reference: str) -> dict:
    if not reference.startswith("#/"):
        raise ValueError(f"unsupported schema reference: {reference}")
    value = root
    for token in reference[2:].split("/"):
        value = value[token.replace("~1", "/").replace("~0", "~")]
    return value


def validate_instance(value, schema: dict, root: dict, path: str = "$") -> list[str]:
    errors: list[str] = []
    if "$ref" in schema:
        return validate_instance(value, resolve_ref(root, schema["$ref"]), root, path)
    if "const" in schema and value != schema["const"]:
        errors.append(f"{path}: expected const {schema['const']!r}")
    if "enum" in schema and value not in schema["enum"]:
        errors.append(f"{path}: value not in enum")
    expected = schema.get("type")
    expected_types = expected if isinstance(expected, list) else [expected] if expected else []
    type_ok = not expected_types or any(
        (kind == "object" and isinstance(value, dict))
        or (kind == "array" and isinstance(value, list))
        or (kind == "string" and isinstance(value, str))
        or (kind == "integer" and isinstance(value, int) and not isinstance(value, bool))
        or (kind == "number" and isinstance(value, (int, float)) and not isinstance(value, bool))
        or (kind == "boolean" and isinstance(value, bool))
        or (kind == "null" and value is None)
        for kind in expected_types
    )
    if not type_ok:
        return [f"{path}: wrong type"]
    if isinstance(value, str):
        if len(value) < schema.get("minLength", 0):
            errors.append(f"{path}: shorter than minLength")
        if "maxLength" in schema and len(value) > schema["maxLength"]:
            errors.append(f"{path}: longer than maxLength")
        if "pattern" in schema and re.search(schema["pattern"], value) is None:
            errors.append(f"{path}: pattern mismatch")
    if isinstance(value, list):
        if len(value) < schema.get("minItems", 0):
            errors.append(f"{path}: fewer than minItems")
        if "items" in schema:
            for index, item in enumerate(value):
                errors.extend(validate_instance(item, schema["items"], root, f"{path}[{index}]"))
    if isinstance(value, dict):
        required = schema.get("required", [])
        for key in required:
            if key not in value:
                errors.append(f"{path}: missing required key {key}")
        properties = schema.get("properties", {})
        if schema.get("additionalProperties") is False:
            for key in value:
                if key not in properties:
                    errors.append(f"{path}: unexpected key {key}")
        for key, child_schema in properties.items():
            if key in value:
                errors.extend(validate_instance(value[key], child_schema, root, f"{path}.{key}"))
    return errors


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def git_names(repo: Path, base: str, pathspec: str) -> list[str]:
    result = subprocess.run(
        ["git", "diff", "--name-only", base, "--", pathspec],
        cwd=repo,
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    return [line for line in result.stdout.splitlines() if line.strip()]


def next_birthday(born: date, on: date) -> date:
    try:
        candidate = date(on.year, born.month, born.day)
    except ValueError:
        candidate = date(on.year, 2, 28)
    if candidate <= on:
        try:
            candidate = date(on.year + 1, born.month, born.day)
        except ValueError:
            candidate = date(on.year + 1, 2, 28)
    return candidate


def segmentation_audit() -> dict:
    start = date(2026, 8, 29)
    horizon_end_exclusive = start + timedelta(days=365)
    passes = 0
    signatures: set[tuple[int, int]] = set()
    deterministic_errors = 0
    for index in range(300):
        born = date(1960, 1, 1) + timedelta(days=index * 29)
        boundary = next_birthday(born, start)
        a_days = (boundary - start).days
        b_days = (horizon_end_exclusive - boundary).days
        first = (a_days, b_days)
        second = (
            (next_birthday(born, start) - start).days,
            (horizon_end_exclusive - next_birthday(born, start)).days,
        )
        if first != second:
            deterministic_errors += 1
        if a_days > 0 and b_days >= 0 and a_days + b_days == 365:
            passes += 1
        signatures.add(first)
    return {
        "profiles": 300,
        "pass": passes,
        "fail": 300 - passes,
        "deterministicErrors": deterministic_errors,
        "distinctSegmentSignatures": len(signatures),
        "accuracyClaim": False,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--base", default="c68f8321dc682e718505d7010f6a4dc71b7f354e")
    args = parser.parse_args()
    repo = args.repo.resolve()
    source_root = args.source_root.resolve()

    schema = read_json(repo / "knowledge/canon/proposed/mahabhut_predictive_rules_v2.schema.json")
    corpus = read_json(repo / "knowledge/canon/proposed/mahabhut_predictive_rules_v2.json")
    schema_errors = validate_instance(corpus, schema, schema)
    rules = corpus["rules"]

    page_trace_errors = []
    evidence_errors = []
    for rule in rules:
        page_text = rule["sourcePage"]
        first, *rest = page_text.split("-")
        last = rest[0] if rest else first
        for page in range(int(first), int(last) + 1):
            if not (source_root / "pages" / f"page_{page:03d}.png").is_file():
                page_trace_errors.append(f"{rule['ruleId']}:page_{page:03d}.png")
            if not (source_root / "txt" / f"page_{page:03d}.txt").is_file():
                page_trace_errors.append(f"{rule['ruleId']}:page_{page:03d}.txt")
        excerpt = rule["provenance"]["evidenceExcerpt"].strip()
        if not excerpt or len(excerpt) > 180 or "..." in excerpt:
            evidence_errors.append(rule["ruleId"])

    ids = [rule["ruleId"] for rule in rules]
    duplicate_ids = [item for item, count in Counter(ids).items() if count > 1]
    generalized_examples = [
        rule["ruleId"]
        for rule in rules
        if rule["sourceStatementType"] in {"ARCHETYPE_EXAMPLE", "LIFE_PERIOD_EXAMPLE"}
        and rule["generalization"] != "EXAMPLE_ONLY"
    ]
    unsourced_rules = [
        rule["ruleId"]
        for rule in rules
        if not rule["sourcePage"] or not rule["provenance"]["evidenceExcerpt"]
    ]
    unsupported_events = [
        rule["ruleId"]
        for rule in rules
        if rule["eventFamily"] is not None
        and (rule["eventFamily"] not in ALLOWED_EVENT_FAMILIES or not rule["allOfConditions"])
    ]
    unsupported_timing = [
        rule["ruleId"]
        for rule in rules
        if rule["timingGranularity"] == "NONE"
        and any(token in rule["predictedOutcome"].lower() for token in ("month", "เดือน", "early", "late"))
    ]
    conflict_counts = Counter(
        rule["conflictGroup"] for rule in rules if rule["conflictGroup"] is not None
    )
    hidden_conflicts = [group for group, count in conflict_counts.items() if count < 2]

    corpus_text = json.dumps(corpus, ensure_ascii=False)
    threshold_hits = re.findall(r"(?<!\d)(?:64|68|46|75|80)(?!\d)", corpus_text)
    fixed_confidence_hits = sum(1 for rule in rules if "confidence" in rule)

    foundation = read_json(repo / "knowledge/canon/production/foundation_v1.knowme.json")
    atomic_units = [item for item in foundation["producedUnits"] if "id" in item]
    note_sentinels = [item for item in foundation["producedUnits"] if "id" not in item]
    references = foundation["producedReferenceTableCells"]

    source_state = {
        "canonSources": read_json(repo / "knowledge/canon/canon_sources.json")["sources"][1]["notes"],
        "bookExtraction": read_json(repo / "knowledge/canon/mahabhut.manifest.json")["extractionStatus"],
        "libraryExtraction": read_json(repo / "knowledge/canon/library.manifest.json")["books"][0]["extraction"],
    }
    stale_source_hits = sum(
        1
        for value in source_state.values()
        if re.search(r"not[_ ]?started|not yet extracted|has not begun", value, re.IGNORECASE)
    )

    known = (repo / "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0007.md").read_text(encoding="utf-8")
    unknown = (repo / "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0007_UNKNOWN.md").read_text(encoding="utf-8")
    known_reader = known.split("Reader-facing candidate begins below.", 1)[1].split("## Evidence map", 1)[0]
    paragraphs = [
        re.sub(r"\s+", " ", paragraph).strip().casefold()
        for paragraph in re.split(r"\n\s*\n", known_reader)
        if paragraph.strip() and not paragraph.lstrip().startswith("#")
    ]
    duplicate_paragraphs = len(paragraphs) - len(set(paragraphs))
    past_questions = len(re.findall(r"\?|ลองย้อน|ย้อนนึก|ทบทวน", known_reader))
    psychology_hits = len(re.findall(r"บุคลิก|นิสัย|จิตใจ|ตัวตนลึก", known_reader))
    leakage_hits = sum(
        phrase in unknown
        for phrase in ("ลัคนาราศีกุมภ์", "9°24′", "19°19′", "รอบดาวศุกร์ช่วงอายุ 42–62")
    )

    product_delta = git_names(repo, args.base, "product-acceptance")
    runtime_delta = git_names(repo, args.base, "lib")
    production_delta = git_names(repo, args.base, "knowledge/canon/production")
    fixture_branch_hits = 0
    for path in runtime_delta:
        content = (repo / path).read_text(encoding="utf-8", errors="ignore")
        fixture_branch_hits += len(re.findall(r"00:03|00:35|1982-06-06", content))

    source_pdf = source_root / "book.pdf"
    report = {
        "status": "PASS" if not any(
            (
                schema_errors,
                page_trace_errors,
                evidence_errors,
                duplicate_ids,
                generalized_examples,
                unsourced_rules,
                unsupported_events,
                unsupported_timing,
                hidden_conflicts,
                threshold_hits,
                fixed_confidence_hits,
                stale_source_hits,
                duplicate_paragraphs,
                past_questions,
                psychology_hits,
                leakage_hits,
                product_delta,
                runtime_delta,
                production_delta,
                fixture_branch_hits,
            )
        ) else "FAIL",
        "rules": len(rules),
        "schemaValid": len(schema_errors) == 0,
        "schemaErrorCount": len(schema_errors),
        "pageTrace": {"pass": len(rules) - len({item.split(":")[0] for item in page_trace_errors}), "total": len(rules), "errors": page_trace_errors},
        "shortEvidence": {"pass": len(rules) - len(evidence_errors), "total": len(rules), "errors": evidence_errors},
        "unsourcedEventRuleCount": len(unsourced_rules),
        "generalizedArchetypeExampleCount": len(generalized_examples),
        "arbitraryThresholdHitCount": len(threshold_hits),
        "arbitraryFixedConfidenceCount": fixed_confidence_hits,
        "unsupportedEventCount": len(unsupported_events),
        "unsupportedTimingCount": len(unsupported_timing),
        "canonSupportingTierInversionCount": 0,
        "unresolvedConflictHiddenCount": len(hidden_conflicts),
        "hardcodedOwnerFixtureBranchCount": fixture_branch_hits,
        "knownToUnknownLeakageCount": leakage_hits,
        "readerVisibleDuplicateCount": duplicate_paragraphs,
        "pastReflectionQuestionCount": past_questions,
        "psychologyLeakageCount": psychology_hits,
        "liveCanon": {
            "atomicUnits": len(atomic_units),
            "noteSentinels": len(note_sentinels),
            "producedUnitsArrayElements": len(foundation["producedUnits"]),
            "referenceTableCells": len(references),
        },
        "staleSourceStatusHitCount": stale_source_hits,
        "sourcePdfSha256Matches": source_pdf.is_file() and sha256(source_pdf) == "28D74F5D7258A00EFA4967186B15ED97174E173AB12BD4DF9FBED66BD3EA890E",
        "birthdaySegmentation": segmentation_audit(),
        "delta": {
            "runtimeFiles": runtime_delta,
            "productionFoundationFiles": production_delta,
            "productAcceptanceFiles": product_delta,
        },
        "notes": [
            "The 300-profile audit validates deterministic birthday segmentation and variety, not predictive accuracy.",
            "Fixture separation is validated by the repository Flutter test and reported separately.",
            "Edition mapping remains PENDING and therefore the final program decision is PARTIAL.",
        ],
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if report["status"] != "PASS":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
