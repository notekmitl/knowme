from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent


def read(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8", errors="strict")


def analyzer_diagnostics(text: str) -> set[str]:
    diagnostics: set[str] = set()
    pattern = re.compile(
        r"^\s*(info|warning|error) - (.*?) - (.*?):(\d+):(\d+) - ([a-z0-9_]+)\s*$",
        re.MULTILINE,
    )
    for match in pattern.finditer(text):
        severity, message, path, line, column, code = match.groups()
        normalized_path = path.replace("\\", "/")
        diagnostics.add(
            f"{severity}|{message}|{normalized_path}|{line}|{column}|{code}"
        )
    return diagnostics


def failure_ids(text: str) -> set[str]:
    failures: set[str] = set()
    pattern = re.compile(r"^.*?/test/(.*?\.dart): (.*?) \[E\]\s*$", re.MULTILINE)
    for match in pattern.finditer(text.replace("\\", "/")):
        failures.add(f"{match.group(1)} :: {match.group(2)}")
    return failures


def totals(text: str) -> tuple[int, int]:
    matches = re.findall(r"\+(\d+) -(\d+): (?:Some tests failed\.|All tests passed!)", text)
    if not matches:
        raise RuntimeError("Could not locate final Flutter test totals")
    passed, failed = matches[-1]
    return int(passed), int(failed)


branch_analyzer = analyzer_diagnostics(read("full-analyzer-branch-result.txt"))
main_analyzer = analyzer_diagnostics(read("full-analyzer-main-result.txt"))
branch_only_analyzer = sorted(branch_analyzer - main_analyzer)
main_only_analyzer = sorted(main_analyzer - branch_analyzer)

analyzer_lines = [
    f"branchDiagnostics: {len(branch_analyzer)}",
    f"mainDiagnostics: {len(main_analyzer)}",
    f"branchOnlyDiagnostics: {len(branch_only_analyzer)}",
    f"mainOnlyDiagnostics: {len(main_only_analyzer)}",
    f"result: {'PASS' if not branch_only_analyzer else 'BLOCKED'}",
    "",
    "branchOnly:",
    *(branch_only_analyzer or ["(none)"]),
    "",
    "mainOnly:",
    *(main_only_analyzer or ["(none)"]),
    "",
]
(ROOT / "analyzer-delta-result.txt").write_text(
    "\n".join(analyzer_lines), encoding="utf-8", newline="\n"
)

branch_test_text = read("full-test-branch-result.txt")
main_test_text = read("full-test-main-result.txt")
branch_failures = failure_ids(branch_test_text)
main_failures = failure_ids(main_test_text)
branch_passed, branch_failed = totals(branch_test_text)
main_passed, main_failed = totals(main_test_text)
branch_only = sorted(branch_failures - main_failures)
main_only = sorted(main_failures - branch_failures)
common = sorted(branch_failures & main_failures)
life_map_failures = sorted(
    failure
    for failure in branch_failures
    if re.search(r"life_map/v12[6-9]|life_map/v13[0-2]", failure)
)

failure_gate_passed = (
    not branch_only
    and not main_only
    and len(common) == 39
    and branch_failed == 39
    and main_failed == 39
    and not life_map_failures
)
failure_lines = [
    "status: PASS AGAINST PINNED MAIN BASELINE"
    if failure_gate_passed
    else "status: BLOCKED — BRANCH FAILURE SET DIFFERS FROM MAIN",
    f"branchPassed: {branch_passed}",
    f"branchFailed: {branch_failed}",
    f"branchFailureIds: {len(branch_failures)}",
    f"mainPassed: {main_passed}",
    f"mainFailed: {main_failed}",
    f"mainFailureIds: {len(main_failures)}",
    f"commonFailureIds: {len(common)}",
    f"branchOnlyFailureIds: {len(branch_only)}",
    f"mainOnlyFailureIds: {len(main_only)}",
    f"lifeMapV126ToV132FailureIds: {len(life_map_failures)}",
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
(ROOT / "full-test-delta-result.txt").write_text(
    "\n".join(failure_lines), encoding="utf-8", newline="\n"
)

print(
    f"analyzer branch/main/delta={len(branch_analyzer)}/{len(main_analyzer)}/{len(branch_only_analyzer)}"
)
print(
    f"tests branch={branch_passed}/{branch_failed} main={main_passed}/{main_failed} "
    f"common={len(common)} branchOnly={len(branch_only)} mainOnly={len(main_only)}"
)
if branch_only_analyzer or not failure_gate_passed:
    raise SystemExit(1)
