from __future__ import annotations

import hashlib
import json
import subprocess
import zipfile
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]
EVIDENCE = Path(__file__).resolve().parent
R7_ZIP = REPO / "product-acceptance" / "thai-narrative-v1.5-r7.zip"
R71_ZIP = REPO / "product-acceptance" / "thai-narrative-v1.5-r7.1.zip"
EXPECTED_R71_BYTES = 10_709_328
EXPECTED_R71_SHA256 = (
    "9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58"
)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def parse_sums(data: bytes) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in data.decode("utf-8").splitlines():
        if not line.strip():
            continue
        digest, path = line.split(maxsplit=1)
        result[path.strip().replace("\\", "/")] = digest.upper()
    return result


fixtures = [
    "owner-known-0035",
    "owner-unknown",
    "regression-known-0003",
    "comparison-known-bangkok",
    "comparison-known-khon-kaen",
]

r71_sha256 = sha256_file(R71_ZIP)
r71_bytes = R71_ZIP.stat().st_size

with zipfile.ZipFile(R7_ZIP, "r") as r7, zipfile.ZipFile(R71_ZIP, "r") as r71:
    r7_names = [item.filename for item in r7.infolist()]
    r71_names = [item.filename for item in r71.infolist()]
    unsafe = [
        name
        for name in r71_names
        if name.startswith(("/", "\\")) or ".." in Path(name).parts
    ]
    sums = parse_sums(r71.read("SHA256SUMS.txt"))
    checksum_mismatches = [
        path
        for path, expected in sums.items()
        if path not in r71_names or sha256_bytes(r71.read(path)) != expected
    ]

    comparison = json.loads(
        r71.read("evidence/r7-to-r7.1-identity-comparison.json").decode("utf-8")
    )
    immutable_mismatches: list[str] = []
    for item in comparison["files"]:
        path = item["path"]
        if path not in r7_names or path not in r71_names:
            immutable_mismatches.append(path)
            continue
        r7_data = r7.read(path)
        r71_data = r71.read(path)
        if any(
            [
                len(r7_data) != item["r7Bytes"],
                len(r71_data) != item["r71Bytes"],
                sha256_bytes(r7_data) != item["r7Sha256"].upper(),
                sha256_bytes(r71_data) != item["r71Sha256"].upper(),
                r7_data != r71_data,
                item["match"] is not True,
            ]
        ):
            immutable_mismatches.append(path)

    canonical_hashes: dict[str, str] = {}
    canonical_mismatches: list[str] = []
    for fixture in fixtures:
        web_data = r71.read(f"evidence/{fixture}-web-text.txt")
        pdf_data = r71.read(f"evidence/{fixture}-pdf-text.txt")
        canonical_hashes[fixture] = sha256_bytes(web_data)
        if web_data != pdf_data:
            canonical_mismatches.append(fixture)

    engine = json.loads(
        r71.read("evidence/engine-factual-result.json").decode("utf-8")
    )
    engine_by_id = {item["fixtureId"]: item for item in engine["fixtures"]}
    owner = engine_by_id["owner-known-1982-06-06-0035-chiang-mai"]
    regression = engine_by_id["regression-known-1982-06-06-0003-chiang-mai"]
    owner_fact = f"Aquarius {owner['lagnaDegree']}"
    regression_fact = f"Aquarius {regression['lagnaDegree']}"
    unknown_text = r71.read("evidence/owner-unknown-web-text.txt").decode("utf-8")
    unknown_fail_closed = "ลัคนา" not in unknown_text and "เวลาเกิด" in unknown_text

    traceability = json.loads(
        r71.read("evidence/claim-render-traceability.json").decode("utf-8")
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
        r71_bytes == EXPECTED_R71_BYTES,
        r71_sha256 == EXPECTED_R71_SHA256,
        len(r71_names) == 80,
        len(r71_names) == len(set(r71_names)),
        not unsafe,
        len(sums) == 79,
        not checksum_mismatches,
        comparison["comparedFiles"] == 63,
        len(comparison["files"]) == 63,
        comparison["mismatchCount"] == 0,
        not immutable_mismatches,
        not canonical_mismatches,
        owner_fact == "Aquarius 19°19′",
        regression_fact == "Aquarius 9°24′",
        unknown_fail_closed,
        trace_result == (170, 170, 0),
        not git_status,
    ]
)

lines = [
    "verificationBasis: accepted ZIP archives (read-only, direct byte comparison)",
    f"r7ZipSha256: {sha256_file(R7_ZIP)}",
    f"r7ZipEntries: {len(r7_names)}",
    f"r7.1ZipBytes: {r71_bytes}",
    f"r7.1ZipSha256: {r71_sha256}",
    f"r7.1ZipEntries: {len(r71_names)}",
    f"unsafeZipEntries: {len(unsafe)}",
    f"zipChecksumEntries: {len(sums)}",
    f"zipChecksumMismatches: {len(checksum_mismatches)}",
    f"immutableFilesComparedDirectlyBetweenArchives: {len(comparison['files'])}",
    f"immutableMismatches: {len(immutable_mismatches)}",
    f"canonicalWebPdfPairs: {len(fixtures)}/5",
    f"canonicalWebPdfMismatches: {len(canonical_mismatches)}",
]
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
result = "\n".join(lines)
(EVIDENCE / "r71-accepted-archive-identity-result.txt").write_text(
    result, encoding="utf-8", newline="\n"
)
print(result)
if not passed:
    raise SystemExit(1)
