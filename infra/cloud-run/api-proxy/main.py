"""
Neon Voyager API Proxy
======================
Runs on Cloud Run (scale-to-zero). Forwards requests to TMDB, Gemini, and OMDb,
injecting API keys from environment variables (mounted from Secret Manager).

Firebase App Check token is validated on every non-health endpoint.
"""

import os
import logging
from typing import Optional

import httpx
from fastapi import FastAPI, Request, Response, HTTPException
from fastapi.responses import JSONResponse
import firebase_admin
from firebase_admin import app_check, credentials

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Firebase App Check initialisation
# ---------------------------------------------------------------------------
# In Cloud Run, GOOGLE_APPLICATION_CREDENTIALS is set automatically.
# Skip App Check validation when running in test mode.
_APP_CHECK_ENABLED = os.getenv("APP_CHECK_ENABLED", "true").lower() == "true"

if _APP_CHECK_ENABLED:
    try:
        firebase_admin.initialize_app(credentials.ApplicationDefault())
        logger.info("Firebase Admin SDK initialised")
    except Exception as exc:  # pragma: no cover
        logger.warning("Firebase Admin SDK init failed (will skip App Check): %s", exc)
        _APP_CHECK_ENABLED = False

# ---------------------------------------------------------------------------
# API keys (injected from Secret Manager via Cloud Run env vars)
# ---------------------------------------------------------------------------
TMDB_API_KEY = os.getenv("TMDB_API_KEY", "")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
OMDB_API_KEY = os.getenv("OMDB_API_KEY", "")

# Upstream base URLs
TMDB_BASE = "https://api.themoviedb.org/3"
GEMINI_BASE = "https://generativelanguage.googleapis.com"
OMDB_BASE = "https://www.omdbapi.com"

# ---------------------------------------------------------------------------
# App
# ---------------------------------------------------------------------------
app = FastAPI(title="Neon Voyager API Proxy", docs_url=None, redoc_url=None)

# ---------------------------------------------------------------------------
# CORS — allow the Flutter web app (localhost:3000) to call the proxy
# ---------------------------------------------------------------------------
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# App Check middleware
# ---------------------------------------------------------------------------
async def _verify_app_check(request: Request) -> None:
    """Raise 401 if App Check token is missing or invalid."""
    if not _APP_CHECK_ENABLED:
        return
    token = request.headers.get("X-Firebase-AppCheck")
    if not token:
        raise HTTPException(status_code=401, detail="Missing App Check token")
    try:
        app_check.verify_token(token)
    except Exception as exc:
        logger.warning("App Check verification failed: %s", exc)
        raise HTTPException(status_code=401, detail="Invalid App Check token") from exc


# ---------------------------------------------------------------------------
# Helper: forward request to upstream, stripping proxy-specific headers
# ---------------------------------------------------------------------------
_HOP_BY_HOP = {
    "host", "content-length", "transfer-encoding", "connection",
    "x-firebase-appcheck",
    # Strip encoding headers: the proxy fully buffers the body, so
    # chunked/gzip encoding no longer applies and confuses Dio on macOS.
    "content-encoding",
}

async def _proxy(
    request: Request,
    upstream_url: str,
    extra_params: Optional[dict] = None,
) -> Response:
    params = dict(request.query_params)
    if extra_params:
        params.update(extra_params)

    headers = {
        k: v for k, v in request.headers.items()
        if k.lower() not in _HOP_BY_HOP
    }

    body = await request.body()

    async with httpx.AsyncClient(timeout=30.0) as client:
        upstream = await client.request(
            method=request.method,
            url=upstream_url,
            params=params,
            headers=headers,
            content=body,
        )

    # Strip hop-by-hop / encoding headers from the upstream response.
    # httpx transparently decompresses gzip, but the original
    # content-encoding header is still present.  If we forward it,
    # Dio on the client side will try to decompress already-plain JSON,
    # causing  "FormatException: Filter error, bad data".
    _STRIP_RESPONSE_HEADERS = {
        "content-encoding", "transfer-encoding", "content-length",
    }
    resp_headers = {
        k: v for k, v in upstream.headers.items()
        if k.lower() not in _STRIP_RESPONSE_HEADERS
    }

    return Response(
        content=upstream.content,
        status_code=upstream.status_code,
        headers=resp_headers,
        media_type=upstream.headers.get("content-type"),
    )


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.get("/health")
async def health() -> JSONResponse:
    """Liveness probe — no App Check required."""
    return JSONResponse({"status": "ok"})


@app.api_route("/tmdb/{path:path}", methods=["GET", "POST", "DELETE"])
async def tmdb_proxy(path: str, request: Request) -> Response:
    """Forward to TMDB v3 API with injected bearer token."""
    await _verify_app_check(request)
    if not TMDB_API_KEY:
        raise HTTPException(status_code=503, detail="TMDB_API_KEY not configured")
    upstream_url = f"{TMDB_BASE}/{path}"
    return await _proxy(
        request,
        upstream_url,
        extra_params={"api_key": TMDB_API_KEY},
    )


@app.api_route("/gemini/{path:path}", methods=["GET", "POST"])
async def gemini_proxy(path: str, request: Request) -> Response:
    """Forward to Gemini API with injected API key."""
    await _verify_app_check(request)
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=503, detail="GEMINI_API_KEY not configured")
    upstream_url = f"{GEMINI_BASE}/{path}"
    return await _proxy(
        request,
        upstream_url,
        extra_params={"key": GEMINI_API_KEY},
    )


@app.api_route("/omdb/{path:path}", methods=["GET"])
@app.get("/omdb")
async def omdb_proxy(request: Request, path: str = "") -> Response:
    """Forward to OMDb API with injected API key."""
    await _verify_app_check(request)
    if not OMDB_API_KEY:
        raise HTTPException(status_code=503, detail="OMDB_API_KEY not configured")
    upstream_url = OMDB_BASE if not path else f"{OMDB_BASE}/{path}"
    return await _proxy(
        request,
        upstream_url,
        extra_params={"apikey": OMDB_API_KEY},
    )
