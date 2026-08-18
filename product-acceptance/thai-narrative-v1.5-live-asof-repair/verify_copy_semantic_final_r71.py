from __future__ import annotations

import runpy
from pathlib import Path


ORIGINAL_WRITE_TEXT = Path.write_text


def redirected_write_text(path: Path, data: str, *args, **kwargs) -> int:
    if path.name == "s008-final-r71-identity-archive-result.txt":
        path = path.with_name("copy-semantic-final-r71-identity-result.txt")
    return ORIGINAL_WRITE_TEXT(path, data, *args, **kwargs)


Path.write_text = redirected_write_text
runpy.run_path(str(Path(__file__).with_name("verify_s008_r71_identity.py")))
