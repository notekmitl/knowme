import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw


FIXTURES = (
    "known",
    "unknown",
    "owner-known-0035",
    "owner-unknown",
    "regression-known-0003",
    "comparison-known-bangkok",
    "comparison-known-khon-kaen",
)
KINDS = ("browser-print", "dedicated-report")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    digest.update(path.read_bytes())
    return digest.hexdigest().upper()


def compare(approved: Path, current: Path) -> dict[str, object]:
    with Image.open(approved).convert("RGB") as approved_image:
        with Image.open(current).convert("RGB") as current_image:
            if approved_image.size != current_image.size:
                return {
                    "dimensionsMatch": False,
                    "approvedDimensions": approved_image.size,
                    "currentDimensions": current_image.size,
                }
            approved_pixels = np.asarray(approved_image, dtype=np.int16)
            current_pixels = np.asarray(current_image, dtype=np.int16)
            delta = np.abs(approved_pixels - current_pixels)
            changed = np.any(delta != 0, axis=2)
            changed_pixels = int(changed.sum())
            total_pixels = int(changed.size)
            return {
                "dimensionsMatch": True,
                "dimensions": approved_image.size,
                "changedPixels": changed_pixels,
                "totalPixels": total_pixels,
                "exactPixelPercent": round(
                    (total_pixels - changed_pixels) * 100 / total_pixels, 6
                ),
                "meanAbsoluteChannelDelta": round(float(delta.mean()), 6),
                "maxChannelDelta": int(delta.max()),
                "differenceBounds": ImageChops.difference(
                    approved_image, current_image
                ).getbbox(),
            }


def contact_sheet(
    approved_root: Path, current_root: Path, fixture: str, output: Path
) -> None:
    cell_width = 454
    cell_height = 644
    label_height = 34
    sheet = Image.new("RGB", (cell_width * 2, (cell_height + label_height) * 2), "white")
    draw = ImageDraw.Draw(sheet)
    for row, kind in enumerate(KINDS):
        name = f"{kind}-{fixture}-page-02.png"
        for column, (label, root) in enumerate(
            (("OWNER-APPROVED R4", approved_root), ("CURRENT LIVE FLOW", current_root))
        ):
            with Image.open(root / name).convert("RGB") as source:
                resized = source.copy()
                resized.thumbnail((cell_width, cell_height), Image.Resampling.LANCZOS)
                x = column * cell_width + (cell_width - resized.width) // 2
                y = row * (cell_height + label_height) + label_height
                sheet.paste(resized, (x, y))
            draw.text(
                (column * cell_width + 8, row * (cell_height + label_height) + 8),
                f"{label} | {kind} | {fixture}",
                fill="black",
            )
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--approved-root", type=Path, required=True)
    parser.add_argument("--current-root", type=Path, required=True)
    parser.add_argument("--contact-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    approved_names = sorted(path.name for path in args.approved_root.glob("*.png"))
    current_names = sorted(path.name for path in args.current_root.glob("*.png"))
    names = sorted(set(approved_names) | set(current_names))
    rows = []
    for name in names:
        approved = args.approved_root / name
        current = args.current_root / name
        row = {
            "file": name,
            "approvedPresent": approved.is_file(),
            "currentPresent": current.is_file(),
        }
        if approved.is_file() and current.is_file():
            row["approvedSha256"] = sha256(approved)
            row["currentSha256"] = sha256(current)
            row["byteIdentical"] = row["approvedSha256"] == row["currentSha256"]
            row["pixelComparison"] = compare(approved, current)
        rows.append(row)

    for fixture in FIXTURES:
        contact_sheet(
            args.approved_root,
            args.current_root,
            fixture,
            args.contact_root / f"infographic-page-approved-current-{fixture}.png",
        )

    missing = [row["file"] for row in rows if not row["approvedPresent"] or not row["currentPresent"]]
    mismatches = [row for row in rows if not row.get("byteIdentical", False)]
    payload = {
        "approvedCount": len(approved_names),
        "currentCount": len(current_names),
        "missingCount": len(missing),
        "byteIdenticalCount": len(rows) - len(mismatches),
        "byteMismatchCount": len(mismatches),
        "mismatchFiles": [row["file"] for row in mismatches],
        "manualReviewScope": "All byte mismatches; byte-identical pages inherit approved pixels.",
        "rows": rows,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        f"approved={payload['approvedCount']}|current={payload['currentCount']}|"
        f"missing={payload['missingCount']}|byteIdentical={payload['byteIdenticalCount']}|"
        f"byteMismatch={payload['byteMismatchCount']}|contactSheets={len(FIXTURES)}"
    )
    if payload["missingCount"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
