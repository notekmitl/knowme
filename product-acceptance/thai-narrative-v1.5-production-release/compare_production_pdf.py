from __future__ import annotations

import difflib
import hashlib
import json
import re
from pathlib import Path

from pypdf import PdfReader


EVIDENCE = Path(__file__).resolve().parent
REPO = EVIDENCE.parents[1]
FIXTURE = "owner-known-0035"
PRODUCTION = EVIDENCE / f"{FIXTURE}-production.pdf"
ACCEPTED_PDF = (
    REPO
    / "product-acceptance"
    / "thai-narrative-v1.5-r7.1"
    / "evidence"
    / f"{FIXTURE}-report.pdf"
)
ACCEPTED_TEXT = ACCEPTED_PDF.with_name(f"{FIXTURE}-pdf-text.txt")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def extract(path: Path) -> tuple[int, str]:
    reader = PdfReader(path)
    return len(reader.pages), "\n".join(page.extract_text() or "" for page in reader.pages)


def normalize(text: str) -> str:
    without_page_numbers = re.sub(r"หน้า\s+\d+\s*/\s*\d+", "", text)
    return re.sub(r"\s+", " ", without_page_numbers).strip()


production_pages, production_extracted = extract(PRODUCTION)
accepted_pages, accepted_extracted = extract(ACCEPTED_PDF)
accepted_canonical = ACCEPTED_TEXT.read_text(encoding="utf-8")
(EVIDENCE / f"{FIXTURE}-production-extracted.txt").write_text(
    production_extracted, encoding="utf-8", newline="\n"
)

production_normalized = normalize(production_extracted)
accepted_pdf_normalized = normalize(accepted_extracted)
accepted_canonical_normalized = normalize(accepted_canonical)
matcher = difflib.SequenceMatcher(None, production_normalized, accepted_pdf_normalized)
differences = []
for tag, i1, i2, j1, j2 in matcher.get_opcodes():
    if tag == "equal":
        continue
    differences.append(
        {
            "operation": tag,
            "production": production_normalized[i1:i2],
            "accepted": accepted_pdf_normalized[j1:j2],
        }
    )

result = {
    "fixture": FIXTURE,
    "productionPdfBytes": PRODUCTION.stat().st_size,
    "productionPdfSha256": sha256(PRODUCTION),
    "productionPages": production_pages,
    "acceptedPdfBytes": ACCEPTED_PDF.stat().st_size,
    "acceptedPdfSha256": sha256(ACCEPTED_PDF),
    "acceptedPages": accepted_pages,
    "productionVsAcceptedPdfExtractedExact": production_normalized
    == accepted_pdf_normalized,
    "productionVsAcceptedCanonicalExact": production_normalized
    == accepted_canonical_normalized,
    "sequenceSimilarity": matcher.ratio(),
    "substantiveDifferenceCount": len(differences),
    "differences": differences,
    "result": "BLOCKED",
    "requiredAction": "ROLLBACK_TO_V1.4",
}
(EVIDENCE / f"{FIXTURE}-production-comparison.json").write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
    newline="\n",
)
print(json.dumps(result, ensure_ascii=False, indent=2))
raise SystemExit(1)
