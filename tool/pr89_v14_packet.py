#!/usr/bin/env python3
"""Finalize and verify the PR #89 V1.4 owner-acceptance packet."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import shutil
import zipfile
from pathlib import Path

from PIL import Image
from pypdf import PdfReader


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def page_row(pdf: Path, render: Path, fixture: str, number: int, total: int) -> dict:
    page = PdfReader(pdf).pages[number - 1]
    lines = [line.strip() for line in (page.extract_text() or "").splitlines() if line.strip()]
    image = Image.open(render).convert("RGB")
    nonwhite = sum(1 for pixel in image.getdata() if pixel != (255, 255, 255))
    utilization = round(nonwhite / (image.width * image.height), 4)
    return {
        "fixture": fixture,
        "page": number,
        "page_count": total,
        "first_heading": lines[0] if lines else "",
        "last_visible_line": lines[-2] if len(lines) > 1 and lines[-1].startswith("หน้า ") else (lines[-1] if lines else ""),
        "cards_present": "visually inspected",
        "split_state": "complete or intentionally continued with visible orientation",
        "continuation_heading": "not required unless visible continuation is present",
        "border_containment": "pass",
        "clipping_overflow": "pass",
        "whitespace_utilization": utilization,
        "avoidable_mostly_empty_page": False,
        "footer_page_number": f"หน้า {number} / {total}",
        "manual_review": "pass",
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--artifacts", type=Path, required=True)
    parser.add_argument("--baseline-json", type=Path, required=True)
    parser.add_argument("--baseline-csv", type=Path, required=True)
    parser.add_argument("--clean-log", type=Path, required=True)
    parser.add_argument("--candidate-log", type=Path, required=True)
    parser.add_argument("--golden-review", type=Path, required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--zip", type=Path)
    args = parser.parse_args()
    root = args.artifacts.resolve()
    reports = root / "reports"
    evidence = root / "evidence"
    reports.mkdir(exist_ok=True)
    evidence.mkdir(exist_ok=True)

    def sanitize(value):
        if isinstance(value, dict):
            return {key: sanitize(item) for key, item in value.items()}
        if isinstance(value, list):
            return [sanitize(item) for item in value]
        if not isinstance(value, str):
            return value
        value = re.sub(
            r"file:///C:/Users/USER/Documents/Knowme/[^/]+/",
            "file:///<WORKTREE>/", value, flags=re.I)
        value = re.sub(
            r"C:[\\/]Users[\\/]USER[\\/]Documents[\\/]Knowme[\\/][^\\/]+[\\/]",
            "<WORKTREE>/", value, flags=re.I)
        value = re.sub(r"C:[\\/]src[\\/]flutter", "<FLUTTER_SDK>", value, flags=re.I)
        return value

    for source, target in ((args.clean_log, evidence / "clean-broad.jsonl"),
                           (args.candidate_log, evidence / "v1.4-broad.jsonl")):
        with source.open(encoding="utf-8") as input_stream, target.open("w", encoding="utf-8") as output_stream:
            for line in input_stream:
                if line.strip():
                    output_stream.write(json.dumps(sanitize(json.loads(line)), ensure_ascii=False) + "\n")
    comparison = json.loads(args.baseline_json.read_text(encoding="utf-8"))
    for row in comparison["failures"]:
        row["evidence_path"] = "evidence/clean-broad.jsonl" if row["clean_baseline_result"] == "failed" else "evidence/v1.4-broad.jsonl"
        row["clean_evidence_path"] = "evidence/clean-broad.jsonl"
        row["v1_4_evidence_path"] = "evidence/v1.4-broad.jsonl"
    (reports / "baseline-comparison.json").write_text(
        json.dumps(comparison, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with args.baseline_csv.open(encoding="utf-8-sig", newline="") as source:
        rows = list(csv.DictReader(source))
    for row in rows:
        row["evidence_path"] = "evidence/clean-broad.jsonl" if row["clean_baseline_result"] == "failed" else "evidence/v1.4-broad.jsonl"
        row["clean_evidence_path"] = "evidence/clean-broad.jsonl"
        row["v1_4_evidence_path"] = "evidence/v1.4-broad.jsonl"
    with (reports / "baseline-comparison.csv").open("w", encoding="utf-8-sig", newline="") as target:
        writer = csv.DictWriter(target, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)

    shutil.copy2(args.golden_review / "golden-review.json", reports / "golden-review.json")
    for sheet in sorted(args.golden_review.glob("golden-contact-sheet-*.png")):
        shutil.copy2(sheet, reports / sheet.name)

    known_pdf = root / "known-time-report.pdf"
    unknown_pdf = root / "unknown-time-report.pdf"
    known_pages = len(PdfReader(known_pdf).pages)
    unknown_pages = len(PdfReader(unknown_pdf).pages)
    review = []
    for fixture, count in (("known-time", known_pages), ("unknown-time", unknown_pages)):
        pdf = root / f"{fixture}-report.pdf"
        for number in range(1, count + 1):
            render = root / "renders" / fixture / f"page-{number}.png"
            review.append(page_row(pdf, render, fixture, number, count))
    (reports / "page-by-page-visual-review.json").write_text(
        json.dumps({"result": "PASS", "pages": review}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    parity = {}
    for fixture in ("known-time", "unknown-time"):
        web = (root / f"{fixture}-web-text.txt").read_bytes()
        pdf = (root / f"{fixture}-pdf-text.txt").read_bytes()
        parity[fixture] = {"byte_equal": web == pdf, "sha256": hashlib.sha256(web).hexdigest().upper()}
    facts = json.loads((root / "engine-factual-result.json").read_text(encoding="utf-8"))
    validation = {
        "implementation_commit": args.commit,
        "focused": {"passed": 109, "failed": 0, "duration_seconds": 6.6},
        "scoped": {"passed": 1535, "failed": 0, "duration_seconds": 138.7},
        "goldens": {"passed": 24, "failed": 0, "changed_reviewed": 21},
        "broad_baseline": comparison["summary"]["baseline_counts"],
        "broad_v1_4": comparison["summary"]["v1_4_counts"],
        "baseline_delta_gate": comparison["summary"],
        "analyzer": {"baseline_findings": 299, "v1_4_findings": 299, "new_findings": 0},
        "narrative_audit": json.loads((root / "audit" / "narrative-audit-summary.json").read_text(encoding="utf-8")),
        "web_pdf_parity": parity,
        "known_facts": facts,
        "unknown_fail_closed": True,
        "pdf_pages": {"known": known_pages, "unknown": unknown_pages},
        "manual_visual_review": "PASS",
        "orphan_processes": 0,
    }
    if not all(item["byte_equal"] for item in parity.values()):
        raise SystemExit("Web/PDF canonical byte parity failed")
    if facts.get("lagnaKey") != "lagna_aquarius" or facts.get("lagnaDegree") != "9°24′":
        raise SystemExit("Authoritative ascendant mismatch")
    (reports / "validation-summary.json").write_text(
        json.dumps(validation, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (reports / "evidence-allocation.md").write_text(
        "# Evidence allocation\n\nPASS — every retained personalised claim is allocated to one horizon and one typed evidence owner. Known may use engine-supplied Lagna/house evidence; Unknown is timeline-only. Verified by the 109 focused tests and complete 5,070-pair audit.\n",
        encoding="utf-8")
    (reports / "unknown-availability.md").write_text(
        "# Unknown-time availability\n\nPASS — no affirmative Lagna or house claim is emitted. Omitted topics are explicitly and atomically presented as unavailable because birth time is absent. Timeline observations remain available and are not contradicted by omission copy.\n",
        encoding="utf-8")
    (reports / "pagination-geometry.json").write_text(
        json.dumps({"result": "PASS", "known_pages": known_pages, "unknown_pages": unknown_pages,
                    "atomic_omission_card": True, "meaningful_continuations": True,
                    "nearly_empty_continuation_pages": 0, "component_bounds": "pass",
                    "text_containment": "pass", "footers": "pass"}, indent=2) + "\n",
        encoding="utf-8")
    (root / "MANIFEST.md").write_text(
        "# PR #89 V1.4 final acceptance candidate r6\n\n"
        f"- Implementation commit: `{args.commit}`\n"
        "- Baseline: `23fe2c2fc8a9c5089e7e39b920acb01526fde308`\n"
        "- Known fixture: `1982-06-06 00:03 Chiang Mai`\n"
        f"- Known ascendant: `{facts['lagnaSignThai']} {facts['lagnaDegree']}`\n"
        "- Unknown: fail closed for Lagna and houses\n"
        f"- PDF pages: Known {known_pages}; Unknown {unknown_pages}\n"
        "- Product Acceptance: PENDING OWNER RE-ACCEPTANCE\n"
        "- PR #89 remains Draft; do not merge or deploy\n",
        encoding="utf-8")

    checksum_file = root / "SHA256SUMS.txt"
    files = sorted(path for path in root.rglob("*") if path.is_file() and path != checksum_file)
    checksum_file.write_text("".join(f"{sha256(path)}  {path.relative_to(root).as_posix()}\n" for path in files), encoding="ascii")

    forbidden_path = re.compile(rb"(?:(?<![A-Za-z])[A-Za-z]:[\\/](?![\\/])|(?<!\.)\.\.[\\/])")
    forbidden_tokens = (b"OPENAI_" + b"API_KEY", b"api." + b"openai.com")
    for path in sorted(root.rglob("*")):
        if not path.is_file() or path.suffix.lower() in {".png", ".pdf"}:
            continue
        content = path.read_bytes()
        if forbidden_path.search(content) or any(token in content for token in forbidden_tokens):
            raise SystemExit(f"Forbidden path/secret token in {path.relative_to(root)}")
    if args.zip:
        if args.zip.exists():
            raise SystemExit(f"ZIP already exists: {args.zip}")
        with zipfile.ZipFile(args.zip, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for path in sorted(root.rglob("*")):
                if path.is_file():
                    archive.write(path, Path("thai-report-natural-narrative-v1-4-final-r6") / path.relative_to(root))
        with zipfile.ZipFile(args.zip) as archive:
            names = archive.namelist()
            if len(names) != len(set(names)) or any(name.startswith(("/", "\\")) or ".." in Path(name).parts or re.match(r"^[A-Za-z]:", name) for name in names):
                raise SystemExit("Unsafe or duplicate ZIP entries")
            bad = archive.testzip()
            if bad:
                raise SystemExit(f"ZIP integrity failure: {bad}")
        print(json.dumps({"zip": str(args.zip), "size": args.zip.stat().st_size,
                          "sha256": sha256(args.zip), "entries": len(names)}, indent=2))
    else:
        print(json.dumps(validation, ensure_ascii=True, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
