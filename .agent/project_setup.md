---
description: StreamScout — New Project Bootstrap Reference
---

# 🚀 StreamScout — New Project Setup Guide

Copy this file to `.agent/rules.md` in any new blank project to immediately enforce World-Class standards.
For ongoing daily development, use the condensed `.agent/rules.md` instead.

---

## 1. Full Tech Stack

- **Framework:** Flutter (iOS, Android, macOS, Web).
- **Directory Structure:** Layer-First — `lib/config/`, `lib/data/`, `lib/domain/`, `lib/l10n/`, `lib/ui/`, `lib/utils/`.
- **State Management:** Riverpod (`flutter_riverpod`, `riverpod_annotation`). `AsyncNotifier` for async/pagination. Central barrel: `lib/config/providers.dart`.
- **Navigation:** `go_router`. `context.go()` / `context.push()`. Never raw `Navigator`.
- **Models:** `freezed` + `json_serializable`. Run `make gen` for all code generation.
- **Database:** Firestore (with native offline persistence). `Hive` only for local flags.
  - **macOS Hive lock files:** Lock files live in `~/Library/Containers/com.streamscout.app/Data/Documents/`. Stale locks crash with `FileSystemException: lock failed (errno = 35)`. `make run-macos` clears them automatically.
- **Secrets:** Zero on device. GCP Secret Manager → Cloud Run proxy only.
- **Services vs Repos:** HTTP logic → `lib/data/services/`. Business + Firestore → `lib/data/repositories/`.
- **File size:** Max 300 lines per file.

---

## 2. Environment & Build Flavors

- **Flavors:** `dev`, `staging`, `prod` via `flavorizr.yaml`.
- **Scaffolding:** `dart run flutter_flavorizr` — never manually edit native directories.
- **Commands:** `flutter run --flavor dev -d ios` or `make run-ios` (defaults to dev), `FLAVOR=prod make run-ios`.
- **Firebase:** Flavor-specific `google-services.json` and `GoogleService-Info.plist` per flavor.

---

## 3. GCP Infrastructure & Terraform (IaC)

All GCP resources managed via Terraform. Manual console changes are forbidden.

- **Modules:** `infra/terraform/modules/` covers Secret Manager, Artifact Registry, Cloud Run, Firebase, Firestore, Cloud Functions, Cloud Build, Cloud Scheduler.
- **Workflow:** `terraform plan` → `terraform apply`. Never apply without a plan review.
- **API Proxy:** External APIs MUST route through the Cloud Run `api-proxy`. It holds secrets and authenticates with Firebase App Check.
- **Cost:** `min_instance_count = 0` on Cloud Run. Cloud Functions (2nd gen) for event-driven triggers.

---

## 4. Core Feature Implementation Rules

- **Offline-First:** Rely on Firestore cache. No custom SQLite/Hive sync layers. Show offline banner via `connectivity_plus`.
- **Auth:** Firebase Auth (Identity Platform). Multi-Profile: isolate data per profile ID, not just Firebase UID.
- **Push Notifications:** FCM. Trigger logic via Cloud Functions or Cloud Scheduler — not client-side.
- **Observability:** Crashlytics on `FlutterError.onError` + `PlatformDispatcher.instance.onError`. Firebase Analytics for screen and funnel events.
- **Feature Flags:** Gate new features behind Firebase Remote Config. No dark code in production.
- **AI Features:** `google_generative_ai` SDK routed through the Cloud Run proxy.
- **Voice:** `speech_to_text`. Patch STT permissions frame via `make run-macos` when targeting macOS.
- **Home Screen Widgets:** `home_widget` → Apple WidgetKit (iOS) + Glance (Android).
- **Social/Sharing:** Sub-collections or linking documents in Firestore for secure granular Security Rules.

---

## 5. Testing Policy

Every feature and bugfix MUST include tests. CI enforces 70% coverage minimum.

- Models, Repos/Services, Providers, Widget/Screen tests, Golden tests (`golden_toolkit`), E2E (`integration_test` on Firebase Test Lab).
- Use `fake_cloud_firestore` for Firestore mocks and `mocktail` for Dio.
- Follow TDD via `.agent/workflows/tdd.md`.

---

## 6. UI & UX Standards

- **Theme:** Light / Dark / System. Persist in `Hive`.
- **i18n:** `intl` + `.arb` files. No hardcoded strings.
- **Accessibility:** `Semantics` on interactive widgets. WCAG AA contrast. Dynamic text scaling.
- **Animations:** `Hero`, skeleton shimmer, platform-adaptive transitions, `lottie`/`rive` for state animations, `fl_chart` for data viz.
- **Splash/Icons:** `flutter_native_splash` + `flutter_launcher_icons`.
- **Gestures:** `flutter_slidable` for swipe actions. Haptic feedback (light/medium/heavy) on appropriate interactions.
- **Layouts:** Tablet breakpoints in `AppTheme`.

---

## 7. AI Agent Workflow

1. Analyze architectural consistency before changing code.
2. Use `freezed` for models, never bypass the proxy, never hardcode secrets.
3. `make gen` for code generation, `make test` for validation.
4. After every code change: run `make run-macos` to verify.
5. Output `_test.dart` alongside every new widget or service.
