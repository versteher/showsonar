---
description: "{{APP_NAME}} — New Project Bootstrap Reference"
---

# {{APP_NAME}} — New Project Setup Guide

Drop this file into `.agent/project_setup.md` in any new blank Flutter project to enforce production-grade standards from day one. For ongoing daily development, use `.agent/rules.md` instead.

---

## 1. Full Tech Stack

| Category | Package | Purpose |
|----------|---------|---------|
| **Framework** | Flutter 3.x | Cross-platform: iOS, Android, macOS, Web |
| **State** | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` | Compile-safe, testable state management |
| **Navigation** | `go_router` | Declarative routing, deep links, platform-adaptive transitions |
| **Models** | `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation` | Immutable data classes with JSON serialization |
| **Code gen** | `build_runner` | Dev-time code generation for providers, models |
| **Database (cloud)** | `cloud_firestore` | Real-time sync with built-in offline persistence |
| **Database (local)** | `shared_preferences` | Device-local flags: theme, onboarding, viewing context |
| **Auth** | `firebase_auth`, `google_sign_in`, `sign_in_with_apple` | Firebase Authentication (Identity Platform) |
| **HTTP** | `dio`, `dio_cache_interceptor`, `dio_cache_interceptor_hive_store` | HTTP client with response caching and offline fallback |
| **Analytics** | `firebase_analytics`, `firebase_crashlytics` | Observability: screen tracking, crash reporting |
| **Remote Config** | `firebase_remote_config` | Feature flags (no dark code in production) |
| **Push** | `firebase_messaging` | FCM push notifications |
| **Connectivity** | `connectivity_plus` | Offline banner detection |
| **Testing** | `mocktail`, `fake_cloud_firestore`, `golden_toolkit`, `integration_test`, `network_image_mock` | Full test pyramid |
| **UI** | `flutter_animate`, `google_fonts`, `shimmer`, `cached_network_image`, `lottie` | Polished animations and image loading |
| **Haptics** | `flutter/services.dart` (HapticFeedback) | Centralized via `AppHaptics` utility |
| **Splash/Icons** | `flutter_native_splash`, `flutter_launcher_icons` | Native splash screen + app icons |
| **Gestures** | `flutter_slidable` | Swipe actions on list items |
| **Charts** | `fl_chart` | Data visualization |
| **AI** | `google_generative_ai` | Gemini SDK (always routed through api-proxy) |
| **Voice** | `speech_to_text` | Voice search input |
| **Home Widgets** | `home_widget` | iOS WidgetKit + Android Glance |
| **Environment** | `flutter_dotenv` | Local `.env` loading for dev |
| **Flavors** | `flutter_flavorizr` | Build flavor scaffolding (dev/staging/prod) |
| **E2E** | `patrol` | Advanced E2E testing |

---

## 2. Directory Structure

```
{{PACKAGE_NAME}}/
├── .agent/
│   ├── rules.md                        # Daily development rules (this project's companion)
│   ├── project_setup.md                # This file
│   └── workflows/
│       └── tdd.md                      # TDD Red-Green-Refactor workflow
├── .devcontainer/
│   ├── Dockerfile                      # Flutter + Terraform + gcloud + Python 3.12
│   └── devcontainer.json               # VS Code extensions, post-create: flutter pub get && make gen
├── .vscode/
│   ├── launch.json                     # Debug configs for macOS, Chrome, iOS, Android
│   └── settings.json                   # Editor settings (formatOnSave, etc.)
├── infra/
│   ├── cloud-run/
│   │   └── api-proxy/
│   │       ├── main.py                 # FastAPI proxy (Python 3.12-slim)
│   │       ├── Dockerfile              # Cloud Run container
│   │       ├── requirements.txt        # uvicorn, fastapi, httpx, firebase-admin
│   │       ├── requirements-dev.txt    # pytest, pytest-asyncio, respx
│   │       └── .venv/                  # Local Python venv (.gitignored)
│   ├── terraform/
│   │   ├── versions.tf                 # Terraform >=1.7, google/google-beta ~5.20
│   │   ├── providers.tf                # Google + Google-Beta providers
│   │   ├── variables.tf                # project_id, region, environment
│   │   ├── apis.tf                     # Enables all required GCP APIs
│   │   ├── modules/
│   │   │   ├── secrets/                # GCP Secret Manager
│   │   │   ├── ci-cd/                  # Artifact Registry + Cloud Build trigger
│   │   │   ├── api-proxy/              # Cloud Run service + service account
│   │   │   ├── firebase/               # Firebase project setup
│   │   │   ├── firebase-auth/          # Identity Platform config
│   │   │   ├── firestore/              # Database + Security Rules
│   │   │   ├── cloud-functions/        # 2nd gen event-driven functions
│   │   │   └── scheduler/              # Cloud Scheduler jobs
│   │   └── environments/
│   │       ├── dev/                    # terraform.tfvars for dev
│   │       ├── staging/                # terraform.tfvars for staging
│   │       └── prod/                   # terraform.tfvars for prod
│   └── firestore-rules-tests/
│       ├── package.json                # @firebase/rules-unit-testing, mocha
│       └── test/                       # Security Rules tests
├── lib/
│   ├── config/
│   │   ├── providers.dart              # Barrel: exports all sub-providers
│   │   ├── providers/                  # Split provider files with .g.dart counterparts
│   │   ├── router.dart                 # go_router with platform-adaptive transitions
│   │   └── firebase_fallback.dart      # Firestore instance (prod vs fake for tests)
│   ├── data/
│   │   ├── models/                     # Freezed data classes (.freezed.dart, .g.dart)
│   │   ├── services/                   # HTTP clients (Dio-based, talk to api-proxy)
│   │   └── repositories/              # Business logic, Firestore CRUD, caching
│   ├── domain/                         # Pure business rules, engines, enums
│   ├── l10n/
│   │   ├── app_localizations.dart      # Abstract interface (hand-maintained)
│   │   ├── app_localizations_en.dart   # English implementation
│   │   ├── app_localizations_<locale>.dart # Additional locale(s)
│   │   └── arb/                        # ARB source files
│   ├── ui/
│   │   ├── screens/                    # Screen widgets (max 300 lines each)
│   │   ├── widgets/                    # Composable reusable widgets
│   │   └── theme/
│   │       └── app_theme.dart          # Colors, typography, spacing, breakpoints
│   └── utils/                          # Pure helpers: haptics, filters, analytics, crashlytics
├── test/
│   ├── data/                           # Model, service, repository tests
│   ├── config/                         # Provider tests
│   ├── ui/                             # Widget and screen tests
│   └── utils/
│       ├── test_app_wrapper.dart       # pumpAppScreen helper
│       └── test_provider_container.dart # MockDependencies helper
├── scripts/
│   ├── set_ci_version.sh               # Updates pubspec build number from git commit count
│   └── run_firebase_test_lab.sh        # E2E tests on Firebase Test Lab
├── Makefile                            # All dev commands (see Section 8)
├── pubspec.yaml
├── analysis_options.yaml               # flutter_lints defaults
├── cloudbuild.yaml                     # CI/CD pipeline
├── firebase.json                       # Firebase project config
├── firestore.rules                     # Firestore Security Rules
└── .env.example                        # Template for local API keys
```

---

## 3. Environment & Build Flavors

- **Flavors:** `dev`, `staging`, `prod` via `flutter_flavorizr`.
- **Scaffolding:** `dart run flutter_flavorizr` — never manually edit native directories.
- **Commands:** `flutter run --flavor dev -d ios` or `make run-ios` (defaults to dev). Override: `FLAVOR=prod make run-ios`.
- **Dart defines:** `--dart-define=appFlavor=$(FLAVOR)` passed by Makefile targets.
- **Firebase:** Flavor-specific `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) per flavor.
- **Version management:** Use git commit count as build number:
  ```bash
  # scripts/set_ci_version.sh
  BUILD_NUMBER=$(git rev-list HEAD --count)
  # Updates pubspec.yaml: X.Y.Z+${BUILD_NUMBER}
  ```
