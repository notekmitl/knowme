from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent
LOGS = ROOT / "logs"


def read(name: str) -> str:
    return (LOGS / name).read_text(encoding="utf-8-sig", errors="strict")


def failure_ids(text: str) -> set[str]:
    failures: set[str] = set()
    pattern = re.compile(r"^.*?/test/(.*?\.dart): (.*?) \[E\]\s*$", re.MULTILINE)
    for match in pattern.finditer(text.replace("\\", "/")):
        failures.add(f"{match.group(1)} :: {match.group(2)}")
    return failures


def totals(text: str) -> tuple[int, int]:
    matches = re.findall(
        r"\+(\d+) -(\d+): (?:Some tests failed\.|All tests passed!)", text
    )
    if not matches:
        raise RuntimeError("Could not locate final Flutter test totals")
    passed, failed = matches[-1]
    return int(passed), int(failed)


branch_text = read("full-test-branch-final.txt")
main_text = read("full-test-main-final.txt")
branch_failures = failure_ids(branch_text)
main_failures = failure_ids(main_text)
branch_passed, branch_failed = totals(branch_text)
main_passed, main_failed = totals(main_text)
branch_only = sorted(branch_failures - main_failures)
main_only = sorted(main_failures - branch_failures)
common = sorted(branch_failures & main_failures)
passed = not branch_only and branch_failed <= main_failed

(LOGS / "full-test-delta-final.txt").write_text(
    "\n".join(
        [
            "status: PASS — NO BRANCH-ONLY FAILURES AGAINST EXACT MAIN BASELINE"
            if passed
            else "status: BLOCKED — BRANCH ADDS FAILURES AGAINST MAIN",
            f"branchPassed: {branch_passed}",
            f"branchFailed: {branch_failed}",
            f"branchFailureIds: {len(branch_failures)}",
            f"mainPassed: {main_passed}",
            f"mainFailed: {main_failed}",
            f"mainFailureIds: {len(main_failures)}",
            f"commonFailureIds: {len(common)}",
            f"branchOnlyFailureIds: {len(branch_only)}",
            f"mainOnlyFailureIds: {len(main_only)}",
            "",
            "branchOnly:",
            *(branch_only or ["(none)"]),
            "",
            "mainOnly:",
            *(main_only or ["(none)"]),
            "",
            "common:",
            *(common or ["(none)"]),
            "",
        ]
    ),
    encoding="utf-8",
    newline="\n",
)

print(
    f"tests branch={branch_passed}/{branch_failed} main={main_passed}/{main_failed} "
    f"common={len(common)} branchOnly={len(branch_only)} mainOnly={len(main_only)}"
)
raise SystemExit(0 if passed else 1)
