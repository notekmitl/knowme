from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parent / "live-oracle-renders"
THUMBNAIL_WIDTH = 300
LABEL_HEIGHT = 28
GAP = 16
BACKGROUND = "#e8e4dc"


for fixture in sorted(path for path in ROOT.iterdir() if path.is_dir()):
    pages = sorted(fixture.glob("page-*.png"))
    thumbnails: list[Image.Image] = []
    for page in pages:
        image = Image.open(page).convert("RGB")
        height = round(image.height * THUMBNAIL_WIDTH / image.width)
        thumbnails.append(image.resize((THUMBNAIL_WIDTH, height)))

    columns = min(4, len(thumbnails))
    rows = (len(thumbnails) + columns - 1) // columns
    cell_height = max(image.height for image in thumbnails) + LABEL_HEIGHT
    sheet = Image.new(
        "RGB",
        (
            GAP + columns * (THUMBNAIL_WIDTH + GAP),
            GAP + rows * (cell_height + GAP),
        ),
        BACKGROUND,
    )
    draw = ImageDraw.Draw(sheet)
    for index, image in enumerate(thumbnails):
        row, column = divmod(index, columns)
        x = GAP + column * (THUMBNAIL_WIDTH + GAP)
        y = GAP + row * (cell_height + GAP)
        sheet.paste(image, (x, y + LABEL_HEIGHT))
        draw.text((x, y + 5), f"page {index + 1}", fill="black")
    sheet.save(ROOT / f"{fixture.name}-contact-sheet.png")
    print(f"{fixture.name}: {len(pages)} pages")