- **Local secrets:** `.env` file (gitignored) with API keys for local dev. In production, keys are in GCP Secret Manager.

---

## 4. GCP Infrastructure & Terraform (IaC)

All GCP resources managed via Terraform. Manual console changes are **forbidden**.

**Terraform modules** (`infra/terraform/modules/`):

| Module | Purpose |
|--------|---------|
| `secrets/` | GCP Secret Manager for API keys (TMDB, Gemini, OMDB, etc.) |
| `ci-cd/` | Artifact Registry for Docker images + Cloud Build trigger on `main` |
| `api-proxy/` | Cloud Run service with `min_instance_count = 0` (scale-to-zero) |
| `firebase/` | Firebase project setup |
| `firebase-auth/` | Identity Platform configuration |
| `firestore/` | Database instance + Security Rules deployment |
| `cloud-functions/` | 2nd gen Cloud Functions for event-driven triggers |
| `scheduler/` | Cloud Scheduler for recurring jobs |

**Workflow:** `terraform plan` → review → `terraform apply`. Never apply without a plan review.

**API Proxy pattern:**
```python
# infra/cloud-run/api-proxy/main.py — FastAPI + uvicorn
# - Secrets injected via Secret Manager env vars (TMDB_API_KEY, GEMINI_API_KEY, etc.)
# - Validates Firebase App Check tokens in production (APP_CHECK_ENABLED=true)
# - Routes: /tmdb/*, /gemini/*, /omdb/*, etc.
# - APP_CHECK_ENABLED=false for local development
```

