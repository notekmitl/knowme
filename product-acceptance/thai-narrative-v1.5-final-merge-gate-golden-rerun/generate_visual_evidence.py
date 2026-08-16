from __future__ import annotations

import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFont


ROOT = Path(__file__).resolve().parent
SETS = {
    "main": ROOT / "main-golden",
    "branch": ROOT / "branch-golden",
    "repaired": ROOT / "repaired-actual",
}
NAMES = sorted(path.name for path in SETS["repaired"].glob("*.png"))
EXPECTED_PREFIXES = {
    f"{profile}_{viewport}"
    for profile in "adefgh"
    for viewport in ("desktop", "tablet", "mobile")
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def open_rgba(path: Path) -> Image.Image:
    with Image.open(path) as image:
        return image.convert("RGBA")


def padded(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    canvas = Image.new("RGBA", size, (255, 255, 255, 255))
    canvas.paste(image, (0, 0))
    return canvas


def compare(left: Image.Image, right: Image.Image) -> tuple[dict[str, object], np.ndarray, Image.Image]:
    size = (max(left.width, right.width), max(left.height, right.height))
    a = padded(left, size)
    b = padded(right, size)
    arr_a = np.asarray(a)
    arr_b = np.asarray(b)
    mask = np.any(arr_a != arr_b, axis=2)
    count = int(mask.sum())
    if count:
        ys, xs = np.where(mask)
        bbox: list[int] | None = [int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)]
    else:
        bbox = None
    metrics = {
        "comparisonCanvas": {"width": size[0], "height": size[1]},
        "exactPixelDifferenceCount": count,
        "differencePercentage": round(count * 100 / (size[0] * size[1]), 6),
        "changedBoundingBox": bbox,
        "dimensionsEqual": left.size == right.size,
        "pixelIdentical": count == 0 and left.size == right.size,
    }
    base = np.asarray(ImageEnhance.Color(b.convert("RGB")).enhance(0.18)).copy()
    if count:
        base[mask] = (0.25 * base[mask] + 0.75 * np.array([232, 37, 37])).astype(np.uint8)
    return metrics, mask, Image.fromarray(base, mode="RGB")


def thumbnail(image: Image.Image, width: int = 280) -> Image.Image:
    height = round(image.height * width / image.width)
    return image.convert("RGB").resize((width, height), Image.Resampling.LANCZOS)


def triptych(name: str, images: dict[str, Image.Image], destination: Path) -> None:
    labels = ("MAIN", "BRANCH", "REPAIRED")
    thumbs = [thumbnail(images[key]) for key in ("main", "branch", "repaired")]
    gutter, header = 18, 46
    width = sum(image.width for image in thumbs) + gutter * 4
    height = max(image.height for image in thumbs) + header + gutter * 2
    sheet = Image.new("RGB", (width, height), "#E9EDF3")
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for index, (label, image) in enumerate(zip(labels, thumbs)):
        x = gutter + index * (image.width + gutter)
        draw.text((x, 12), f"{label}  {name}", fill="black", font=font)
        sheet.paste(image, (x, header))
    sheet.save(destination, optimize=True)


def contact_sheet(profile: str, rows: list[tuple[str, dict[str, Image.Image]]], destination: Path) -> None:
    gutter, header, label_width = 18, 42, 90
    prepared: list[tuple[str, list[Image.Image]]] = []
    for viewport, images in rows:
        prepared.append((viewport, [thumbnail(images[key], 260) for key in ("main", "branch", "repaired")]))
    row_heights = [max(image.height for image in images) + header for _, images in prepared]
    width = label_width + 260 * 3 + gutter * 5
    height = header + sum(row_heights) + gutter * (len(prepared) + 1)
    sheet = Image.new("RGB", (width, height), "#E9EDF3")
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    draw.text((gutter, 12), f"PROFILE {profile.upper()} | MAIN / BRANCH / REPAIRED", fill="black", font=font)
    y = header + gutter
    for (viewport, images), row_height in zip(prepared, row_heights):
        draw.text((gutter, y + 12), viewport.upper(), fill="black", font=font)
        for index, image in enumerate(images):
            x = label_width + gutter * 2 + index * (260 + gutter)
            sheet.paste(image, (x, y + header))
        y += row_height + gutter
    sheet.save(destination, optimize=True)


def main() -> None:
    if len(NAMES) != 18:
        raise SystemExit(f"expected 18 repaired images, found {len(NAMES)}")
    prefixes = {name.split("_thai_consumer_life_timeline.png")[0] for name in NAMES}
    if prefixes != EXPECTED_PREFIXES:
        raise SystemExit("image name allowlist mismatch")
    for directory in SETS.values():
        if sorted(path.name for path in directory.glob("*.png")) != NAMES:
            raise SystemExit(f"set mismatch: {directory}")

    triptych_dir = ROOT / "triptychs"
    main_diff_dir = ROOT / "diff-actual-vs-main"
    branch_diff_dir = ROOT / "diff-actual-vs-branch"
    contact_dir = ROOT / "contact-sheets"
    for directory in (triptych_dir, main_diff_dir, branch_diff_dir, contact_dir):
        directory.mkdir(parents=True, exist_ok=True)

    rows: list[dict[str, object]] = []
    profile_images: dict[str, list[tuple[str, dict[str, Image.Image]]]] = {}
    for name in NAMES:
        paths = {key: directory / name for key, directory in SETS.items()}
        images = {key: open_rgba(path) for key, path in paths.items()}
        main_branch, _, _ = compare(images["main"], images["branch"])
        main_actual, _, main_visual = compare(images["main"], images["repaired"])
        branch_actual, _, branch_visual = compare(images["branch"], images["repaired"])
        main_visual.save(main_diff_dir / name, optimize=True)
        branch_visual.save(branch_diff_dir / name, optimize=True)
        triptych(name, images, triptych_dir / name)
        profile, viewport = name.split("_", 2)[:2]
        profile_images.setdefault(profile, []).append((viewport, images))
        rows.append(
            {
                "path": f"test/validation/thai_mirror_qa_harness/screenshots/{name}",
                "profile": profile.upper(),
                "viewport": viewport,
                "sources": {
                    "main": "git commit 22cbb3cfcb583b63fe8d48a164d5083d9ee32163",
                    "branch": "tracked golden at starting HEAD 5b2e4cf84ed67f4b1cbe1e66ac296caa995ff3c7",
                    "repaired": "fresh Flutter test actual after four-string Life Map repair",
                },
                "images": {
                    key: {
                        "dimensions": {"width": image.width, "height": image.height},
                        "bytes": paths[key].stat().st_size,
                        "sha256": sha256(paths[key]),
                    }
                    for key, image in images.items()
                },
                "comparisons": {
                    "mainVsBranch": main_branch,
                    "mainVsRepaired": main_actual,
                    "branchVsRepaired": branch_actual,
                },
            }
        )

    viewport_order = {"desktop": 0, "tablet": 1, "mobile": 2}
    for profile, items in profile_images.items():
        items.sort(key=lambda item: viewport_order[item[0]])
        contact_sheet(profile, items, contact_dir / f"profile-{profile}.png")

    payload = {
        "schema": "knowme-v1.5-life-map-golden-three-way-comparison-v1",
        "comparisonRule": "RGBA exact pixel comparison on a top-left aligned white canvas sized to the union dimensions",
        "files": rows,
    }
    (ROOT / "pixel-comparison-metrics.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    manifest_lines = [
        "path\tmainDimensions\tmainSha256\tbranchDimensions\tbranchSha256\trepairedDimensions\trepairedSha256"
    ]
    metric_lines = [
        "| Path | Main vs repaired: dimensions | Main vs repaired: pixel diff | Main vs repaired: bbox | Branch vs repaired: pixel diff | Branch vs repaired: bbox |",
        "|---|---|---:|---|---:|---|",
    ]
    for row in rows:
        images = row["images"]
        comparisons = row["comparisons"]
        dims = lambda item: f"{item['dimensions']['width']}x{item['dimensions']['height']}"
        manifest_lines.append(
            "\t".join(
                [
                    row["path"],
                    dims(images["main"]), images["main"]["sha256"],
                    dims(images["branch"]), images["branch"]["sha256"],
                    dims(images["repaired"]), images["repaired"]["sha256"],
                ]
            )
        )
        main_actual = comparisons["mainVsRepaired"]
        branch_actual = comparisons["branchVsRepaired"]
        metric_lines.append(
            f"| `{row['path']}` | {main_actual['dimensionsEqual']} | "
            f"{main_actual['exactPixelDifferenceCount']} ({main_actual['differencePercentage']:.6f}%) | "
            f"{main_actual['changedBoundingBox']} | "
            f"{branch_actual['exactPixelDifferenceCount']} ({branch_actual['differencePercentage']:.6f}%) | "
            f"{branch_actual['changedBoundingBox']} |"
        )
    (ROOT / "main-branch-repaired-sha256-manifest.tsv").write_text(
        "\n".join(manifest_lines) + "\n", encoding="utf-8"
    )
    (ROOT / "pixel-comparison-metrics.md").write_text(
        "# Pixel Comparison Metrics\n\n" + "\n".join(metric_lines) + "\n", encoding="utf-8"
    )
    (ROOT / "golden-allowlist.txt").write_text(
        "\n".join(row["path"] for row in rows) + "\n", encoding="utf-8"
    )
    exact_main = sum(row["comparisons"]["mainVsRepaired"]["pixelIdentical"] for row in rows)
    print(f"files={len(rows)} repairedPixelIdenticalToMain={exact_main}")


if __name__ == "__main__":
    main()
