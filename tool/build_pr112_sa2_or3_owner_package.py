#!/usr/bin/env python3
"""Build and verify the PR112 SA2 OR3 Owner Review ZIP."""

from __future__ import annotations

import hashlib
import json
import re
import shutil
import tempfile
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SHORT_SHA = "b03e46c"
VALIDATION_COMMIT = "b03e46cb93f0864b8910ba9313f0734bab574980"
ZIP_PATH = ROOT.parent / (
    "OWNER_REVIEW_THAI_REPORT_PREDICTIVE_NARRATIVE_V2_PHASE1_"
    f"SA2_OR3_{SHORT_SHA}.zip"
)

FILES = {
    "OWNER_REVIEW.md": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_PHASE1_SA2_OR3_OWNER_REVIEW.md",
    "CANDIDATE_0010_TO_0011_FULL_COPY_DIFF.md": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0010_TO_0011_FULL_COPY_DIFF.md",
    "CANDIDATE_0011_KNOWN.md": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md",
    "CANDIDATE_0011_UNKNOWN.md": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011_UNKNOWN.md",
    "COMPLETE_READER_TEXT_KNOWN.md": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md",
    "CANDIDATE_0011_CLAIM_MAP.md": "docs/THAI_MAHABHUT_2537_CANDIDATE_0011_CLAIM_EVIDENCE_MAP.md",
    "candidate_0011_reader_claims.json": "knowledge/canon/proposed/mahabhut_2537_candidate_0011_reader_claims.json",
    "SEMANTIC_MOTIF_OWNERSHIP.md": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0011_SEMANTIC_MOTIF_OWNERSHIP.md",
    "SEMANTIC_MOTIF_OWNERSHIP.json": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0011_SEMANTIC_MOTIF_OWNERSHIP.json",
    "TWO_PASS_HUMAN_AUDIT.md": "docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0011_TWO_PASS_HUMAN_AUDIT.md",
    "STRUCTURAL_VALIDATION.md": "docs/THAI_MAHABHUT_2537_SA2_OR3_VALIDATION.md",
    "STRUCTURAL_VALIDATION.json": "docs/THAI_MAHABHUT_2537_SA2_OR3_VALIDATION.json",
    "NEGATIVE_CONTROLS.json": "docs/THAI_MAHABHUT_2537_SA2_OR3_NEGATIVE_CONTROLS.json",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="pr112_sa2_or3_") as temporary:
        stage = Path(temporary) / "owner-review"
        stage.mkdir()
        entries = []
        for package_name, repo_name in FILES.items():
            source = ROOT / repo_name
            if not source.is_file():
                raise FileNotFoundError(source)
            target = stage / package_name
            shutil.copyfile(source, target)
            entries.append(
                {"path": package_name, "bytes": target.stat().st_size, "sha256": sha256(target)}
            )

        manifest = {
            "package": ZIP_PATH.name,
            "validationCommit": VALIDATION_COMMIT,
            "status": "PENDING_OWNER_FINAL_CONTENT_REVIEW",
            "runtimeImplementation": False,
            "sourcePdfIncluded": False,
            "counts": {
                "baselinePredictionOwners": 24,
                "candidatePredictionOwners": 22,
                "addedOwners": 0,
                "removedOwners": ["OAS-02", "OAS-08"],
                "semanticMotifs": 8,
                "negativeControls": 6,
                "focusedTestsPassed": 44,
            },
            "files": entries,
        }
        manifest_path = stage / "MANIFEST.json"
        manifest_path.write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        sum_paths = [stage / item["path"] for item in entries] + [manifest_path]
        sums_path = stage / "SHA256SUMS.txt"
        sums_path.write_text(
            "".join(f"{sha256(path)}  {path.name}\n" for path in sum_paths),
            encoding="ascii",
        )

        with zipfile.ZipFile(
            ZIP_PATH, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9
        ) as archive:
            for path in sorted(stage.iterdir(), key=lambda item: item.name):
                archive.write(path, path.name)

        with tempfile.TemporaryDirectory(prefix="pr112_sa2_or3_extract_") as extracted_dir:
            extracted = Path(extracted_dir)
            with zipfile.ZipFile(ZIP_PATH) as archive:
                crc_error = archive.testzip()
                archive.extractall(extracted)
                zip_names = sorted(archive.namelist())
            expected_names = sorted([*FILES, "MANIFEST.json", "SHA256SUMS.txt"])
            missing = sorted(set(expected_names) - set(zip_names))
            extra = sorted(set(zip_names) - set(expected_names))
            extracted_manifest = json.loads(
                (extracted / "MANIFEST.json").read_text(encoding="utf-8")
            )
            hash_mismatch = []
            size_mismatch = []
            for item in extracted_manifest["files"]:
                path = extracted / item["path"]
                if sha256(path) != item["sha256"]:
                    hash_mismatch.append(item["path"])
                if path.stat().st_size != item["bytes"]:
                    size_mismatch.append(item["path"])
            sums_mismatch = []
            for line in (extracted / "SHA256SUMS.txt").read_text(
                encoding="ascii"
            ).splitlines():
                expected, name = line.split("  ", 1)
                if sha256(extracted / name) != expected:
                    sums_mismatch.append(name)
            secret_pattern = re.compile(
                r"(?i)(api[_-]?key\s*[:=]|password\s*[:=]|private[_-]?key|"
                r"BEGIN [A-Z ]+PRIVATE KEY|AIza[0-9A-Za-z_-]{20,})"
            )
            secret_hits = []
            absolute_path_hits = []
            for path in extracted.iterdir():
                if path.suffix.lower() not in {".md", ".json", ".txt"}:
                    continue
                content = path.read_text(encoding="utf-8", errors="replace")
                if secret_pattern.search(content):
                    secret_hits.append(path.name)
                if re.search(r"[A-Za-z]:\\", content):
                    absolute_path_hits.append(path.name)
            report = {
                "zip": str(ZIP_PATH),
                "zipSha256": sha256(ZIP_PATH),
                "entries": len(zip_names),
                "crcError": crc_error,
                "missingCount": len(missing),
                "extraCount": len(extra),
                "manifestHashMismatchCount": len(hash_mismatch),
                "manifestSizeMismatchCount": len(size_mismatch),
                "sha256SumsMismatchCount": len(sums_mismatch),
                "secretHitCount": len(secret_hits),
                "absolutePathHitCount": len(absolute_path_hits),
            }
            print(json.dumps(report, ensure_ascii=True, indent=2))
            if any(
                (
                    crc_error,
                    missing,
                    extra,
                    hash_mismatch,
                    size_mismatch,
                    sums_mismatch,
                    secret_hits,
                    absolute_path_hits,
                )
            ):
                raise SystemExit(1)


if __name__ == "__main__":
    main()
