from __future__ import annotations

import difflib
import hashlib
import json
import re
import sys
from pathlib import Path

from pypdf import PdfReader


ROOT = Path(__file__).resolve().parent
ORACLE = ROOT / "predeploy-live-oracle-output"

FIXTURES = {
    "owner-known-0035": "owner-known-0035",
    "owner-unknown": "owner-unknown",
    "regression-known-0003": "regression-known-0003",
    "bangkok-known-1420": "comparison-known-bangkok",
    "khon-kaen-known-0645": "comparison-known-khon-kaen",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def extract(path: Path) -> tuple[int, str]:
    reader = PdfReader(path)
    return len(reader.pages), "\n".join(page.extract_text() or "" for page in reader.pages)


def normalize(text: str) -> str:
    text = text.replace("\ufeff", "")
    text = re.sub(r"หน้า\s+\d+\s*/\s*\d+", "", text)
    return re.sub(r"\s+", " ", text).strip()


def normalize_canonical(text: str) -> str:
    text = normalize(text)
    # These are pagination-only continuation labels injected by the PDF layout.
    text = text.replace("โครงสร้างดวงหลัก — ต่อ", "")
    text = text.replace("รายงานไม่รู้เวลา — ต่อ", "")
    text = text.replace("รายงานนี้ดูจากอะไร — ต่อ", "")
    text = re.sub(r"\s+([),.;:])", r"\1", text)
    return re.sub(r"\s+", " ", text).strip()


def differences(left: str, right: str) -> list[dict[str, str]]:
    matcher = difflib.SequenceMatcher(None, left, right)
    return [
        {
            "operation": tag,
            "actual": left[i1:i2],
            "oracle": right[j1:j2],
        }
        for tag, i1, i2, j1, j2 in matcher.get_opcodes()
        if tag != "equal"
    ]


def main(environment: str) -> int:
    rows = []
    for release_name, oracle_name in FIXTURES.items():
        actual_pdf = ROOT / f"{environment}-{release_name}-report.pdf"
        oracle_pdf = ORACLE / f"{oracle_name}-report.pdf"
        oracle_text_path = ORACLE / f"{oracle_name}-pdf-text.txt"
        actual_pages, actual_text = extract(actual_pdf)
        oracle_pages, oracle_extracted = extract(oracle_pdf)
        oracle_text = oracle_text_path.read_text(encoding="utf-8")
        (ROOT / f"{environment}-{release_name}-pdf-extracted.txt").write_text(
            actual_text, encoding="utf-8", newline="\n"
        )
        actual_norm = normalize(actual_text)
        oracle_pdf_norm = normalize(oracle_extracted)
        actual_canonical_norm = normalize_canonical(actual_text)
        oracle_text_norm = normalize_canonical(oracle_text)
        delta = differences(actual_norm, oracle_pdf_norm)
        rows.append(
            {
                "fixture": release_name,
                "environment": environment,
                "bytes": actual_pdf.stat().st_size,
                "sha256": sha256(actual_pdf),
                "pages": actual_pages,
                "oraclePages": oracle_pages,
                "extractedVsOraclePdfExact": actual_norm == oracle_pdf_norm,
                "extractedVsOracleCanonicalTextExact": actual_canonical_norm
                == oracle_text_norm,
                "substantiveDifferenceCount": len(delta),
                "differences": delta,
            }
        )
    result = {
        "environment": environment,
        "fixtures": rows,
        "fixtureCount": len(rows),
        "totalPages": sum(row["pages"] for row in rows),
        "allPageCountsMatch": all(row["pages"] == row["oraclePages"] for row in rows),
        "allExtractedVsOraclePdfExact": all(
            row["extractedVsOraclePdfExact"] for row in rows
        ),
        "allExtractedVsOracleCanonicalTextExact": all(
            row["extractedVsOracleCanonicalTextExact"] for row in rows
        ),
        "totalSubstantiveDifferences": sum(
            row["substantiveDifferenceCount"] for row in rows
        ),
    }
    result["result"] = (
        "PASS"
        if result["allPageCountsMatch"]
        and result["allExtractedVsOraclePdfExact"]
        and result["allExtractedVsOracleCanonicalTextExact"]
        and result["totalSubstantiveDifferences"] == 0
        else "FAIL"
    )
    output = ROOT / f"{environment}-pdf-semantic-verification.json"
    output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["result"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1]))
