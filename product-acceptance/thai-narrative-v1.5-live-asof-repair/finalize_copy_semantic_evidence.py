from __future__ import annotations

import hashlib
from pathlib import Path


ROOT = Path(__file__).resolve().parent
MANIFEST = ROOT / "SHA256SUMS.txt"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


files = sorted(
    (path for path in ROOT.rglob("*") if path.is_file() and path != MANIFEST),
    key=lambda path: path.relative_to(ROOT).as_posix(),
)
entries = [
    (sha256(path), path.relative_to(ROOT).as_posix(), path.stat().st_size)
    for path in files
]
MANIFEST.write_text(
    "".join(f"{digest}  {relative}\n" for digest, relative, _ in entries),
    encoding="utf-8",
    newline="\n",
)

missing = 0
mismatch = 0
for expected, relative, _ in entries:
    target = ROOT / Path(relative)
    if not target.is_file():
        missing += 1
    elif sha256(target) != expected:
        mismatch += 1

print(f"file_count={len(entries)}")
print(f"byte_count={sum(size for _, _, size in entries)}")
print(f"missing={missing}")
print(f"mismatch={mismatch}")
print(f"manifest_sha256={sha256(MANIFEST)}")
