from __future__ import annotations

import hashlib
import json
import subprocess
import zipfile
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]
EVIDENCE = Path(__file__).resolve().parent
R7 = REPO / "product-acceptance" / "thai-narrative-v1.5-r7"
R71 = REPO / "product-acceptance" / "thai-narrative-v1.5-r7.1"
ZIP = REPO / "product-acceptance" / "thai-narrative-v1.5-r7.1.zip"
R7_ZIP = REPO / "product-acceptance" / "thai-narrative-v1.5-r7.zip"
EXPECTED_ZIP_SHA = "9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58"


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def parse_sums(text: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in text.splitlines():
        if not line.strip():
            continue
        digest, path = line.split(maxsplit=1)
        result[path.strip().replace("\\", "/")] = digest.upper()
    return result


zip_sha = sha256_file(ZIP)
zip_bytes = ZIP.stat().st_size
with zipfile.ZipFile(ZIP, "r") as archive:
    infos = archive.infolist()
    names = [info.filename for info in infos]
    if len(names) != len(set(names)):
        raise RuntimeError("Duplicate ZIP entries")
    unsafe = [
        name
        for name in names
        if name.startswith(("/", "\\")) or ".." in Path(name).parts
    ]
    zip_sums = parse_sums(archive.read("SHA256SUMS.txt").decode("utf-8"))
    zip_mismatches = [
        path
        for path, expected in zip_sums.items()
        if path not in names or sha256_bytes(archive.read(path)) != expected
    ]

comparison = json.loads(
    (R71 / "evidence" / "r7-to-r7.1-identity-comparison.json").read_text(
        encoding="utf-8"
    )
)
immutable_mismatches: list[str] = []
with zipfile.ZipFile(R7_ZIP, "r") as r7_archive, zipfile.ZipFile(
    ZIP, "r"
) as r71_archive:
    for item in comparison["files"]:
        relative = item["path"]
        try:
            r7_bytes = r7_archive.read(relative)
            r71_bytes = r71_archive.read(relative)
        except KeyError:
            immutable_mismatches.append(relative)
            continue
        if (
            sha256_bytes(r7_bytes) != item["r7Sha256"]
            or sha256_bytes(r71_bytes) != item["r71Sha256"]
            or r7_bytes != r71_bytes
        ):
            immutable_mismatches.append(relative)

fixtures = [
    "owner-known-0035",
    "owner-unknown",
    "regression-known-0003",
    "comparison-known-bangkok",
    "comparison-known-khon-kaen",
]
canonical_hashes: dict[str, str] = {}
canonical_mismatches: list[str] = []
for fixture in fixtures:
    web = R71 / "evidence" / f"{fixture}-web-text.txt"
    pdf = R71 / "evidence" / f"{fixture}-pdf-text.txt"
    web_bytes = web.read_bytes()
    pdf_bytes = pdf.read_bytes()
    canonical_hashes[fixture] = sha256_bytes(web_bytes)
    if web_bytes != pdf_bytes:
        canonical_mismatches.append(fixture)

engine = json.loads(
    (R71 / "evidence" / "engine-factual-result.json").read_text(encoding="utf-8")
)
engine_by_id = {item["fixtureId"]: item for item in engine["fixtures"]}
owner = engine_by_id["owner-known-1982-06-06-0035-chiang-mai"]
regression = engine_by_id["regression-known-1982-06-06-0003-chiang-mai"]
owner_fact = f"Aquarius {owner['lagnaDegree']}"
regression_fact = f"Aquarius {regression['lagnaDegree']}"
unknown_text = (R71 / "evidence" / "owner-unknown-web-text.txt").read_text(
    encoding="utf-8"
)
unknown_fail_closed = "ลัคนา" not in unknown_text and "เวลาเกิด" in unknown_text

traceability = json.loads(
    (R71 / "evidence" / "claim-render-traceability.json").read_text(
        encoding="utf-8"
    )
)
trace_result = (
    traceability["totalClaims"],
    traceability["expressedFoundInCanonicalWebAndPdf"],
    len(traceability["failures"]),
)

immutable_paths = [
    f"product-acceptance/thai-narrative-v1.5-r{round_name}"
    for round_name in ("1", "2", "3", "4", "5", "6", "7", "7.1")
] + [
    "product-acceptance/thai-narrative-v1.5-r7.zip",
    "product-acceptance/thai-narrative-v1.5-r7.1.zip",
    "product-acceptance/thai-narrative-v1.5-r7-package-identity.json",
    "product-acceptance/thai-narrative-v1.5-r7.1-package-identity.json",
]
git_status = subprocess.run(
    ["git", "status", "--porcelain=v1", "--", *immutable_paths],
    cwd=REPO,
    check=True,
    capture_output=True,
    text=True,
    encoding="utf-8",
).stdout.splitlines()

passed = all(
    [
        zip_bytes == 10_709_328,
        zip_sha == EXPECTED_ZIP_SHA,
        len(infos) == 80,
        not unsafe,
        len(zip_sums) == 79,
        not zip_mismatches,
        comparison["comparedFiles"] == 63,
        not immutable_mismatches,
        len(canonical_mismatches) == 0,
        owner_fact == "Aquarius 19°19′",
        regression_fact == "Aquarius 9°24′",
        unknown_fail_closed,
        trace_result == (170, 170, 0),
        not git_status,
    ]
)

lines = [
    f"r7.1ZipBytes: {zip_bytes}",
    f"r7.1ZipSha256: {zip_sha}",
    f"r7.1ZipEntries: {len(infos)}",
    f"unsafeZipEntries: {len(unsafe)}",
    f"zipChecksumEntries: {len(zip_sums)}",
    f"zipChecksumMismatches: {len(zip_mismatches)}",
    f"immutableFilesCompared: {comparison['comparedFiles']}",
    f"immutableMismatches: {len(immutable_mismatches)}",
    f"canonicalWebPdfPairs: {len(fixtures)}/5",
    f"canonicalWebPdfMismatches: {len(canonical_mismatches)}",
]
for path in immutable_mismatches:
    lines.append(f"immutableMismatchPath: {path}")
for fixture in fixtures:
    lines.append(f"{fixture} canonicalWebPdfSha256: {canonical_hashes[fixture]}")
lines += [
    f"ownerKnown: {owner_fact}",
    f"regression0003: {regression_fact}",
    f"unknownFailClosedNoLagna: {str(unknown_fail_closed).lower()}",
    f"claimTraceability: {trace_result[1]}/{trace_result[0]}",
    f"r1ThroughR7.1ModifiedPaths: {len(git_status)}",
    f"result: {'PASS' if passed else 'BLOCKED'}",
    "",
]
(EVIDENCE / "acceptance-identity-result.txt").write_text(
    "\n".join(lines), encoding="utf-8", newline="\n"
)
print("\n".join(lines))
if not passed:
    raise SystemExit(1)