**Cost optimization:**
- Cloud Run: `min_instance_count = 0` — $0 when idle (auto scale-to-zero).
- Firestore: built-in offline persistence — no custom sync layer needed.
- Estimated cost for <10K MAU: **$0** (within GCP free tier).

---

## 5. DevContainer Configuration

**`.devcontainer/devcontainer.json`:**
```json
{
  "name": "{{APP_NAME}} Flutter Dev",
  "build": { "dockerfile": "Dockerfile", "context": ".." },
  "customizations": {
    "vscode": {
      "extensions": [
        "Dart-Code.flutter",
        "Dart-Code.dart-code",
        "anthropic.claude-code"
      ],
      "settings": {
        "dart.flutterSdkPath": "/sdks/flutter",
        "editor.formatOnSave": true
      }
    }
  },
  "postCreateCommand": "flutter pub get && make gen",
  "remoteUser": "root"
}
```

**`.devcontainer/Dockerfile`** — installs on top of `ghcr.io/cirruslabs/flutter:stable`:
- Python 3.12, pip, venv (for API proxy local dev)
- Terraform (via HashiCorp apt repo)
- Google Cloud SDK
- curl, gnupg, make, git

---

## 6. CI/CD Pipeline

**`cloudbuild.yaml`** — triggered on push to `main`:

| Step | Command | Purpose |
|------|---------|---------|
| 1 | `flutter pub get` | Install dependencies |
| 2 | `scripts/set_ci_version.sh` | Set build number from git commit count |
| 3 | `flutter analyze` | Lint / static analysis |
| 4 | `flutter test --coverage` | Unit + widget tests |
| 5 | `flutter test --tags=golden` | Golden snapshot tests |
| 6 | Parse `lcov.info` | **Fail if coverage < 70%** |
| 7 | `docker build` api-proxy | Build API proxy Docker image |
| 8 | `docker push` | Push to Artifact Registry |
| 9 | `gcloud run deploy` | Deploy Cloud Run service |
| 10 | `firebase deploy --only firestore:rules` | Deploy Security Rules |

**Firestore Rules tests:** Separate Mocha test suite in `infra/firestore-rules-tests/`. Run with `npm test`.

**E2E on Firebase Test Lab:** `scripts/run_firebase_test_lab.sh` builds APKs and runs instrumentation tests.

---

## 7. Core Feature Implementation Rules

### 7.1 Offline-First
- Rely on Firestore's built-in offline cache. **No custom SQLite/Hive sync layers.**
- Show offline banner via `connectivity_plus`.
- Dio cache interceptor config:
  ```dart
  CacheOptions(
    store: kIsWeb ? MemCacheStore() : HiveCacheStore('$appDir/api_cache'),
    policy: CachePolicy.refreshForceCache,  // network first, fallback to cache
    maxStale: const Duration(days: 30),
    hitCacheOnErrorExcept: [401, 403],       // serve stale on error, but not on auth failures
  )
  ```

