from contextlib import asynccontextmanager
import json
import logging
import os
import re
import time

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app.routes.astrology import router as astrology_router
from app.routes.bazi import router as bazi_router
from app.services.firebase_admin_service import initialize_firebase_admin
from app.services.runtime_warmup import warm_firestore_connection

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger("knowme.api")

PRODUCTION_WEB_ORIGINS = [
    "https://knowme-app-694e1.web.app",
    "https://knowme-app-694e1.firebaseapp.com",
]

LOCAL_DEV_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8080",
    "http://127.0.0.1:8080",
]


@asynccontextmanager
async def lifespan(_app: FastAPI):
    """Initialize process-wide dependencies before accepting API requests."""
    initialize_firebase_admin()
    warm_firestore_connection(_firestore_client())
    yield


def _firestore_client():
    """Load the shared client at startup while keeping module imports offline-safe."""
    from app.services.firebase_service import db

    return db


app = FastAPI(
    title="KnowMe Astrology API",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[*PRODUCTION_WEB_ORIGINS, *LOCAL_DEV_ORIGINS],
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    completed = time.perf_counter()
    elapsed_ms = (completed - start) * 1000
    western_timing = getattr(request.state, "western_timing", None)
    if isinstance(western_timing, dict):
        handler_completed = western_timing.pop("_handler_completed", None)
        if isinstance(handler_completed, (int, float)):
            western_timing["response_serialization_ms"] = max(
                0.0,
                (completed - handler_completed) * 1000,
            )
        western_timing["total_ms"] = elapsed_ms
        logger.info(
            json.dumps(
                {
                    "event": "western_generation_timing",
                    "revision": os.environ.get("K_REVISION", "local"),
                    "trace_id": _trace_id(
                        request.headers.get("x-cloud-trace-context", "")
                    ),
                    "status": response.status_code,
                    "phases_ms": {
                        key: round(float(value), 3)
                        for key, value in western_timing.items()
                        if key.endswith("_ms")
                    },
                },
                sort_keys=True,
                separators=(",", ":"),
            )
        )
    logger.info(
        "%s %s -> %s (%.1fms)",
        request.method,
        request.url.path,
        response.status_code,
        elapsed_ms,
    )
    return response


def _trace_id(header: str) -> str | None:
    candidate = header.split("/", 1)[0].strip().lower()
    return candidate if re.fullmatch(r"[0-9a-f]{32}", candidate) else None


app.include_router(astrology_router)
app.include_router(bazi_router)


@app.get("/")
def root():
    return {"message": "KnowMe API running", "service": "astrology"}


@app.get("/health")
def health():
    return {"status": "ok", "service": "knowme-astrology-api"}
