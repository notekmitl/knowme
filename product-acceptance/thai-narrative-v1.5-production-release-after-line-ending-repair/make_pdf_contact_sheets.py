from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parent


def main(environment: str) -> None:
    source_root = ROOT / f"{environment}-rendered"
    output_root = ROOT / f"{environment}-contact-sheets"
    output_root.mkdir(parents=True, exist_ok=True)
    for report_dir in sorted(path for path in source_root.iterdir() if path.is_dir()):
        pages = [Image.open(path).convert("RGB") for path in sorted(report_dir.glob("*.png"))]
        thumb_width = 420
        gap = 18
        label_height = 34
        thumbs = []
        for page in pages:
            height = round(page.height * thumb_width / page.width)
            thumbs.append(page.resize((thumb_width, height)))
        cell_height = max(image.height for image in thumbs) + label_height
        canvas = Image.new(
            "RGB",
            (thumb_width * 2 + gap * 3, cell_height * ((len(thumbs) + 1) // 2) + gap),
            "#d8d8d8",
        )
        draw = ImageDraw.Draw(canvas)
        font = ImageFont.load_default()
        for index, image in enumerate(thumbs):
            column = index % 2
            row = index // 2
            x = gap + column * (thumb_width + gap)
            y = gap + row * cell_height
            draw.text((x, y), f"Page {index + 1}", fill="black", font=font)
            canvas.paste(image, (x, y + label_height))
        destination = output_root / f"{report_dir.name}-contact-sheet.png"
        canvas.save(destination, optimize=True)
        print(destination)


if __name__ == "__main__":
    main(sys.argv[1])
