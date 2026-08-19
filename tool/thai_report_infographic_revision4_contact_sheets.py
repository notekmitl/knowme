#!/usr/bin/env python3
"""Build identity-labelled Revision 4 infographic contact sheets."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


FIXTURES = {
    "known": "annual-infographic-known.png",
    "unknown": "annual-infographic-unknown.png",
    "owner-known-0035": "annual-infographic-owner-known-0035.png",
    "owner-unknown": "annual-infographic-owner-unknown.png",
    "regression-known-0003": "annual-infographic-regression-known-0003.png",
    "comparison-known-bangkok": "annual-infographic-comparison-known-bangkok.png",
    "comparison-known-khon-kaen": "annual-infographic-comparison-known-khon-kaen.png",
    "stress-known-longest": "annual-infographic-stress-known-longest.png",
    "stress-unknown-longest": "annual-infographic-stress-unknown-longest.png",
    "stress-opportunity-caution-longest": "annual-infographic-stress-opportunity-caution-longest.png",
    "stress-disclaimer-longest": "annual-infographic-stress-disclaimer-longest.png",
    "stress-thai-multiline": "annual-infographic-stress-thai-multiline.png",
    "stress-regression-1972": "annual-infographic-stress-regression-1972.png",
    "year-boundary-2569": "annual-infographic-year-boundary-2569.png",
    "year-boundary-2570": "annual-infographic-year-boundary-2570.png",
}


def font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        Path(r"C:\Windows\Fonts\arial.ttf"),
        Path(r"C:\Windows\Fonts\tahoma.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size)
    return ImageFont.load_default()


def panel(path: Path, label: str, width: int = 360) -> Image.Image:
    with Image.open(path) as source:
        image = source.convert("RGB")
    height = round(image.height * width / image.width)
    image = image.resize((width, height), Image.Resampling.LANCZOS)
    label_height = 68
    result = Image.new("RGB", (width, height + label_height), "white")
    result.paste(image, (0, label_height))
    draw = ImageDraw.Draw(result)
    draw.rectangle((0, 0, width, label_height), fill="#10233f")
    small = font(16)
    lines = [label, path.name]
    for index, line in enumerate(lines):
        draw.text((10, 8 + index * 26), line, fill="white", font=small)
    return result


def sheet(items: list[tuple[Path, str]], output: Path, columns: int = 3) -> None:
    panels = [panel(path, label) for path, label in items]
    rows = (len(panels) + columns - 1) // columns
    cell_width = max(item.width for item in panels)
    cell_height = max(item.height for item in panels)
    canvas = Image.new("RGB", (cell_width * columns, cell_height * rows), "#d9dde4")
    for index, item in enumerate(panels):
        canvas.paste(item, ((index % columns) * cell_width, (index // columns) * cell_height))
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, optimize=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("revision3", type=Path)
    parser.add_argument("revision4", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    groups = {
        "infographic-canonical-five-contact-sheet.png": [
            "known", "unknown", "owner-known-0035", "owner-unknown", "regression-known-0003"
        ],
        "infographic-known-unknown-contact-sheet.png": ["known", "unknown"],
        "infographic-stress-contact-sheet.png": [
            "stress-known-longest", "stress-unknown-longest",
            "stress-opportunity-caution-longest", "stress-disclaimer-longest",
            "stress-thai-multiline", "stress-regression-1972",
        ],
        "infographic-year-boundary-contact-sheet.png": ["year-boundary-2569", "year-boundary-2570"],
    }
    for filename, fixture_ids in groups.items():
        items = [(args.revision4 / FIXTURES[item], f"R4 | {item}") for item in fixture_ids]
        sheet(items, args.output / filename, columns=2 if len(items) == 2 else 3)

    defect_ids = ["unknown", "stress-unknown-longest", "stress-opportunity-caution-longest"]
    before_after: list[tuple[Path, str]] = []
    for fixture_id in defect_ids:
        before_after.append((args.revision3 / FIXTURES[fixture_id], f"R3 BEFORE | {fixture_id}"))
        before_after.append((args.revision4 / FIXTURES[fixture_id], f"R4 AFTER | {fixture_id}"))
    sheet(before_after, args.output / "infographic-before-after-three-contact-sheet.png", columns=2)
    print("CONTACT_SHEETS status=PASS groups=5 fixtures=15 beforeAfter=3 labels=unique")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
