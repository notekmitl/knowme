#!/usr/bin/env python3
"""Compare exact PR #95 VM/Chrome parity manifests deterministically."""

from __future__ import annotations

import json
import sys
from pathlib import Path


CATEGORIES = {
    "profile": (
        "normalizedInputSignature",
        "birthTimeMode",
        "explicitAsOf",
        "profileEngineFactSignature",
        "presenterContentSeedSignature",
        "presenterSeed",
        "evidenceProfile",
        "mirrorSectionThemeIds",
        "selectionSeedTrace",
    ),
    "structured": ("lifePeriodSignature",),
    "periodScore": ("periodScores", "periodScoreSignature"),
    "report": ("reportSnapshot", "reportSnapshotSha256", "reportHash"),
    "canonical": ("canonicalTextSha256",),
    "narrative": (
        "narrativeParts",
        "narrativeOnlySha256",
        "criticalSections",
        "criticalSectionHashes",
    ),
    "unknownOmission": ("unknownOmission",),
    "copyNormalization": ("copyNormalizationImpact",),
}


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def compare(label: str, left: dict, right: dict) -> dict:
    left_cases = {case["caseId"]: case for case in left["cases"]}
    right_cases = {case["caseId"]: case for case in right["cases"]}
    all_ids = sorted(set(left_cases) | set(right_cases))
    category_ids: dict[str, list[str]] = {name: [] for name in CATEGORIES}
    missing_ids = sorted(set(left_cases) ^ set(right_cases))
    raw_numeric_findings: list[dict] = []
    canonical_degree_mismatch_ids: list[str] = []

    for case_id in all_ids:
        if case_id not in left_cases or case_id not in right_cases:
            continue
        left_case = left_cases[case_id]
        right_case = right_cases[case_id]
        left_numeric = left_case["rawNumericAudit"]
        right_numeric = right_case["rawNumericAudit"]
        if (
            left_numeric["siderealAscendantDeg"]
            != right_numeric["siderealAscendantDeg"]
        ):
            raw_numeric_findings.append(
                {
                    "caseId": case_id,
                    "leftRaw": left_numeric["siderealAscendantDeg"],
                    "rightRaw": right_numeric["siderealAscendantDeg"],
                    "leftCanonicalUnits": left_numeric[
                        "canonicalSiderealAscendantUnits"
                    ],
                    "rightCanonicalUnits": right_numeric[
                        "canonicalSiderealAscendantUnits"
                    ],
                    "leftDisplayedDegree": left_numeric["displayedDegree"],
                    "rightDisplayedDegree": right_numeric["displayedDegree"],
                }
            )
        if (
            left_numeric["canonicalSiderealAscendantUnits"]
            != right_numeric["canonicalSiderealAscendantUnits"]
        ):
            canonical_degree_mismatch_ids.append(case_id)
        for category, fields in CATEGORIES.items():
            if any(left_case[field] != right_case[field] for field in fields):
                category_ids[category].append(case_id)

    canonical_mismatches = []
    left_canonical = {row["fixture"]: row for row in left["canonical"]}
    right_canonical = {row["fixture"]: row for row in right["canonical"]}
    for fixture in sorted(set(left_canonical) | set(right_canonical)):
        if left_canonical.get(fixture) != right_canonical.get(fixture):
            canonical_mismatches.append(fixture)

    metadata_fields = (
        "schema",
        "syntheticSeed",
        "explicitSyntheticAsOf",
        "stableHashVectors",
        "canonicalDegreeVectors",
        "summary",
    )
    metadata_mismatches = [
        field for field in metadata_fields if left[field] != right[field]
    ]
    passed = not (
        missing_ids
        or canonical_degree_mismatch_ids
        or canonical_mismatches
        or metadata_mismatches
        or any(category_ids.values())
    )
    return {
        "comparison": label,
        "leftRuntime": left["runtime"],
        "rightRuntime": right["runtime"],
        "leftRunLabel": left["runLabel"],
        "rightRunLabel": right["runLabel"],
        "executedLeft": len(left_cases),
        "executedRight": len(right_cases),
        "missingCaseIds": missing_ids,
        "rawNumericFindingCount": len(raw_numeric_findings),
        "rawNumericFindings": raw_numeric_findings,
        "canonicalDegreeMismatchCount": len(canonical_degree_mismatch_ids),
        "canonicalDegreeMismatchCaseIds": canonical_degree_mismatch_ids,
        "mismatchCounts": {
            name: len(ids) for name, ids in category_ids.items()
        },
        "mismatchCaseIds": category_ids,
        "canonicalMismatchCount": len(canonical_mismatches),
        "canonicalMismatchFixtures": canonical_mismatches,
        "metadataMismatchCount": len(metadata_mismatches),
        "metadataMismatchFields": metadata_mismatches,
        "pass": passed,
    }


def main() -> int:
    if len(sys.argv) not in (2, 3):
        raise SystemExit(
            "usage: comparator.py EVIDENCE_DIRECTORY [MANIFEST_SUFFIX]"
        )
    evidence = Path(sys.argv[1])
    suffix = f"-{sys.argv[2]}" if len(sys.argv) == 3 else ""
    vm1 = load(evidence / f"cross-runtime-300-vm-run-1{suffix}.json")
    vm2 = load(evidence / f"cross-runtime-300-vm-run-2{suffix}.json")
    chrome1 = load(evidence / f"cross-runtime-300-chrome-run-1{suffix}.json")
    chrome2 = load(evidence / f"cross-runtime-300-chrome-run-2{suffix}.json")
    comparisons = [
        compare("vm-run-1-vs-vm-run-2", vm1, vm2),
        compare("chrome-run-1-vs-chrome-run-2", chrome1, chrome2),
        compare("vm-run-1-vs-chrome-run-1", vm1, chrome1),
        compare("vm-run-2-vs-chrome-run-2", vm2, chrome2),
    ]
    result = {
        "schema": "knowme-v15-cross-runtime-delta-v1",
        "ignoredMetadataFields": ["runtime", "runLabel"],
        "comparisons": comparisons,
        "allComparisonsPass": all(row["pass"] for row in comparisons),
    }
    (evidence / f"cross-runtime-300-delta{suffix}.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    canonical_result = {
        "schema": "knowme-v15-cross-runtime-canonical-delta-v1",
        "fixtures": vm1["canonical"],
        "comparisonMismatchCounts": {
            row["comparison"]: row["canonicalMismatchCount"]
            for row in comparisons
        },
        "allCanonicalComparisonsPass": all(
            row["canonicalMismatchCount"] == 0 for row in comparisons
        ),
    }
    (evidence / f"cross-runtime-canonical-delta{suffix}.json").write_text(
        json.dumps(canonical_result, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    for name, manifest in (("vm", vm1), ("chrome", chrome1)):
        (evidence / f"stable-hash-vectors-{name}{suffix}.json").write_text(
            json.dumps(
                manifest["stableHashVectors"], ensure_ascii=False, indent=2
            )
            + "\n",
            encoding="utf-8",
        )
        (evidence / f"canonical-degree-vectors-{name}{suffix}.json").write_text(
            json.dumps(
                manifest["canonicalDegreeVectors"],
                ensure_ascii=False,
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["allComparisonsPass"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
