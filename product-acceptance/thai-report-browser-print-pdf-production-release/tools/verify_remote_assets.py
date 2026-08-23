from __future__ import annotations

import argparse
import hashlib
import json
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    rows = []
    for line in args.manifest.read_text(encoding="utf-8").splitlines():
        expected_hash, expected_size, relative_path = line.split(maxsplit=2)
        url = args.base_url.rstrip("/") + "/" + urllib.parse.quote(
            relative_path, safe="/"
        )
        try:
            with urllib.request.urlopen(url, timeout=30) as response:
                payload = response.read()
                status = response.status
        except urllib.error.HTTPError as error:
            payload = error.read()
            status = error.code
        actual_hash = hashlib.sha256(payload).hexdigest().upper()
        rows.append(
            {
                "path": relative_path,
                "url": url,
                "status": status,
                "expectedBytes": int(expected_size),
                "actualBytes": len(payload),
                "expectedSha256": expected_hash,
                "actualSha256": actual_hash,
                "passed": status == 200
                and len(payload) == int(expected_size)
                and actual_hash == expected_hash,
            }
        )

    result = {
        "baseUrl": args.base_url,
        "entries": len(rows),
        "passed": sum(row["passed"] for row in rows),
        "missing": sum(row["status"] == 404 for row in rows),
        "mismatch": sum(row["status"] == 200 and not row["passed"] for row in rows),
        "httpFailures": sum(row["status"] != 200 for row in rows),
        "rows": rows,
    }
    args.output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(
        "REMOTE_ASSETS "
        f"entries={result['entries']} passed={result['passed']} "
        f"missing={result['missing']} mismatch={result['mismatch']} "
        f"httpFailures={result['httpFailures']}"
    )
    if result["passed"] != result["entries"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
