from fastapi import FastAPI
import os

app = FastAPI()


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/status")
def status():
    return {
        "service": "mission-status-api",
        "environment": os.getenv("ENV", "dev"),
        "status": "running",
    }


@app.get("/version")
def version():
    return {"version": os.getenv("APP_VERSION", "1.0.0")}
