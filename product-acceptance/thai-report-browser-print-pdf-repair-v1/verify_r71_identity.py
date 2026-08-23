from __future__ import annotations

import runpy
import sys
from pathlib import Path


PACKET = Path(__file__).resolve().parent
REPO = PACKET.parents[1]
SOURCE = (
    REPO
    / "product-acceptance"
    / "thai-narrative-v1.5-production-release-after-line-ending-repair"
    / "verify_r71_identity.py"
)
TARGET = PACKET / "logs" / "r7.1-identity-final.txt"
ORIGINAL_WRITE_TEXT = Path.write_text


def redirected_write_text(path: Path, data: str, *args, **kwargs) -> int:
    if path.name == "r71-accepted-archive-identity-result.txt":
        return ORIGINAL_WRITE_TEXT(TARGET, data, *args, **kwargs)
    return ORIGINAL_WRITE_TEXT(path, data, *args, **kwargs)


Path.write_text = redirected_write_text
sys.stdout.reconfigure(encoding="utf-8")
runpy.run_path(str(SOURCE))