### 7.2 Authentication
- Firebase Auth (Identity Platform). Support Google Sign-In + Apple Sign-In.
- Multi-Profile: isolate user data per profile ID sub-path in Firestore, not just Firebase UID.
- Repository constructors take `userId` parameter for Firestore path scoping.

### 7.3 Push Notifications
- FCM for delivery. Trigger logic in **Cloud Functions or Cloud Scheduler** — never client-side.
- Notification service in `lib/utils/notification_service.dart`.

### 7.4 Observability
- **Crashlytics:** `FlutterError.onError` + `PlatformDispatcher.instance.onError`.
- **Analytics:** Screen tracking + funnel events via centralized `AnalyticsService` in `lib/utils/`.
- Never call Firebase directly from UI code — always through utility wrappers.

### 7.5 Feature Flags
- Firebase Remote Config. Gate new features behind flags.
- No dark code in production — unreleased features must be behind a flag.
- Provider: `remoteConfigServiceProvider` with getters like `enableSocial`, `enableWidgets`.

### 7.6 AI Features
- `google_generative_ai` SDK routed through the Cloud Run proxy (never direct from client).
- `GeminiService` in `lib/data/services/`.
- Chat history: `StateNotifierProvider<ChatHistoryNotifier, List<ChatMessage>>` (no `@riverpod` needed for simple state).

### 7.7 Voice
- `speech_to_text` package.
- macOS requires STT framework plist patching + re-signing: `make patch-stt-framework`.

### 7.8 Home Screen Widgets
- `home_widget` package → iOS WidgetKit + Android Glance.
- Helper in `lib/utils/home_widget_helper.dart`.

### 7.9 Social / Sharing
- Firestore sub-collections for shared data (e.g., shared watchlists, friend recommendations).
- Granular Security Rules per sub-collection — never expose full user data.

---

## 8. Makefile Reference

```makefile
.PHONY: run-macos run-web run-ios run-android gen watch clean test lint help

FLAVOR ?= dev

help:
	@echo "Available commands:"
	@echo "  make run-web      - Run on web (port 3000) with API proxy (port 8080)"
	@echo "  make run-macos    - Run on macOS with API proxy"
	@echo "  make run-ios      - Run on iOS (FLAVOR=prod for production)"
	@echo "  make run-android  - Run on Android (FLAVOR=prod for production)"
	@echo "  make run-device   - Run on specific device (DEVICE=<id>)"
	@echo "  make gen          - Run build_runner build"
	@echo "  make watch        - Run build_runner watch"
	@echo "  make clean        - Clean + pub get"
	@echo "  make test         - Run all tests"
	@echo "  make lint         - Run analyzer"

run-web:
	@lsof -ti :8080 | xargs kill -9 2>/dev/null || true
	@lsof -ti :3000 | xargs kill -9 2>/dev/null || true
	@cd infra/cloud-run/api-proxy && \
		source .venv/bin/activate && \
		export $$(grep -v '^#' ../../../.env | xargs) && \
		APP_CHECK_ENABLED=false uvicorn main:app --port 8080 & \
		PROXY_PID=$$!; \
		flutter run -d web-server --web-port=3000 --web-hostname=localhost \
			--dart-define=appFlavor=$(FLAVOR); \
		kill $$PROXY_PID

run-macos:
	@lsof -ti :8080 | xargs kill -9 2>/dev/null || true
	@cd infra/cloud-run/api-proxy && \
		source .venv/bin/activate && \
		export $$(grep -v '^#' ../../../.env | xargs) && \
		APP_CHECK_ENABLED=false uvicorn main:app --port 8080 & \
		PROXY_PID=$$!; \
		flutter run --dart-define=appFlavor=$(FLAVOR) -d macos; \
		kill $$PROXY_PID

run-ios:
	flutter run --flavor $(FLAVOR) -d ios

run-android:
	flutter run --flavor $(FLAVOR) -d android

run-device:
	flutter run -d $(DEVICE)

gen:
	flutter pub run build_runner build --delete-conflicting-outputs

watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

clean:
	flutter clean
	flutter pub get

test:
	flutter test

lint:
	flutter analyze
```

