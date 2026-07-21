import logging
import time

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app.routes.astrology import router as astrology_router
from app.routes.bazi import router as bazi_router

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

app = FastAPI(title="KnowMe Astrology API", version="1.0.0")

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
    elapsed_ms = (time.perf_counter() - start) * 1000
    logger.info(
        "%s %s -> %s (%.1fms)",
        request.method,
        request.url.path,
        response.status_code,
        elapsed_ms,
    )
    return response


app.include_router(astrology_router)
app.include_router(bazi_router)


@app.get("/")
def root():
    return {"message": "KnowMe API running", "service": "astrology"}


@app.get("/health")
def health():
    return {"status": "ok", "service": "knowme-astrology-api"}
