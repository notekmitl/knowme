from fastapi import FastAPI
from app.routes.astrology import router as astrology_router

app = FastAPI()

app.include_router(astrology_router)


@app.get("/")
def root():
    return {
        "message": "KnowMe Astrology Backend Running"
    }