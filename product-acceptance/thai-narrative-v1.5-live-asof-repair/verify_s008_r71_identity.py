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
COMPARISON = (
    REPO
    / "product-acceptance"
    / "thai-narrative-v1.5-r7.1"
    / "evidence"
    / "r7-to-r7.1-identity-comparison.json"
)
EXPECTED_ZIP_SHA = "9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58"


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


comparison = json.loads(COMPARISON.read_text(encoding="utf-8"))
with zipfile.ZipFile(R7_ZIP) as r7, zipfile.ZipFile(R71_ZIP) as r71:
    r71_infos = r71.infolist()
    r71_names = [entry.filename for entry in r71_infos]
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
    immutable_mismatches: list[str] = []
    for item in comparison["files"]:
        path = item["path"]
        try:
            r7_bytes = r7.read(path)
            r71_bytes = r71.read(path)
        except KeyError:
            immutable_mismatches.append(path)
            continue
        if not (
            sha256_bytes(r7_bytes) == item["r7Sha256"]
            and sha256_bytes(r71_bytes) == item["r71Sha256"]
            and r7_bytes == r71_bytes
        ):
            immutable_mismatches.append(path)

    fixtures = [
        "owner-known-0035",
        "owner-unknown",
        "regression-known-0003",
        "comparison-known-bangkok",
        "comparison-known-khon-kaen",
    ]
    canonical_mismatches = [
        fixture
        for fixture in fixtures
        if r71.read(f"evidence/{fixture}-web-text.txt")
        != r71.read(f"evidence/{fixture}-pdf-text.txt")
    ]
    engine = json.loads(r71.read("evidence/engine-factual-result.json"))
    traceability = json.loads(r71.read("evidence/claim-render-traceability.json"))
    unknown_text = r71.read("evidence/owner-unknown-web-text.txt").decode("utf-8")

engine_by_id = {item["fixtureId"]: item for item in engine["fixtures"]}
owner = engine_by_id["owner-known-1982-06-06-0035-chiang-mai"]
regression = engine_by_id["regression-known-1982-06-06-0003-chiang-mai"]
owner_fact = f"Aquarius {owner['lagnaDegree']}"
regression_fact = f"Aquarius {regression['lagnaDegree']}"
unknown_fail_closed = "ลัคนา" not in unknown_text and "เวลาเกิด" in unknown_text
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
modified_paths = subprocess.run(
    ["git", "status", "--porcelain=v1", "--", *immutable_paths],
    cwd=REPO,
    check=True,
    capture_output=True,
    text=True,
    encoding="utf-8",
).stdout.splitlines()

r71_bytes = R71_ZIP.stat().st_size
r71_sha = sha256_file(R71_ZIP)
passed = all(
    [
        r71_bytes == 10_709_328,
        r71_sha == EXPECTED_ZIP_SHA,
        len(r71_infos) == 80,
        not unsafe,
        len(sums) == 79,
        not checksum_mismatches,
        comparison["comparedFiles"] == 63,
        not immutable_mismatches,
        not canonical_mismatches,
        owner_fact == "Aquarius 19°19′",
        regression_fact == "Aquarius 9°24′",
        unknown_fail_closed,
        trace_result == (170, 170, 0),
        not modified_paths,
    ]
)

lines = [
    "identitySource: immutable R7 and R7.1 ZIP bytes; working-checkout line-ending filters excluded",
    f"r7.1ZipBytes: {r71_bytes}",
    f"r7.1ZipSha256: {r71_sha}",
    f"r7.1ZipEntries: {len(r71_infos)}",
    f"unsafeZipEntries: {len(unsafe)}",
    f"zipChecksumEntries: {len(sums)}",
    f"zipChecksumMismatches: {len(checksum_mismatches)}",
    f"immutableFilesCompared: {comparison['comparedFiles']}",
    f"immutableMismatches: {len(immutable_mismatches)}",
    f"canonicalWebPdfPairs: {len(fixtures)}/5",
    f"canonicalWebPdfMismatches: {len(canonical_mismatches)}",
    f"ownerKnown: {owner_fact}",
    f"regression0003: {regression_fact}",
    f"unknownFailClosedNoLagna: {str(unknown_fail_closed).lower()}",
    f"claimTraceability: {trace_result[1]}/{trace_result[0]}",
    f"r1ThroughR7.1ModifiedPaths: {len(modified_paths)}",
    f"result: {'PASS' if passed else 'BLOCKED'}",
    "",
]
output = "\n".join(lines)
(EVIDENCE / "s008-final-r71-identity-archive-result.txt").write_text(
    output, encoding="utf-8", newline="\n"
)
print(output)
if not passed:
    raise SystemExit(1)
