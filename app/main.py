import os
from datetime import datetime, timezone

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

app = FastAPI(title="Mission Status API", version="1.0.0")
templates = Jinja2Templates(directory="app/templates")

APP_NAME = os.getenv("APP_NAME", "Mission Status API")
APP_ENV = os.getenv("ENV", "unknown")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
CLOUD_PROVIDER = os.getenv("CLOUD_PROVIDER", "unknown")
CLOUD_REGION = os.getenv("CLOUD_REGION", "unknown")
CLUSTER_NAME = os.getenv("CLUSTER_NAME", "unknown")
DEPLOYED_AT = os.getenv(
    "DEPLOYED_AT",
    datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC"),
)


@app.get("/", response_class=HTMLResponse)
def root(request: Request):
    return templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "app_name": APP_NAME,
            "env": APP_ENV,
            "version": APP_VERSION,
            "cloud_provider": CLOUD_PROVIDER,
            "cloud_region": CLOUD_REGION,
            "cluster_name": CLUSTER_NAME,
            "deployed_at": DEPLOYED_AT,
        },
    )


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/status")
def status() -> dict:
    return {
        "service": "mission-status-api",
        "environment": APP_ENV,
        "status": "running",
        "cloud_provider": CLOUD_PROVIDER,
        "region": CLOUD_REGION,
        "cluster": CLUSTER_NAME,
        "version": APP_VERSION,
    }


@app.get("/version")
def version() -> dict:
    return {"version": APP_VERSION}
