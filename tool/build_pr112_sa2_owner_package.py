#!/usr/bin/env python3
"""Build and verify the PR112 SA2 Owner Review ZIP."""

from __future__ import annotations

import hashlib
import json
import re
import shutil
import tempfile
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SHORT_SHA = "e1773d4"
ZIP_PATH = ROOT.parent / f"OWNER_REVIEW_THAI_REPORT_PREDICTIVE_NARRATIVE_V2_PHASE1_SA2_{SHORT_SHA}.zip"

FILES = {
    "OWNER_REVIEW.md": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_PHASE1_SA2_OWNER_REVIEW.md",
    "PRIMARY_EDITION_DECISION.md": "docs/THAI_MAHABHUT_2537_PRIMARY_EDITION_DECISION_RECORD.md",
    "SOURCE_TRUTH_RECONCILIATION.md": "docs/THAI_MAHABHUT_CANON_SOURCE_TRUTH_RECONCILIATION_V1.md",
    "CANON_V2_CHARTER.md": "docs/THAI_MAHABHUT_PREDICTIVE_CANON_V2_CHARTER.md",
    "FULL_49_CONTEXT_EXTRACTION_MATRIX.md": "docs/THAI_MAHABHUT_2537_FULL_49_CONTEXT_EXTRACTION_MATRIX.md",
    "OCR_BLOCKER_TRIAGE.md": "docs/THAI_MAHABHUT_2537_OCR_BLOCKER_TRIAGE.md",
    "CONFLICT_EXCEPTION_REGISTER.md": "docs/THAI_MAHABHUT_2537_CONFLICT_EXCEPTION_REGISTER.md",
    "EVENT_COVERAGE_REPORT.md": "docs/THAI_MAHABHUT_2537_EVENT_COVERAGE_REPORT.md",
    "FULL_EVIDENCE_MAPPING.md": "docs/THAI_MAHABHUT_2537_FULL_EVIDENCE_MAPPING.md",
    "mahabhut_2537_predictive_corpus_v1.json": "knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.json",
    "mahabhut_2537_predictive_corpus_v1.schema.json": "knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.schema.json",
    "mahabhut_predictive_rules_v2.json": "knowledge/canon/proposed/mahabhut_predictive_rules_v2.json",
    "mahabhut_predictive_rules_v2.schema.json": "knowledge/canon/proposed/mahabhut_predictive_rules_v2.schema.json",
    "CANDIDATE_0008_KNOWN.md": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0008.md",
    "CANDIDATE_0008_UNKNOWN.md": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0008_UNKNOWN.md",
    "DIRECT_LANGUAGE_AUDIT.md": "docs/THAI_MAHABHUT_2537_DIRECT_LANGUAGE_AUDIT.md",
    "SA2_VALIDATION.json": "docs/THAI_MAHABHUT_2537_SA2_VALIDATION.json",
    "FIXTURE_SEPARATION.json": "docs/THAI_MAHABHUT_2537_SA2_FIXTURE_SEPARATION.json",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="pr112_sa2_") as temporary:
        stage = Path(temporary) / "owner-review"
        stage.mkdir()
        manifest_entries = []
        for package_name, repo_name in FILES.items():
            source = ROOT / repo_name
            if not source.is_file():
                raise FileNotFoundError(source)
            target = stage / package_name
            shutil.copyfile(source, target)
            manifest_entries.append({"path": package_name, "bytes": target.stat().st_size, "sha256": sha256(target)})

        manifest = {
            "package": ZIP_PATH.name, "candidateCommit": "e1773d4033652b417e3a4a22ab44054aa8d0fd94",
            "status": "PENDING_OWNER_CONTENT_REVIEW", "files": manifest_entries,
            "sourcePdfIncluded": False, "runtimeImplementation": False,
        }
        manifest_path = stage / "MANIFEST.json"
        manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        sum_paths = [stage / item["path"] for item in manifest_entries] + [manifest_path]
        sums_path = stage / "SHA256SUMS.txt"
        sums_path.write_text("".join(f"{sha256(path)}  {path.name}\n" for path in sum_paths), encoding="ascii")

        with zipfile.ZipFile(ZIP_PATH, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for path in sorted(stage.iterdir(), key=lambda item: item.name):
                archive.write(path, path.name)

        with tempfile.TemporaryDirectory(prefix="pr112_sa2_extract_") as extracted_dir:
            extracted = Path(extracted_dir)
            with zipfile.ZipFile(ZIP_PATH) as archive:
                crc_error = archive.testzip()
                archive.extractall(extracted)
                zip_names = sorted(archive.namelist())
            expected_names = sorted([*FILES, "MANIFEST.json", "SHA256SUMS.txt"])
            missing = sorted(set(expected_names) - set(zip_names))
            extra = sorted(set(zip_names) - set(expected_names))
            extracted_manifest = json.loads((extracted / "MANIFEST.json").read_text(encoding="utf-8"))
            hash_mismatch = []
            size_mismatch = []
            for item in extracted_manifest["files"]:
                path = extracted / item["path"]
                if sha256(path) != item["sha256"]:
                    hash_mismatch.append(item["path"])
                if path.stat().st_size != item["bytes"]:
                    size_mismatch.append(item["path"])
            sums_mismatch = []
            for line in (extracted / "SHA256SUMS.txt").read_text(encoding="ascii").splitlines():
                expected, name = line.split("  ", 1)
                if sha256(extracted / name) != expected:
                    sums_mismatch.append(name)
            secret_patterns = re.compile(r"(?i)(api[_-]?key\s*[:=]|password\s*[:=]|private[_-]?key|BEGIN [A-Z ]+PRIVATE KEY|AIza[0-9A-Za-z_-]{20,})")
            secret_hits = []
            absolute_path_hits = []
            for path in extracted.iterdir():
                if path.suffix.lower() not in {".md", ".json", ".txt"}:
                    continue
                text = path.read_text(encoding="utf-8", errors="replace")
                if secret_patterns.search(text):
                    secret_hits.append(path.name)
                if re.search(r"[A-Za-z]:\\", text):
                    absolute_path_hits.append(path.name)
            report = {
                "zip": str(ZIP_PATH), "zipSha256": sha256(ZIP_PATH), "entries": len(zip_names),
                "crcError": crc_error, "missingCount": len(missing), "extraCount": len(extra),
                "manifestHashMismatchCount": len(hash_mismatch), "manifestSizeMismatchCount": len(size_mismatch),
                "sha256SumsMismatchCount": len(sums_mismatch), "secretHitCount": len(secret_hits),
                "absolutePathHitCount": len(absolute_path_hits),
            }
            print(json.dumps(report, ensure_ascii=True, indent=2))
            if any((crc_error, missing, extra, hash_mismatch, size_mismatch, sums_mismatch, secret_hits, absolute_path_hits)):
                raise SystemExit(1)


if __name__ == "__main__":
    main()
