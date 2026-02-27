"""
Unit tests for the Neon Voyager API proxy.
App Check is disabled via APP_CHECK_ENABLED=false env var.
Upstream HTTP calls are mocked with respx.
"""

import os
os.environ["APP_CHECK_ENABLED"] = "false"
os.environ["TMDB_API_KEY"] = "test-tmdb-key"
os.environ["GEMINI_API_KEY"] = "test-gemini-key"
os.environ["OMDB_API_KEY"] = "test-omdb-key"

import pytest
import respx
import httpx
from fastapi.testclient import TestClient

# Import after env vars are set so module-level code picks them up
from main import app  # noqa: E402

client = TestClient(app)


# ---------------------------------------------------------------------------
# /health
# ---------------------------------------------------------------------------

def test_health_returns_ok():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_health_requires_no_app_check_token():
    """Health endpoint is always reachable — used as a liveness probe."""
    response = client.get("/health")
    assert response.status_code == 200


# ---------------------------------------------------------------------------
# /tmdb/* routing
# ---------------------------------------------------------------------------

@respx.mock
def test_tmdb_proxy_injects_api_key():
    respx.get("https://api.themoviedb.org/3/movie/popular").mock(
        return_value=httpx.Response(200, json={"results": []})
    )
    response = client.get("/tmdb/movie/popular")
    assert response.status_code == 200
    called_url = str(respx.calls[0].request.url)
    assert "api_key=test-tmdb-key" in called_url


@respx.mock
def test_tmdb_proxy_passes_query_params():
    respx.get("https://api.themoviedb.org/3/search/movie").mock(
        return_value=httpx.Response(200, json={"results": []})
    )
    response = client.get("/tmdb/search/movie?query=Inception&page=2")
    assert response.status_code == 200
    called_url = str(respx.calls[0].request.url)
    assert "query=Inception" in called_url
    assert "page=2" in called_url


@respx.mock
def test_tmdb_proxy_forwards_upstream_status():
    respx.get("https://api.themoviedb.org/3/movie/9999999").mock(
        return_value=httpx.Response(404, json={"status_message": "not found"})
    )
    response = client.get("/tmdb/movie/9999999")
    assert response.status_code == 404


# ---------------------------------------------------------------------------
# /gemini/* routing
# ---------------------------------------------------------------------------

@respx.mock
def test_gemini_proxy_injects_api_key():
    respx.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
    ).mock(return_value=httpx.Response(200, json={"candidates": []}))
    response = client.post(
        "/gemini/v1beta/models/gemini-pro:generateContent",
        json={"contents": []},
    )
    assert response.status_code == 200
    called_url = str(respx.calls[0].request.url)
    assert "key=test-gemini-key" in called_url


# ---------------------------------------------------------------------------
# /omdb routing
# ---------------------------------------------------------------------------

@respx.mock
def test_omdb_proxy_injects_api_key():
    respx.get("https://www.omdbapi.com").mock(
        return_value=httpx.Response(200, json={"Title": "Inception"})
    )
    response = client.get("/omdb?t=Inception")
    assert response.status_code == 200
    called_url = str(respx.calls[0].request.url)
    assert "apikey=test-omdb-key" in called_url
    assert "t=Inception" in called_url


# ---------------------------------------------------------------------------
# App Check enforcement (re-enable and test rejection)
# ---------------------------------------------------------------------------

def test_app_check_rejects_missing_token(monkeypatch):
    monkeypatch.setenv("APP_CHECK_ENABLED", "true")
    # Re-import to pick up changed env (or test the middleware directly)
    import main as proxy_main
    monkeypatch.setattr(proxy_main, "_APP_CHECK_ENABLED", True)
    response = client.get("/tmdb/movie/popular")
    assert response.status_code == 401
    assert "App Check" in response.json()["detail"]


# ---------------------------------------------------------------------------
# Missing API key → 503
# ---------------------------------------------------------------------------

def test_tmdb_503_when_key_missing(monkeypatch):
    monkeypatch.setattr("main.TMDB_API_KEY", "")
    response = client.get("/tmdb/movie/popular")
    assert response.status_code == 503


def test_gemini_503_when_key_missing(monkeypatch):
    monkeypatch.setattr("main.GEMINI_API_KEY", "")
    response = client.post("/gemini/v1beta/models/gemini-pro:generateContent", json={})
    assert response.status_code == 503


def test_omdb_503_when_key_missing(monkeypatch):
    monkeypatch.setattr("main.OMDB_API_KEY", "")
    response = client.get("/omdb?t=Test")
    assert response.status_code == 503
