# StreamScout 🚀

> Intelligent movie & series recommendation app — Flutter + GCP + Firebase

---

## Table of Contents

1. [Fresh machine setup](#1-fresh-machine-setup)
2. [Daily local development](#2-daily-local-development)
3. [GCP / infrastructure bootstrap](#3-gcp--infrastructure-bootstrap-one-time)
4. [After GCP is live — release builds](#4-after-gcp-is-live--release-builds)
5. [CI/CD pipeline](#5-cicd-pipeline)
6. [Running tests](#6-running-tests)
7. [Make commands](#7-make-commands)
8. [Architecture overview](#8-architecture-overview)

---

## 1. Fresh machine setup (One-time)

### 1a. Tools

```bash
# Flutter (use FVM or install directly)
# https://docs.flutter.dev/get-started/install/macos
flutter --version   # must be >= 3.x, Dart SDK >= 3.10

# GCP tools (needed for infra bootstrap — not for daily Flutter dev)
brew install terraform google-cloud-sdk

# Python (needed only to run the proxy locally)
brew install python@3.12
```

### 1b. Clone & get packages

```bash
git clone <repo-url>
cd imdb
flutter pub get

# Generate Freezed models and Riverpod providers (required on fresh clone)
make gen
```

### 1c. API keys — local `.env`

```bash
cp .env.example .env
# Edit .env and fill in your local keys:
#   TMDB_API_KEY=...   (https://www.themoviedb.org/settings/api)
#   GEMINI_API_KEY=... (https://aistudio.google.com/app/apikey)
#   OMDB_API_KEY=...   (https://www.omdbapi.com/apikey.aspx)
```

> **Note:** `.env` is gitignored and never committed. In production, keys live in GCP Secret Manager — the local proxy reads them from `.env` instead.

### 1d. Firebase Configuration files

Since Firebase configurations (`google-services.json` and `GoogleService-Info.plist`) are gitignored, you must download them from your Firebase Console for each build flavor, or retrieve them from a secure team vault. Ensure you place them in the correct directories for your flavor environments (e.g., `android/app/src/dev/` and `ios/Runner/`).

---

## 2. Daily local development

This app utilizes Build Flavors (`dev`, `staging`, `prod`) to manage different environments. All API calls go through a local Python proxy instead of hitting upstream APIs directly (mirrors how production works).

### Step 1 — Start the local proxy

```bash
cd infra/cloud-run/api-proxy
pip install -r requirements.txt -r requirements-dev.txt

# Load keys from the project root .env and start the proxy
APP_CHECK_ENABLED=false \
  TMDB_API_KEY=$(grep TMDB_API_KEY ../../.env | cut -d= -f2) \
  GEMINI_API_KEY=$(grep GEMINI_API_KEY ../../.env | cut -d= -f2) \
  OMDB_API_KEY=$(grep OMDB_API_KEY ../../.env | cut -d= -f2) \
  uvicorn main:app --port 8080 --reload
```

### Step 2 — Run the app (in another terminal)

Since Flavors are enforced, the app requires a defined flavor to run. The default in the Makefile is `dev`.

```bash
# The app auto-uses localhost:8080 when no PROXY_URL dart-define is set
# Using the make commands (recommended):
make run-ios                    # iOS Simulator (defaults to dev flavor)
make run-android                # Android Emulator (defaults to dev flavor)
FLAVOR=prod make run-ios        # Run with explicit flavor

# Or using flutter directly:
flutter run --flavor dev -d ios
flutter run --flavor dev -d android

# Other platforms
make run-macos      # macOS (with STT framework patch)
make run-web        # Chrome
```

> **Hot reload** works normally. The proxy gets `--reload` too, so Python changes are picked up automatically.

### Step 3 — Testing Policy

Before making any commits, ensure that `make test` runs successfully. Every feature that adds new code must include unit tests. Ensure you follow the workflow patterns defined in the `WORLD_CLASS_ANALYSIS.md`.

```bash
make test
make lint
```

---

## 3. GCP / Infrastructure bootstrap (one-time)

> **Do this once per environment.** After this, the CI/CD pipeline handles all deploys.

### 3a. Authenticate

```bash
gcloud auth login
gcloud auth application-default login
```

### 3b. Create the GCP project

```bash
gcloud projects create streamscout-dev --name="StreamScout Dev"
gcloud config set project streamscout-dev
```

> **Enable billing** in the console: [console.cloud.google.com/billing](https://console.cloud.google.com/billing)
> All services stay within free tier for < 10K MAU. First cost is ~$5–15/month at ~5–10K DAU.

### 3c. Create the Terraform state bucket

```bash
gsutil mb -l europe-west1 gs://streamscout-terraform-state
```

Then uncomment the `backend "gcs"` block in `infra/terraform/versions.tf`.

### 3d. Apply Terraform

```bash
cd infra/terraform/environments/dev
terraform init
terraform plan    # review what will be created
terraform apply   # creates all GCP resources
```

This creates all required GCP resources. Quick links to inspect them in your console:
- [Secret Manager](https://console.cloud.google.com/security/secret-manager?project=streamscout-dev) for API keys
- [Artifact Registry](https://console.cloud.google.com/artifacts?project=streamscout-dev) for Docker proxies
- [Cloud Run](https://console.cloud.google.com/run?project=streamscout-dev) for your deployed API proxy
- [Firebase Console](https://console.firebase.google.com/project/streamscout-dev/overview) (Auth, Crashlytics, etc.)
- [Firestore Database](https://console.firebase.google.com/project/streamscout-dev/firestore)
- [Cloud Build configuration](https://console.cloud.google.com/cloud-build/triggers?project=streamscout-dev)

### 3e. Load secrets into Secret Manager

```bash
echo -n "$(grep TMDB_API_KEY .env | cut -d= -f2)"   | gcloud secrets versions add tmdb-api-key   --data-file=-
echo -n "$(grep GEMINI_API_KEY .env | cut -d= -f2)"  | gcloud secrets versions add gemini-api-key  --data-file=-
echo -n "$(grep OMDB_API_KEY .env | cut -d= -f2)"    | gcloud secrets versions add omdb-api-key    --data-file=-
```

### 3f. Build & push the API proxy Docker image

```bash
cd infra/cloud-run/api-proxy
gcloud builds submit \
  --tag europe-west1-docker.pkg.dev/streamscout-dev/streamscout/api-proxy:latest
```

The `terraform apply` output prints the proxy URL — copy it for Step 3g.

### 3g. Get the proxy URL

```bash
cd infra/terraform/environments/dev
terraform output proxy_url
# → https://streamscout-api-proxy-dev-xxxx-ew.a.run.app
```

Release builds use this URL via `--dart-define`:

```bash
flutter build ios \
  --dart-define=PROXY_URL=https://streamscout-api-proxy-dev-xxxx-ew.a.run.app
```

---

## 4. After GCP is live — release builds

Release builds use the API proxy URL injected during the build, and they require specifying the chosen flavor.

```bash
# iOS 
flutter build ios --flavor prod --dart-define=PROXY_URL=<proxy_url>

# Android
flutter build appbundle --flavor prod --dart-define=PROXY_URL=<proxy_url>
```

The CI/CD pipeline (P1-5) injects `PROXY_URL` automatically — you don't need to set it manually once Cloud Build is configured.

---

## 5. CI/CD pipeline

> Set up by Terraform in P1-5. Until then, all of the above is manual.

On every push to `main`, Cloud Build runs:

```
lint → test (with coverage gate ≥70%) → build proxy Docker image
  → push to Artifact Registry → deploy Cloud Run → deploy Firestore rules
```

---

## 6. Running tests

```bash
# All tests (Flutter)
make test
# or
flutter test

# Proxy unit tests (Python)
cd infra/cloud-run/api-proxy
pytest test_main.py -v

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 7. Make commands

| Command | Description |
|---------|-------------|
| `make run-ios` | Run on iOS Simulator (Default flavor: dev. Override: `FLAVOR=prod make run-ios`) |
| `make run-android` | Run on Android Emulator (Default flavor: dev. Override: `FLAVOR=prod make run-android`) |
| `make run-macos` | Build + run on macOS (patches STT framework) |
| `make run-web` | Run in Chrome |
| `make run-device DEVICE=<id>` | Run on a specific device ID |
| `make test` | Run all Flutter tests |
| `make lint` | Run `flutter analyze` |
| `make gen` | Run `build_runner build` (code generation) |
| `make watch` | Run `build_runner watch` (continuous gen) |
| `make clean` | `flutter clean` + `flutter pub get` |

For wireless iOS deployment, see [IOS_WIRELESS_SETUP.md](IOS_WIRELESS_SETUP.md).

---

## 8. Architecture overview

```
Flutter app
    │
    │  All API calls (TMDB, Gemini, OMDb)
    ▼
Cloud Run proxy  ←── Secret Manager (API keys)
    │  /tmdb/*  →  api.themoviedb.org/3
    │  /gemini/* →  generativelanguage.googleapis.com
    │  /omdb/*  →  www.omdbapi.com
    │
    └── Firebase App Check validates every request
        (only the real app binary can call the proxy)

Local dev: proxy runs at localhost:8080 with APP_CHECK_ENABLED=false
           keys loaded from .env instead of Secret Manager
```

### Key decisions

| Concern | Choice | Why |
|---------|--------|-----|
| Secrets | GCP Secret Manager | Zero keys on device or in git |
| API security | App Check + Cloud Run proxy | Free, no per-user key management |
| Database | Firestore | Built-in offline sync, 50K reads/day free |
| State management | Riverpod | Already in use, best Flutter choice |
| Navigation | `go_router` (P1-8) | Deep links, typed routes |
| CI/CD | Cloud Build | Already in GCP, 120 free build-min/day |
| Region | europe-west1 (Frankfurt) | Lower cost, EU data residency (GDPR) |

See [WORLD_CLASS_ANALYSIS.md](WORLD_CLASS_ANALYSIS.md) for the full prioritised roadmap.
