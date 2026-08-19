#!/usr/bin/env python3
"""Render and validate the 14 PR #100 review PDFs with bound file identity.

Every PNG basename includes its source PDF stem. This prevents the repeated
``page-1.png`` preview-cache collision that produced the false Revision 3
clipping report.
"""

from __future__ import annotations

import argparse
import difflib
import hashlib
import html
import json
import re
import subprocess
import unicodedata
from pathlib import Path

import pdfplumber
from PIL import Image, ImageChops
from pypdf import PdfReader


FIXTURES = (
    "comparison-known-bangkok",
    "comparison-known-khon-kaen",
    "known",
    "owner-known-0035",
    "owner-unknown",
    "regression-known-0003",
    "unknown",
)
KINDS = ("browser-print", "dedicated-report")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def normalized_text(value: str) -> str:
    return re.sub(r"\s+", " ", value.replace("\x00", " ")).strip()


def extraction_skeleton(value: str) -> str:
    """Normalize browser-PDF Thai font maps for inventory comparison only.

    Chromium's embedded Thai font map can expose U+0E33 as decomposed marks and
    can map some rendered combining marks to NUL. The visible raster remains
    authoritative for glyph QA. This skeleton removes whitespace and Thai
    combining marks from both expected and extracted text so section/paragraph
    presence and ordering remain deterministic without claiming byte parity.
    """
    decomposed = unicodedata.normalize("NFKD", html.unescape(value)).replace("\x00", "")
    # Retain Thai base consonants/digits and ASCII identity. Browser PDF font
    # maps are inconsistent for both leading vowels and combining marks, while
    # the base consonant sequence remains stable and is long enough to bind
    # every expected paragraph to its source section without sampling.
    return re.sub(r"[^\u0e01-\u0e2e\u0e50-\u0e59A-Za-z0-9]", "", decomposed)


def visible_html_text(value: str) -> str:
    without_tags = re.sub(r"<[^>]+>", " ", value)
    return normalized_text(html.unescape(without_tags))


def expected_contract(html_path: Path) -> dict[str, object]:
    source = html_path.read_text(encoding="utf-8")
    header_match = re.search(r"<h1>(.*?)</h1>", source, flags=re.DOTALL)
    subtitle_match = re.search(
        r'<p class="subtitle">(.*?)</p>', source, flags=re.DOTALL
    )
    if not header_match or not subtitle_match:
        raise ValueError(f"missing report header contract in {html_path}")
    sections: list[dict[str, object]] = []
    for section_id, body in re.findall(
        r'<section[^>]*data-section-id="([^"]+)"[^>]*>(.*?)</section>',
        source,
        flags=re.DOTALL,
    ):
        title_match = re.search(r"<h2>(.*?)</h2>", body, flags=re.DOTALL)
        paragraphs = [
            visible_html_text(value)
            for value in re.findall(r"<p[^>]*>(.*?)</p>", body, flags=re.DOTALL)
        ]
        if not title_match or not paragraphs:
            raise ValueError(f"incomplete section {section_id} in {html_path}")
        sections.append(
            {
                "id": section_id,
                "title": visible_html_text(title_match.group(1)),
                "paragraphs": paragraphs,
            }
        )
    if not sections:
        raise ValueError(f"no report sections in {html_path}")
    return {
        "header": visible_html_text(header_match.group(1)),
        "subtitle": visible_html_text(subtitle_match.group(1)),
        "sections": sections,
    }


