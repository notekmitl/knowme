from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent
LOGS = ROOT / "logs"


def read(name: str) -> str:
    return (LOGS / name).read_text(encoding="utf-8-sig", errors="strict")


def diagnostics(text: str) -> set[str]:
    found: set[str] = set()
    pattern = re.compile(
        r"^\s*(info|warning|error) - (.*?) - (.*?) - ([a-z0-9_]+)\s*$",
        re.MULTILINE,
    )
    for severity, message, location, code in pattern.findall(text):
        normalized_location = location.replace("\\", "/")
        found.add(f"{severity}|{message}|{normalized_location}|{code}")
    return found


def reported_total(text: str) -> int:
    matches = re.findall(r"^(\d+) issues found\.", text, re.MULTILINE)
    if not matches:
        raise RuntimeError("Could not locate final analyzer total")
    return int(matches[-1])


branch_text = read("full-analyzer-branch-final-result.txt")
main_text = read("full-analyzer-main-result.txt")
branch = diagnostics(branch_text)
main = diagnostics(main_text)
branch_only = sorted(branch - main)
main_only = sorted(main - branch)
branch_total = reported_total(branch_text)
main_total = reported_total(main_text)
passed = not branch_only and branch_total <= main_total

(LOGS / "full-analyzer-delta-final-result.txt").write_text(
    "\n".join(
        [
            "status: PASS — NO BRANCH-ONLY DIAGNOSTICS"
            if passed
            else "status: BLOCKED — BRANCH ADDS DIAGNOSTICS AGAINST MAIN",
            f"branchDiagnostics: {branch_total}",
            f"mainDiagnostics: {main_total}",
            f"branchOnlyDiagnostics: {len(branch_only)}",
            f"mainOnlyDiagnostics: {len(main_only)}",
            "",
            "branchOnly:",
            *(branch_only or ["(none)"]),
            "",
            "mainOnly:",
            *(main_only or ["(none)"]),
            "",
        ]
    ),
    encoding="utf-8",
    newline="\n",
)

print(
    f"analyzer branch={branch_total} main={main_total} "
    f"branchOnly={len(branch_only)} mainOnly={len(main_only)}"
)
raise SystemExit(0 if passed else 1)
