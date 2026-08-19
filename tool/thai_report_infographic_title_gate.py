#!/usr/bin/env python3
"""Validate Revision 4 infographic title pixels and artifact provenance."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path

from PIL import Image


FIXTURES = (
    "known",
    "unknown",
    "owner-known-0035",
    "owner-unknown",
    "regression-known-0003",
    "comparison-known-bangkok",
    "comparison-known-khon-kaen",
    "stress-known-longest",
    "stress-unknown-longest",
    "stress-opportunity-caution-longest",
    "stress-disclaimer-longest",
    "stress-thai-multiline",
    "stress-regression-1972",
    "year-boundary-2569",
    "year-boundary-2570",
)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def validate(artifact_root: Path, expected_source_head: str) -> dict[str, object]:
    artifact_root = artifact_root.resolve()
    require(artifact_root.is_dir(), f"artifact root missing: {artifact_root}")
    expected_png_names = {f"annual-infographic-{fixture}.png" for fixture in FIXTURES}
    actual_png_names = {path.name for path in artifact_root.glob("annual-infographic-*.png")}
    require(actual_png_names == expected_png_names, "15-fixture PNG inventory mismatch")

    aggregate = json.loads((artifact_root / "infographic-title-integrity.json").read_text("utf-8"))
    require(aggregate["sourceHead"] == expected_source_head, "aggregate source HEAD mismatch")
    require(aggregate["fixtureCount"] == 15, "aggregate fixture count mismatch")
    require(aggregate["missing"] == 0, "aggregate missing count is nonzero")
    require(aggregate["mismatch"] == 0, "aggregate mismatch count is nonzero")
    require(aggregate["duplicateOutputPaths"] == 0, "aggregate duplicate path count is nonzero")
    require(aggregate["titleRasterFailures"] == 0, "aggregate title failure count is nonzero")

    rows: list[dict[str, object]] = []
    output_names: set[str] = set()
    input_identities: set[str] = set()
    for fixture in FIXTURES:
        png = artifact_root / f"annual-infographic-{fixture}.png"
        sidecar_path = artifact_root / f"{fixture}-identity.json"
        require(sidecar_path.is_file(), f"missing sidecar: {fixture}")
        sidecar = json.loads(sidecar_path.read_text("utf-8"))
        expected_title = "ดวงชะตาปี 2570" if fixture == "year-boundary-2570" else "ดวงชะตาปี 2569"
        require(sidecar["fixtureId"] == fixture, f"fixture identity mismatch: {fixture}")
        require(sidecar["sourceHead"] == expected_source_head, f"source HEAD mismatch: {fixture}")
        require(sidecar["artifactRelativePath"] == png.name, f"output path mismatch: {fixture}")
        require(sidecar["title"] == expected_title, f"title mismatch: {fixture}")
        require(re.fullmatch(r"ดวงชะตาปี 25\d{2}", sidecar["title"]) is not None, f"title contract: {fixture}")
        require(sidecar["titleWidgetCount"] == 1, f"title widget count: {fixture}")
        require(sidecar["titleSemanticContains"] == expected_title, f"title semantics: {fixture}")
        require(sidecar["captureRepeatByteIdentical"] is True, f"repeat capture mismatch: {fixture}")
        require(sidecar["pngDimensions"] == {"width": 1080, "height": 1920}, f"sidecar dimensions: {fixture}")
        actual_png_hash = sha256_file(png)
        require(actual_png_hash == sidecar["pngSha256"], f"stale/swapped PNG: {fixture}")

        bounds = sidecar["layoutBounds1080x1920"]
        title_bounds = bounds["title"]
        theme_bounds = bounds["theme"]
        left, top, right, bottom = (int(title_bounds[key]) for key in ("left", "top", "right", "bottom"))
        require(left >= 36 and top >= 36 and right <= 1080 and bottom <= 1920, f"title safe area: {fixture}")
        require(bottom <= int(theme_bounds["top"]), f"title/theme overlap: {fixture}")

        sample_bounds = sidecar["titleRasterSampleBounds"]
        sample_left, sample_top, sample_right, sample_bottom = (
            int(sample_bounds[key]) for key in ("left", "top", "right", "bottom")
        )
        require(
            sample_left >= 0
            and sample_top >= 0
            and sample_right <= 1080
            and sample_bottom <= 1920,
            f"title sample bounds: {fixture}",
        )

        with Image.open(png) as image:
            require(image.size == (1080, 1920), f"PNG dimensions: {fixture}")
            rgba = image.convert("RGBA")
            crop = rgba.crop((sample_left, sample_top, sample_right, sample_bottom))
            raw = crop.tobytes()
        title_region_hash = sha256_bytes(raw)
        background_hash = sha256_bytes(
            bytes((16, 24, 50, 255))
            * ((sample_right - sample_left) * (sample_bottom - sample_top))
        )
        cream_pixels = sum(
            1
            for red, green, blue, alpha in zip(raw[0::4], raw[1::4], raw[2::4], raw[3::4])
            if red >= 210 and green >= 200 and blue >= 170 and alpha >= 240
        )
        require(cream_pixels > 4000, f"title painted-pixel failure: {fixture}")
        require(title_region_hash != background_hash, f"background-only title region: {fixture}")
        require(title_region_hash == sidecar["titleRegionSha256"], f"title region hash mismatch: {fixture}")
        require(background_hash == sidecar["titleBackgroundControlSha256"], f"background control mismatch: {fixture}")
        require(cream_pixels == sidecar["titleCreamPixelCount"], f"title pixel count mismatch: {fixture}")
        require(bool(sidecar["inputIdentitySha256"]), f"input identity missing: {fixture}")
        require(png.name not in output_names, f"duplicate output basename: {png.name}")
        output_names.add(png.name)
        input_identities.add(sidecar["inputIdentitySha256"])
        rows.append(
            {
                "fixtureId": fixture,
                "png": png.name,
                "pngSha256": actual_png_hash,
                "title": expected_title,
                "titleBounds": title_bounds,
                "titleCreamPixelCount": cream_pixels,
                "titleRegionSha256": title_region_hash,
                "result": "PASS",
            }
        )

    require(len(output_names) == 15, "output basename uniqueness failure")
    require(len(input_identities) == 15, "input identity uniqueness failure")
    return {
        "status": "PASS",
        "sourceHead": expected_source_head,
        "fixtureCount": 15,
        "dimensionsPassed": 15,
        "titleWidgetPassed": 15,
        "titleSemanticPassed": 15,
        "titleRasterPassed": 15,
        "repeatCapturePassed": 15,
        "identityPassed": 15,
        "missing": 0,
        "mismatch": 0,
        "unlisted": 0,
        "rows": rows,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("artifact_root", type=Path)
    parser.add_argument("expected_source_head")
    parser.add_argument("--json-output", type=Path)
    args = parser.parse_args()
    result = validate(args.artifact_root, args.expected_source_head)
    payload = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.json_output:
        args.json_output.write_text(payload, encoding="utf-8", newline="\n")
    print(
        "INFOGRAPHIC_TITLE_GATE "
        f"status={result['status']} fixtures={result['fixtureCount']} "
        f"titleRaster={result['titleRasterPassed']} identity={result['identityPassed']} "
        "missing=0 mismatch=0 unlisted=0"
    )


if __name__ == "__main__":
    main()