---

## 9. Testing Infrastructure Bootstrap

When starting a new project, create these two test utility files immediately:

**`test/utils/test_app_wrapper.dart`** — widget test helper:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:{{PACKAGE_NAME}}/l10n/app_localizations.dart';

/// Wraps a widget in ProviderScope + MaterialApp with l10n for testing.
Widget pumpAppScreen({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}
```

**`test/utils/test_provider_container.dart`** — mock dependencies:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
// Import all service/repo classes and their providers

class MockAuthService extends Mock implements AuthService {}
class MockApiClient extends Mock implements ApiClient {}
// ... declare a Mock class for each service and repository

/// Holds all mocked dependencies with sensible defaults.
class MockDependencies {
  final authService = MockAuthService();
  final apiClient = MockApiClient();
  // ... one field per mock

  MockDependencies() {
    // Setup defaults for init() calls and commonly-used getters
    when(() => someRepo.init()).thenAnswer((_) async {});
    when(() => localPrefs.viewingContextIndex).thenReturn(0);
    when(() => remoteConfig.enableSocial).thenReturn(false);
  }

  /// Creates a ProviderContainer with all base dependencies overridden.
  ProviderContainer createContainer({List<Override> overrides = const []}) {
    return ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        apiClientProvider.overrideWithValue(apiClient),
        // ... override every service/repo provider
        ...overrides, // allow test-specific overrides on top
      ],
    );
  }
}
```

**Fake pattern for complex methods** (avoids mocktail matcher issues with many named params):
```dart
class FakeMyRepository extends Fake implements IMyRepository {
  final List<MyModel> Function()? _result;

  FakeMyRepository({List<MyModel> Function()? result}) : _result = result;

  @override
  Future<List<MyModel>> discover({
    List<int>? genreIds,
    double? minRating,
    int? maxAgeRating,
    int page = 1,
    // ... many params
  }) async => (_result ?? () => [])();
}
```

---

## 10. Template Variables

When forking this template, change only these values:

| Variable | Where | Example |
|----------|-------|---------|
| `{{APP_NAME}}` | Display name, `.agent/` headers, DevContainer | `ShowSonar` |
| `{{PACKAGE_NAME}}` | `pubspec.yaml` name, Dart imports | `stream_scout` |
| `{{GCP_PROJECT_ID}}` | `terraform.tfvars`, Firebase config | `showsonar-dev` |
| `{{GCP_REGION}}` | Cloud Run, Artifact Registry | `europe-west1` |
| `{{FIREBASE_PROJECT}}` | `firebase.json`, flavor configs | `showsonar-dev` |
| `{{API_PROXY_ROUTES}}` | `main.py` route prefixes | `/tmdb/*`, `/gemini/*` |
| `{{TERRAFORM_STATE_BUCKET}}` | `versions.tf` backend block | `gs://{{PACKAGE_NAME}}-terraform-state` |
| `{{BUNDLE_ID}}` | iOS/Android bundle identifier | `com.showsonar.app` |
| `{{PRIMARY_COLOR}}` | `AppTheme.primary` hex value | `0xFF6366F1` |
| `{{SUPPORTED_LOCALES}}` | l10n files + MaterialApp config | `en`, `de` |

Everything else (layer structure, test setup, provider patterns, CI/CD pipeline, Terraform modules) is project-agnostic and ready to reuse.

---

## 11. Agent Workflow

1. **Analyze** architectural consistency before changing code.
2. **No shortcuts:** Use `freezed` for models. Never bypass the proxy. Never hardcode secrets.
3. **`make gen`** for code generation, **`make test`** for validation.
4. **Verify after logical units:** After completing a feature, bug fix, or TDD cycle, run `make run-web` and verify at `http://localhost:3000`. See `.agent/rules.md` for the full kill-start-verify workflow.
5. **TDD:** Output `_test.dart` alongside every new widget or service. Follow `.agent/workflows/tdd.md`.