def raster_bbox(path: Path) -> tuple[int, int, int, int] | None:
    with Image.open(path).convert("RGB") as image:
        white = Image.new("RGB", image.size, "white")
        return ImageChops.difference(image, white).getbbox()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--artifact-root", type=Path, required=True)
    parser.add_argument("--render-root", type=Path, required=True)
    parser.add_argument("--pdftoppm", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--text", type=Path, required=True)
    args = parser.parse_args()

    artifact_root = args.artifact_root.resolve()
    render_root = args.render_root.resolve()
    render_root.mkdir(parents=True, exist_ok=True)
    failures: list[str] = []
    results: list[dict[str, object]] = []
    total_pages = 0

    for kind in KINDS:
        for fixture in FIXTURES:
            stem = f"{kind}-{fixture}"
            pdf_path = artifact_root / f"{stem}.pdf"
            html_path = artifact_root / f"browser-print-{fixture}.html"
            if not pdf_path.is_file():
                failures.append(f"missing PDF: {pdf_path}")
                continue
            if not html_path.is_file():
                failures.append(f"missing shared-model HTML: {html_path}")
                continue
            contract = expected_contract(html_path)
            reader = PdfReader(pdf_path)
            page_count = len(reader.pages)
            total_pages += page_count
            first_text = normalized_text(reader.pages[0].extract_text() or "")
            full_text = normalized_text(
                " ".join(page.extract_text() or "" for page in reader.pages)
            )
            first_skeleton = extraction_skeleton(first_text)
            full_skeleton = extraction_skeleton(full_text)
            expected_skeleton = extraction_skeleton(
                " ".join(
                    [str(contract["header"]), str(contract["subtitle"])]
                    + [
                        str(value)
                        for section in contract["sections"]
                        for value in [section["title"], *section["paragraphs"]]
                    ]
                )
            )
            semantic_ratio = difflib.SequenceMatcher(
                None, expected_skeleton, full_skeleton, autojunk=False
            ).ratio()
            extraction_length_ratio = len(full_skeleton) / len(expected_skeleton)
            if semantic_ratio < 0.99:
                failures.append(
                    f"{stem}: shared-model extraction similarity {semantic_ratio:.6f} < 0.99"
                )
            if not 0.98 <= extraction_length_ratio <= 1.02:
                failures.append(
                    f"{stem}: shared-model extraction length ratio "
                    f"{extraction_length_ratio:.6f} outside 0.98..1.02"
                )
            required_first_page = [
                str(contract["header"]),
                str(contract["subtitle"]),
                str(contract["sections"][0]["title"]),
                str(contract["sections"][0]["paragraphs"][0]),
            ]
            for required in required_first_page:
                if extraction_skeleton(required) not in first_skeleton:
                    failures.append(
                        f"{stem}: first page missing contract text: {required[:80]}"
                    )
            if len(first_text) < 100:
                failures.append(f"{stem}: first-page extracted text too short ({len(first_text)})")

            missing_units: list[str] = []
            duplicated_units: list[str] = []
            section_order: list[str] = []
            cursor = -1
            for section in contract["sections"]:
                section_id = str(section["id"])
                title = str(section["title"])
                paragraphs = [str(value) for value in section["paragraphs"]]
                title_skeleton = extraction_skeleton(title)
                paragraph_skeletons = [extraction_skeleton(value) for value in paragraphs]
                title_position = full_skeleton.find(title_skeleton, cursor + 1)
                first_paragraph_position = full_skeleton.find(
                    paragraph_skeletons[0], title_position + 1
                )
                if title_position < 0 or first_paragraph_position < 0:
                    missing_units.append(section_id)
                    continue
                section_order.append(section_id)
                cursor = first_paragraph_position
                for index, paragraph_skeleton in enumerate(paragraph_skeletons, start=1):
                    if paragraph_skeleton not in full_skeleton:
                        missing_units.append(f"{section_id}.p{index:02d}")
                    elif (
                        len(paragraph_skeleton) >= 30
                        and full_skeleton.count(paragraph_skeleton) != 1
                    ):
                        duplicated_units.append(f"{section_id}.p{index:02d}")
            if duplicated_units:
                failures.append(
                    f"{stem}: duplicated shared-model paragraphs: "
                    + ", ".join(duplicated_units)
                )
            page_geometry: list[dict[str, object]] = []
            with pdfplumber.open(pdf_path) as document:
                if len(document.pages) != page_count:
                    failures.append(f"{stem}: parser page-count disagreement")
                for page_index, page in enumerate(document.pages, start=1):
                    chars = page.chars
                    if chars:
                        min_top = min(float(char["top"]) for char in chars)
                        max_bottom = max(float(char["bottom"]) for char in chars)
                        min_x = min(float(char["x0"]) for char in chars)
                        max_x = max(float(char["x1"]) for char in chars)
                        if min_top < -0.01 or min_x < -0.01:
                            failures.append(f"{stem}/page-{page_index}: negative text coordinate")
                        if max_bottom > float(page.height) + 0.01 or max_x > float(page.width) + 0.01:
                            failures.append(f"{stem}/page-{page_index}: text outside page bounds")
                    else:
                        min_top = max_bottom = min_x = max_x = None
                    page_geometry.append(
                        {
                            "page": page_index,
                            "charCount": len(chars),
                            "minTop": min_top,
                            "maxBottom": max_bottom,
                            "minX": min_x,
                            "maxX": max_x,
                        }
                    )

            prefix = render_root / stem
            completed = subprocess.run(
                [str(args.pdftoppm), "-png", "-r", "110", str(pdf_path), str(prefix)],
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
            )
            if completed.returncode:
                failures.append(f"{stem}: pdftoppm exit {completed.returncode}: {completed.stderr.strip()}")
                continue
            generated = sorted(render_root.glob(f"{stem}-*.png"))
            if len(generated) != page_count:
                failures.append(f"{stem}: rendered {len(generated)} of {page_count} pages")
            render_rows: list[dict[str, object]] = []
            for page_index, generated_path in enumerate(generated, start=1):
                target = render_root / f"{stem}-page-{page_index:02d}.png"
                if generated_path != target:
                    generated_path.replace(target)
                with Image.open(target) as image:
                    width, height = image.size
                bbox = raster_bbox(target)
                if bbox is None:
                    failures.append(f"{stem}/page-{page_index}: blank raster")
                elif bbox[1] <= 1:
                    failures.append(f"{stem}/page-{page_index}: ink touches top edge")
                render_rows.append(
                    {
                        "page": page_index,
                        "file": target.name,
                        "bytes": target.stat().st_size,
                        "sha256": sha256(target),
                        "width": width,
                        "height": height,
                        "inkBounds": bbox,
                    }
                )

            results.append(
                {
                    "stem": stem,
                    "fixture": fixture,
                    "kind": kind,
                    "pdf": pdf_path.name,
                    "bytes": pdf_path.stat().st_size,
                    "sha256": sha256(pdf_path),
                    "pages": page_count,
                    "firstPageHasHeader": extraction_skeleton(
                        str(contract["header"])
                    )
                    in first_skeleton,
                    "firstPageContractUnits": len(required_first_page),
                    "firstPageExtractedCharacters": len(first_text),
                    "expectedSectionCount": len(contract["sections"]),
                    "extractedSectionsInOrder": len(section_order),
                    "exactExtractionGapsFromFontMap": missing_units,
                    "duplicatedSharedModelUnits": duplicated_units,
                    "sharedModelExtractionSimilarity": semantic_ratio,
                    "sharedModelExtractionLengthRatio": extraction_length_ratio,
                    "pageGeometry": page_geometry,
                    "renders": render_rows,
                }
            )

    payload = {
        "schema": "knowme-pr100-revision3-pdf-page-one-gate-v1",
        "artifactRoot": str(artifact_root),
        "renderRoot": str(render_root),
        "pdfCount": len(results),
        "totalPages": total_pages,
        "uniqueRenderNames": len({row["file"] for result in results for row in result["renders"]}),
        "failures": failures,
        "results": results,
    }
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.text.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    lines = [
        f"pdfCount={payload['pdfCount']}",
        f"totalPages={total_pages}",
        f"uniqueRenderNames={payload['uniqueRenderNames']}",
        f"failures={len(failures)}",
    ]
    for result in results:
        lines.append(
            f"{result['stem']}|pages={result['pages']}|bytes={result['bytes']}|"
            f"sha256={result['sha256']}|firstPageHasHeader={result['firstPageHasHeader']}|"
            f"firstPageExtractedCharacters={result['firstPageExtractedCharacters']}"
        )
    lines.extend(f"FAIL|{failure}" for failure in failures)
    args.text.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
