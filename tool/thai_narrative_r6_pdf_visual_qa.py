from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont


def ink_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    rgb = image.convert("RGB")
    white = Image.new("RGB", rgb.size, "white")
    diff = ImageChops.difference(rgb, white).convert("L")
    return diff.point(lambda value: 255 if value > 12 else 0).getbbox()


def contact_sheet(
    fixture: str, pages: list[Path], output: Path, *, thumb_width: int = 430
) -> None:
    opened = [Image.open(page).convert("RGB") for page in pages]
    ratio = thumb_width / opened[0].width
    thumb_height = round(opened[0].height * ratio)
    gutter = 24
    header = 44
    cols = 2
    rows = (len(opened) + cols - 1) // cols
    sheet = Image.new(
        "RGB",
        (
            cols * thumb_width + (cols + 1) * gutter,
            header + rows * (thumb_height + header) + (rows + 1) * gutter,
        ),
        "#e9edf3",
    )
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    draw.text((gutter, 14), f"{fixture} - {len(opened)} pages", fill="black", font=font)
    for index, page in enumerate(opened):
        row, col = divmod(index, cols)
        x = gutter + col * (thumb_width + gutter)
        y = header + gutter + row * (thumb_height + header + gutter)
        thumb = page.resize((thumb_width, thumb_height), Image.Resampling.LANCZOS)
        sheet.paste(thumb, (x, y))
        draw.text((x, y + thumb_height + 8), f"page {index + 1}", fill="black", font=font)
    sheet.save(output, optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("renders", type=Path)
    args = parser.parse_args()
    root = args.renders.resolve()
    audit: dict[str, list[dict[str, object]]] = {}
    for fixture_dir in sorted(path for path in root.iterdir() if path.is_dir()):
        pages = sorted(
            fixture_dir.glob("page-*.png"),
            key=lambda path: int(path.stem.split("-")[-1]),
        )
        if not pages:
            continue
        fixture_rows: list[dict[str, object]] = []
        for index, page_path in enumerate(pages, start=1):
            with Image.open(page_path) as image:
                bbox = ink_bbox(image)
                width, height = image.size
                touches_edge = bool(
                    bbox
                    and (
                        bbox[0] < 12
                        or bbox[1] < 12
                        or bbox[2] > width - 12
                        or bbox[3] > height - 12
                    )
                )
                footer_only = bool(bbox and bbox[1] > round(height * 0.72))
                fixture_rows.append(
                    {
                        "page": index,
                        "width": width,
                        "height": height,
                        "inkBoundingBox": list(bbox) if bbox else None,
                        "blank": bbox is None,
                        "footerOnly": footer_only,
                        "touchesEdge": touches_edge,
                    }
                )
        audit[fixture_dir.name] = fixture_rows
        contact_sheet(fixture_dir.name, pages, root / f"{fixture_dir.name}-contact-sheet.png")
    (root / "page-geometry-audit.json").write_text(
        json.dumps(audit, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
