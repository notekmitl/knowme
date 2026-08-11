#!/usr/bin/env python3
"""Compare Flutter JSON reporter failures for PR #89's baseline-delta gate."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
from pathlib import Path
from urllib.parse import unquote, urlparse


BASELINE_SHA = "23fe2c2fc8a9c5089e7e39b920acb01526fde308"


def normalize_text(value: str) -> str:
    value = value.replace("\\", "/")
    value = re.sub(r"file:///C:/Users/USER/Documents/Knowme/[^/]+/", "file:///<WORKTREE>/", value, flags=re.I)
    value = re.sub(r"C:/Users/USER/Documents/Knowme/[^/]+/", "<WORKTREE>/", value, flags=re.I)
    return re.sub(r"\s+", " ", value).strip()


def relative_test_path(url: str) -> str:
    path = unquote(urlparse(url).path).replace("\\", "/")
    marker = "/test/"
    if marker not in path:
        raise ValueError(f"Test URL has no /test/ segment: {url}")
    return "test/" + path.split(marker, 1)[1]


def category(path: str) -> str:
    if any(token in path for token in (
        "test/human_coverage/", "test/human_semantics/",
        "human_pattern_activation_audit_test.dart",
        "narrative_runtime/narrative_intelligence_v2_test.dart",
    )):
        return "human-pattern coverage/semantics"
    if any(token in path for token in (
        "thai_mirror_pre_user_qa_validation_test.dart", "b1_engine_test.dart",
        "test/thai_v2/", "thai_mirror_qa_test.dart", "fusion_repair_export_test.dart",
    )):
        return "Thai engine/fact/QA consistency"
    if any(token in path for token in (
        "thai_mirror_consumer_presenter_test.dart", "thai_mirror_ui_v1b_test.dart",
        "thai_mirror_timeline_ui_test.dart",
    )):
        return "UI/export harness"
    if any(token in path for token in (
        "thai_mirror_content_diversity/", "thai_mirror_consumer_ux/", "test/widget_test.dart",
    )):
        return "consumer diversity/UX/golden harness"
    return "unclassified"


def parse_log(path: Path) -> tuple[dict[str, dict], dict]:
    tests: dict[int, dict] = {}
    errors: dict[int, list[dict]] = {}
    done: dict[int, dict] = {}
    discovered = 0
    passed = failed = skipped = 0
    max_time = 0
    with path.open(encoding="utf-8") as source:
        for line_no, line in enumerate(source, 1):
            if not line.strip():
                continue
            event = json.loads(line)
            max_time = max(max_time, int(event.get("time", 0)))
            event_type = event.get("type")
            if event_type == "testStart":
                test = event["test"]
                tests[int(test["id"])] = test
                discovered += 1
            elif event_type == "error":
                errors.setdefault(int(event["testID"]), []).append(event)
            elif event_type == "testDone":
                test_id = int(event["testID"])
                done[test_id] = event
                if event.get("hidden"):
                    continue
                if event.get("skipped"):
                    skipped += 1
                elif event.get("result") == "success":
                    passed += 1
    failed = len(errors)
    failures: dict[str, dict] = {}
    for test_id, event_errors in errors.items():
        test = tests[test_id]
        test_url = test.get("root_url") or test["url"]
        path_value = relative_test_path(test_url)
        identity = f"{path_value}::{test['name']}"
        error_text = "\n---\n".join(item.get("error", "") for item in event_errors)
        stack_text = "\n---\n".join(item.get("stackTrace", "") for item in event_errors)
        normalized_error = normalize_text(error_text)
        normalized_stack = normalize_text(stack_text)
        stack_location = ""
        matches = re.findall(r"(test/[^\s:]+\.dart)\s+(\d+):(\d+)", stack_text.replace("\\", "/"))
        match = next((item for item in matches if not item[0].startswith("test/src/")), None)
        if match:
            stack_location = f"{match[0]}:{match[1]}:{match[2]}"
        signature_source = normalized_error + "\n" + stack_location
        failures[identity] = {
            "test_file": path_value,
            "complete_test_name": test["name"],
            "stable_test_identity": identity,
            "root_cause_category": category(path_value),
            "failure_message": error_text,
            "normalized_failure_signature": hashlib.sha256(signature_source.encode()).hexdigest().upper(),
            "expected_vs_actual_summary": normalized_error,
            "relevant_stack_location": stack_location,
            "normalized_stack": normalized_stack,
            "evidence_path": str(path.resolve()),
        }
    return failures, {
        "discovered": discovered, "passed": passed, "failed": failed,
        "skipped": skipped, "duration_seconds": round(max_time / 1000, 3),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--csv", type=Path, required=True)
    args = parser.parse_args()
    baseline, baseline_counts = parse_log(args.baseline)
    candidate, candidate_counts = parse_log(args.candidate)
    identities = sorted(set(baseline) | set(candidate))
    rows = []
    for identity in identities:
        clean = baseline.get(identity)
        current = candidate.get(identity)
        record = dict(clean or current)
        if clean and current:
            same_error = clean["expected_vs_actual_summary"] == current["expected_vs_actual_summary"]
            same_location = clean["relevant_stack_location"] == current["relevant_stack_location"]
            classification = "baseline_failure_still_failing_unchanged" if same_error and same_location else "baseline_failure_worsened_or_changed"
            worsened = not (same_error and same_location)
            disposition = "permitted baseline debt" if not worsened else "block delivery"
            reason = "same test identity, expected/actual summary, and stack location" if not worsened else "failure detail differs from clean baseline"
        elif clean:
            classification = "baseline_failure_now_passing"
            worsened = False
            disposition = "improved under V1.4"
            reason = "failed only at clean baseline"
        else:
            classification = "new_v1_4_failure"
            worsened = True
            disposition = "block delivery"
            reason = "failed only under V1.4"
        record.update({
            "clean_baseline_result": "failed" if clean else "passed",
            "v1_4_result": "failed" if current else "passed",
            "classification": classification,
            "v1_4_worsened": worsened,
            "disposition": disposition,
            "reason": reason,
            "clean_evidence_path": str(args.baseline.resolve()),
            "v1_4_evidence_path": str(args.candidate.resolve()),
        })
        rows.append(record)
    summary = {
        "schema": "pr89-v14-baseline-delta-v1",
        "baseline_sha": BASELINE_SHA,
        "baseline_counts": baseline_counts,
        "v1_4_counts": candidate_counts,
        "clean_head_failures": len(baseline),
        "v1_4_failures": len(candidate),
        "new_v1_4_failures": sum(r["classification"] == "new_v1_4_failure" for r in rows),
        "baseline_failures_still_failing_unchanged": sum(r["classification"] == "baseline_failure_still_failing_unchanged" for r in rows),
        "baseline_failures_now_passing": sum(r["classification"] == "baseline_failure_now_passing" for r in rows),
        "worsened_or_changed_failures": sum(r["classification"] == "baseline_failure_worsened_or_changed" for r in rows),
        "unclassified_failures": sum(r["root_cause_category"] == "unclassified" for r in rows if r["v1_4_result"] == "failed"),
        "remaining_category_counts": {},
    }
    for row in rows:
        if row["v1_4_result"] == "failed":
            name = row["root_cause_category"]
            summary["remaining_category_counts"][name] = summary["remaining_category_counts"].get(name, 0) + 1
    summary["gate_pass"] = (
        summary["clean_head_failures"] == 40
        and summary["v1_4_failures"] == 39
        and summary["new_v1_4_failures"] == 0
        and summary["baseline_failures_still_failing_unchanged"] == 39
        and summary["baseline_failures_now_passing"] == 1
        and summary["worsened_or_changed_failures"] == 0
        and summary["unclassified_failures"] == 0
        and summary["remaining_category_counts"] == {
            "human-pattern coverage/semantics": 7,
            "Thai engine/fact/QA consistency": 11,
            "UI/export harness": 6,
            "consumer diversity/UX/golden harness": 15,
        }
    )
    payload = {"summary": summary, "failures": rows}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    fields = list(rows[0])
    with args.csv.open("w", encoding="utf-8-sig", newline="") as target:
        writer = csv.DictWriter(target, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0 if summary["gate_pass"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
