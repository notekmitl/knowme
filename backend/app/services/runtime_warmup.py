"""Runtime dependency warm-up that must finish before Cloud Run serves traffic."""

import json
import logging
import os
import time

logger = logging.getLogger("knowme.runtime")


def warm_firestore_connection(db) -> float:
    """Open the shared Firestore channel with a read-only, non-user probe."""
    started = time.perf_counter()
    try:
        db.collection("runtime_health").document("firestore_warmup").get()
    except Exception:
        elapsed_ms = (time.perf_counter() - started) * 1000
        logger.exception(
            json.dumps(
                {
                    "event": "firestore_startup_warmup",
                    "revision": os.environ.get("K_REVISION", "local"),
                    "status": "failed",
                    "duration_ms": round(elapsed_ms, 3),
                },
                sort_keys=True,
                separators=(",", ":"),
            )
        )
        raise

    elapsed_ms = (time.perf_counter() - started) * 1000
    logger.info(
        json.dumps(
            {
                "event": "firestore_startup_warmup",
                "revision": os.environ.get("K_REVISION", "local"),
                "status": "ready",
                "duration_ms": round(elapsed_ms, 3),
            },
            sort_keys=True,
            separators=(",", ":"),
        )
    )
    return elapsed_ms
