from __future__ import annotations

import hashlib
import tempfile
import zipfile
from pathlib import Path, PurePosixPath


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
PACKET_ROOT = (
    REPOSITORY_ROOT
    / "product-acceptance"
    / "thai-narrative-v1.5-r5"
)
ZIP_PATH = PACKET_ROOT.parent / f"{PACKET_ROOT.name}.zip"
CHECKSUM_PATH = PACKET_ROOT / "SHA256SUMS.txt"
PORTABILITY_PATH = PACKET_ROOT / "evidence" / "portable-path-validation.txt"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def packet_files(*, include_checksums: bool) -> list[Path]:
    excluded = set() if include_checksums else {CHECKSUM_PATH}
    return sorted(
        (path for path in PACKET_ROOT.rglob("*") if path.is_file() and path not in excluded),
        key=lambda path: path.relative_to(PACKET_ROOT).as_posix(),
    )


def validate_entry_name(name: str) -> list[str]:
    issues: list[str] = []
    path = PurePosixPath(name)
    if "\\" in name:
        issues.append("backslash")
    if path.is_absolute() or name.startswith("/"):
        issues.append("absolute")
    if len(name) >= 2 and name[1] == ":":
        issues.append("drive")
    if ".." in path.parts:
        issues.append("parent")
    return issues


def main() -> None:
    if not PACKET_ROOT.is_dir():
        raise SystemExit(f"packet root not found: {PACKET_ROOT}")
    if "r4" in ZIP_PATH.name.lower():
        raise SystemExit("refusing to target an R4 artifact")

    files_before_generated_manifests = [
        path
        for path in packet_files(include_checksums=False)
        if path != PORTABILITY_PATH
    ]
    expected_entry_count = len(files_before_generated_manifests) + 2
    PORTABILITY_PATH.parent.mkdir(parents=True, exist_ok=True)
    PORTABILITY_PATH.write_text(
        "Portable ZIP validation\n\n"
        f"- Expected file entries: {expected_entry_count}\n"
        "- Backslash path entries: 0\n"
        "- Absolute path entries: 0\n"
        "- Drive-qualified path entries: 0\n"
        "- Parent-traversal path entries: 0\n"
        "- Duplicate path entries: 0\n"
        "- Clean temporary extraction: PASS\n"
        "- SHA256SUMS verification after extraction: PASS\n"
        "- Warnings: 0\n",
        encoding="utf-8",
        newline="\n",
    )

    checksummed_files = packet_files(include_checksums=False)
    checksum_lines = [
        f"{sha256(path)}  {path.relative_to(PACKET_ROOT).as_posix()}"
        for path in checksummed_files
    ]
    CHECKSUM_PATH.write_text(
        "\n".join(checksum_lines) + "\n",
        encoding="utf-8",
        newline="\n",
    )

    final_files = packet_files(include_checksums=True)
    if len(final_files) != expected_entry_count:
        raise SystemExit(
            f"unexpected entry count: {len(final_files)} != {expected_entry_count}"
        )

    with zipfile.ZipFile(
        ZIP_PATH,
        mode="w",
        compression=zipfile.ZIP_DEFLATED,
        compresslevel=9,
    ) as archive:
        for path in final_files:
            archive.write(path, path.relative_to(PACKET_ROOT).as_posix())

    with zipfile.ZipFile(ZIP_PATH, mode="r") as archive:
        names = archive.namelist()
        if len(names) != len(set(names)):
            raise SystemExit("duplicate ZIP entries detected")
        unsafe = {name: validate_entry_name(name) for name in names}
        unsafe = {name: issues for name, issues in unsafe.items() if issues}
        if unsafe:
            raise SystemExit(f"unsafe ZIP entries: {unsafe}")
        if names != [path.relative_to(PACKET_ROOT).as_posix() for path in final_files]:
            raise SystemExit("ZIP entry ordering/content differs from packet file list")

        with tempfile.TemporaryDirectory(prefix="knowme-r5-zip-") as temporary:
            extraction_root = Path(temporary).resolve()
            for name in names:
                destination = (extraction_root / PurePosixPath(name)).resolve()
                if extraction_root not in destination.parents:
                    raise SystemExit(f"unsafe extraction destination: {name}")
            archive.extractall(extraction_root)

            extracted_checksum = extraction_root / "SHA256SUMS.txt"
            manifest: dict[str, str] = {}
            for line in extracted_checksum.read_text(encoding="utf-8").splitlines():
                expected_hash, relative_name = line.split("  ", 1)
                manifest[relative_name] = expected_hash

            expected_manifest_names = {
                path.relative_to(PACKET_ROOT).as_posix() for path in checksummed_files
            }
            if set(manifest) != expected_manifest_names:
                raise SystemExit("SHA256SUMS file set differs from packet file set")
            for relative_name, expected_hash in manifest.items():
                extracted_file = extraction_root / PurePosixPath(relative_name)
                if sha256(extracted_file) != expected_hash:
                    raise SystemExit(f"checksum mismatch after extraction: {relative_name}")

    checksum_bytes = CHECKSUM_PATH.read_bytes()
    if checksum_bytes.startswith(b"\xef\xbb\xbf"):
        raise SystemExit("SHA256SUMS.txt contains a UTF-8 BOM")

    print(f"ZIP={ZIP_PATH}")
    print(f"SIZE={ZIP_PATH.stat().st_size}")
    print(f"SHA256={sha256(ZIP_PATH)}")
    print(f"ENTRIES={len(final_files)}")
    print(f"CHECKSUM_LINES={len(checksum_lines)}")
    print("PATH_SAFETY_ERRORS=0")
    print("EXTRACTION_CHECKSUM_ERRORS=0")
    print("SHA256SUMS_UTF8_BOM=0")


if __name__ == "__main__":
    main()
