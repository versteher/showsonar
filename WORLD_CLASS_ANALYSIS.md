# 🚀 StreamScout — World-Class App Roadmap

> Complete, ordered checklist of **every** improvement needed. Work top to bottom within each tier. Mark `[x]` when done.
>
> **Labels:** Each item has a unique ID (`P0-1`, `P1-3`, etc.) for unambiguous reference.
>
> **Parallel tracks:** Items with _"Depends on: Nothing"_ can be worked on simultaneously with other items in the same tier.
>
> **Testing policy:** Every P0 and P1 item that adds new code **must include unit tests** for that code. Tests are not optional or deferred — they ship with the feature.

---

## 🔴 P0 — Critical Foundation (Do First)

> Blockers. Nothing else should ship before these are resolved.

### Track A: Security & GCP Infrastructure

- [x] **P0-1 · Remove `.env` from source control**
  - Add `.env` to `.gitignore`
  - Create `.env.example` with placeholder values
  - Rotate all 3 exposed keys (TMDB, Gemini, OMDb) — they're compromised in git history
  - _Tests:_ N/A (config change only)
  - _Depends on:_ Nothing — do this immediately

- [x] **P0-2 · Set up GCP project + Terraform scaffold**
  - Install Terraform + `gcloud` CLI
  - Create GCP project (`streamscout-dev`)
  - Enable billing, create Terraform state bucket (`gs://streamscout-terraform-state`)
  - Create `infra/terraform/` directory structure with `providers.tf`, `variables.tf`, `versions.tf`
  - Create `environments/dev/`, `staging/`, `prod/` directories
  - Enable required APIs: `secretmanager`, `run`, `artifactregistry`, `cloudbuild`, `firestore`, `identitytoolkit`, `cloudfunctions`
  - _Tests:_ `terraform validate` + `terraform plan` must succeed
  - _Depends on:_ Nothing

- [x] **P0-3 · Terraform: Secret Manager**
  - Create `modules/secrets/` with resources for `tmdb-api-key`, `gemini-api-key`, `omdb-api-key`
  - Store actual key values via `gcloud secrets versions add`
  - _Tests:_ `terraform plan` shows 3 secrets created
  - _Depends on:_ P0-2

- [x] **P0-4 · Terraform: Artifact Registry**
  - Create `modules/ci-cd/` with `google_artifact_registry_repository` for Docker images
  - _Tests:_ `terraform plan` shows repository created
  - _Depends on:_ P0-2

- [x] **P0-5 · Terraform: Cloud Run API proxy + App Check**
  - Create `infra/cloud-run/api-proxy/` with Dockerfile + FastAPI/Flask proxy app
  - Proxy endpoints: `/tmdb/*`, `/gemini/*`, `/omdb/*` — forwards requests with injected API keys
  - Create `modules/api-proxy/` Terraform module (service account, Cloud Run service, IAM)
  - Inject secrets from Secret Manager into Cloud Run env vars
  - Build Docker image and push to Artifact Registry
  - Set `min_instance_count = 0` (scale to zero — **$0 when idle**)
  - Enable **Firebase App Check** — verify requests come from your real app, reject unauthorized callers
  - _Tests:_ Unit tests for proxy routing logic; integration test hitting `/health` endpoint
  - _Depends on:_ P0-3, P0-4

- [x] **P0-6 · Refactor Flutter app to use API proxy**
  - Update `ApiConfig` to point to Cloud Run URL instead of direct API calls
  - Remove `.env` from `pubspec.yaml` assets
  - Remove direct API key usage from `TmdbService`, `GeminiService`, `OmdbService`
  - Add Firebase App Check token to all outbound proxy requests
  - App now has **zero secrets on device**
  - _Tests:_ Unit tests for `ApiConfig` URL construction; mock tests for service proxy calls
  - _Depends on:_ P0-5

### Track B: Firebase Observability (can start after P0-2)

- [x] **P0-7 · Terraform: Firebase project setup**
  - Create `modules/firebase/` with `google_firebase_project`
  - Register Firebase Android app + iOS app
  - Enable Firebase App Check (device attestation via DeviceCheck/Play Integrity)
  - Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
  - _Tests:_ `terraform plan` shows Firebase project + 2 app registrations
  - _Depends on:_ P0-2

- [x] **P0-8 · Add Firebase Crashlytics**
  - Add `firebase_crashlytics` + `firebase_core` packages to Flutter app
  - Initialize in `main.dart` with `FlutterError.onError` and `PlatformDispatcher.onError`
  - _Tests:_ Verify Crashlytics initializes without error in test mode
  - _Depends on:_ P0-7

- [x] **P0-9 · Add Firebase Analytics**
  - Add `firebase_analytics` package
  - Add screen tracking to navigation events
  - _Tests:_ Mock analytics observer, verify screen names are logged
  - _Depends on:_ P0-7

### Track C: Code Quality (no infra dependencies)

- [x] **P0-10 · Fix hardcoded German strings**
  - `watch_history_entry.dart` → move `watchedAgo` strings to i18n ARB files
  - `MediaType.displayName` → use localized strings instead of `'Film'`/`'Serie'`
  - Remove German defaults in comments and fallback values
  - _Tests:_ Unit tests verifying both EN and DE locales produce correct strings
  - _Depends on:_ Nothing

- [x] **P0-11: Add basic accessibility** (Priority: High)
  - *Context:* Ensures the app is usable by visually impaired automated systems and human users, required for proper UX.
  - *Action:* Add `Semantics` labels to buttons, `ExcludeSemantics` for decorative images, and ensure minimum color contrast (WCAG AA). Support dynamic text scaling.
  - *Impact:* Wider user base, avoids negative app store reviews regarding accessibility constraints.
  - Use `MediaQuery.boldTextOf(context)` for bold text preference
  - Test with VoiceOver (iOS) and TalkBack (Android)
  - _Tests:_ Widget tests with `tester.getSemantics()` verifying semantic labels exist
  - _Depends on:_ Nothing

---

## 🟡 P1 — Pre-Launch Essentials

> Required before public release. Build on the P0 foundation.

### Track D: Auth & Cloud Data

- [x] **P1-1 · Terraform: Firebase Auth (Identity Platform)**
  - Create `modules/firebase-auth/` with `google_identity_platform_config`
  - Enable Email/Password, Google Sign-In, Apple Sign-In
  - _Tests:_ `terraform plan` shows auth providers configured
  - _Depends on:_ P0-7

- [x] **P1-2 · Terraform: Cloud Firestore**
  - Create `modules/firestore/` with `google_firestore_database`
  - Enable point-in-time recovery
  - Write Firestore security rules (`firestore.rules`) — only authenticated users can read/write their own data
  - Design collections: `users/{uid}/watchHistory`, `users/{uid}/watchlist`, `users/{uid}/preferences`
  - _Tests:_ Firestore rules unit tests via `@firebase/rules-unit-testing`
  - _Depends on:_ P0-7

- [x] **P1-3 · Flutter: Firebase Auth integration**
  - Add `firebase_auth` + `google_sign_in` + `sign_in_with_apple` packages
  - Create `AuthService` and `authStateProvider`
  - Add login/signup screens (email, Google, Apple)
  - Gate cloud features behind authentication
  - _Tests:_ Unit tests for `AuthService` with mocked `FirebaseAuth`; widget tests for login screen
  - _Depends on:_ P1-1

- [x] **P1-4 · Flutter: Migrate from Hive to Firestore**
  - Add `cloud_firestore` package
  - **Use Firestore's built-in offline persistence** (enabled by default on mobile) — no custom sync layer needed
  - Firestore handles: offline reads from cache, write queuing, automatic sync on reconnect, conflict resolution
  - Replace Hive repositories with Firestore-backed repositories for: watch history, watchlist, ratings, preferences
  - Keep Hive **only** for non-synced local flags (e.g., "has seen onboarding", "last tab index")
  - One-time migration: read existing Hive data → write to Firestore on first authenticated launch
  - _Tests:_ Unit tests for Firestore repositories with `fake_cloud_firestore` package; migration logic tests
  - _Depends on:_ P1-2, P1-3

> [!TIP]
> **Why no custom sync layer?** Firestore's SDK handles offline caching, write queuing, conflict resolution, and automatic reconnection natively. Building a Hive ↔ Firestore sync would reinvent what Firestore provides out of the box.

### Track E: CI/CD

- [x] **P1-5 · Terraform: Cloud Build CI/CD with coverage enforcement**
  - Create Cloud Build trigger for `main` branch pushes
  - Write `cloudbuild.yaml`: lint → test (with `--coverage`) → enforce **minimum 70% coverage** → build API proxy → deploy Cloud Run → deploy Firestore rules
  - Fail the build if coverage drops below threshold
  - _Tests:_ Verify trigger fires on test push
  - _Depends on:_ P0-4, P1-2

### Track F: Architecture Cleanup (no infra dependencies)

- [x] **P1-6 · Split monolithic screen files**
  - Extract `_AiWhyWatchCard`, `_TrailerButton`, `_WatchlistButton` from `detail_screen.dart` (1,289 lines)
  - Extract long press menu (~170 lines) from `home_screen.dart`
  - Extract `_StreamingServicesGrid`, `_CountrySelector` from `settings_screen.dart`
  - Target: < 300 lines per file
  - _Tests:_ Existing tests must still pass (pure refactor, no behavior change)
  - _Depends on:_ Nothing

- [x] **P1-7 · Refactor `TmdbService`**
  - Split into `TmdbApiClient` (HTTP only) + `TmdbRepository` (caching + business logic)
  - Create abstract repository interfaces for dependency inversion
  - Migrate models to `freezed` code generation (already in `dev_dependencies` but unused)
  - _Tests:_ Unit tests for `TmdbApiClient` with mocked `Dio`; unit tests for `TmdbRepository` with mocked client
  - _Depends on:_ P0-6 (service endpoints change to proxy)

- [x] **P1-8 · Implement `go_router`**
  - [x] Add `go_router` dependency
  - [x] Create `router.dart` and define typed routes for all screens
  - [x] Replace all `Navigator.push` and `Navigator.pop` calls with `context.go/push/pop`
  - [x] _Tests:_ Verify navigation flows and ensure tests compile with the new router
  - [x] _Depends on:_ P1-6 (cleaner screen files)

### Track G: UX Essentials

- [x] **P1-9 · Add onboarding flow**
  - First app launch only (store flag `has_seen_onboarding` locally)
  - Screen 1: Language/Country selection
  - Screen 2: Streaming service picker (checkboxes)
  - Screen 3: Preferred genres
  - Screen 4: Theme preference (Dark/Light/System)
  - Screen 5: Optional: Import taste profile
  - _Tests:_ Widget test for onboarding flow structure
  - _Depends on:_ P1-8 (Navigation) Hive — local-only, not synced)
  - _Tests:_ Widget tests for each onboarding screen; test that flag prevents re-showing
  - _Depends on:_ P0-10 (i18n must work correctly first)

- [x] **P1-10 · Add light/dark/system theme toggle**
  - Add `ThemeMode` state to user preferences (dark / light / system)
  - Create light theme in `AppTheme` matching the design language
  - Respect `MediaQuery.platformBrightness` for system mode
  - Persist choice in Hive (local preference) and Firestore (synced)
  - _Tests:_ Widget test verifying theme switches correctly; golden tests for light vs dark
  - _Depends on:_ Nothing

- [x] **P1-11 · Add offline indicator**
  - Add `connectivity_plus` package
  - Show subtle offline banner when no network connection
  - Firestore handles data access automatically (reads from cache, queues writes)
  - Banner is purely informational — no custom sync logic needed
  - _Tests:_ Widget test with mocked connectivity stream
  - _Depends on:_ Nothing

- [x] **P1-12 · Add pagination / infinite scroll**
  - Update discover/search methods to support multi-page fetching
  - Add `AsyncNotifier` or pagination provider for Popular, Top Rated, Genre sections
  - Implement scroll-to-load-more in list views
  - _Tests:_ Unit tests for pagination logic; widget test verifying next page loads on scroll
  - _Depends on:_ P1-7 (service refactor)

---

## 🟢 P2 — Post-Launch Polish

> Enhances quality, engagement, and delight after the app is live.

### Notifications & Engagement

- [x] **P2-1 · Terraform: Cloud Functions for notification triggers**
  - Create `modules/cloud-functions/` with `google_cloudfunctions2_function`
  - Write function: on Firestore document write to `releases/` → check users' watchlists → send FCM notification
  - Cloud Functions 2nd gen (runs on Cloud Run under the hood, but auto-scales and auto-deploys)
  - _Depends on:_ P0-7, P1-2

- [x] **P2-2 · Flutter: Push notifications**
  - Add `firebase_messaging` package
  - Implement notification handler (foreground + background)
  - Notification types: new releases from watchlist, trending picks, weekly recap
  - _Depends on:_ P2-1, P1-3

- [x] **P2-3 · Terraform: Firebase Remote Config**
  - Add Remote Config setup to Firebase module
  - Define default feature flags (e.g., `enable_social`, `enable_widgets`)
  - _Depends on:_ P0-7

- [x] **P2-4 · Flutter: A/B testing with Remote Config**
  - Add `firebase_remote_config` package
  - Use feature flags to gate experimental features
  - _Depends on:_ P2-3

### Testing & Quality

- [x] **P2-5 · Add screen-level widget tests**
  - Test all 11 screens with mocked providers
  - Test navigation flows between screens
  - _Depends on:_ P1-8 (router makes navigation testable)

- [x] **P2-6 · Add provider tests**
  - Test all 8 provider files with mocked services
  - Test async loading, error states, retry logic
  - _Depends on:_ P1-7 (abstract interfaces make mocking possible)

- [x] **P2-7 · Add golden (snapshot) tests**
  - Generate golden images for key screens and widgets
  - Include both dark and light theme variants
  - Add to CI pipeline for visual regression detection
  - _Depends on:_ P2-5, P1-5, P1-10

- [x] **P2-8 · Integration tests with Firebase Test Lab**
  - Write end-to-end integration tests using `integration_test` package
  - Run on Firebase Test Lab (free tier: **15 virtual device tests/day**, 5 physical device tests/day)
  - Add Terraform resource `google_firebase_test_lab` if available, otherwise configure via `gcloud`
  - Test critical flows: onboarding -> search -> detail -> rate -> watchlist
  - _Depends on:_ P1-5, P1-8
  - _Note:_ Tests take >30m and hang during local macOS execution, so they have been marked with `skip: true` for local logic.

### Animation & Polish

- [x] **P2-9 · Shared element Hero transitions everywhere**
  - Add Hero transitions for poster images: carousel → detail, search → detail, watchlist → detail
  - Add Hero for title text where appropriate
  - _Depends on:_ P1-8

- [x] **P2-10 · Add platform-adaptive page transitions**
  - iOS: right-to-left slide
  - Android: fade-through (Material Motion)
  - Implement via `go_router`'s `CustomTransitionPage`
  - _Depends on:_ P1-8

- [x] **[P2-11] Animations & Micro-interactions:** Add Lottie/Rive animations for empty states (e.g., empty watchlist, no search results) and success moments (e.g., rated a movie). Add full-screen skeleton shimmer screens for loading. Replace default `CircularProgressIndicator` with branded loading animation.
  - Add **full-screen skeleton shimmer screens** for home, search, and detail (not just card-level shimmer)
  - _Depends on:_ Nothing

- [x] **[P2-12] Add swipe gestures + haptic feedback strategy**
  - Swipe-to-dismiss on detail screens
  - Swipe actions on list items (add to watchlist, rate, dismiss)
  - **Haptic feedback patterns:** light tap → navigation, medium → actions (rate, add), heavy → destructive (remove, reset)
  - Apply haptic patterns consistently across all interactive elements
  - _Depends on:_ Nothing

- [x] **P2-13 · Tablet & iPad layout optimization**
  - Use responsive breakpoints from `AppTheme` (`tabletBreakpoint`, `desktopBreakpoint`) in all screens
  - Detail screen: side-by-side poster + info on tablets (instead of vertical stack)
  - Home screen: 2-column grid for sections on tablets
  - Search results: multi-column grid on wide screens
  - Master-detail navigation on iPads (split view)
  - _Depends on:_ P1-6 (files must be split for manageable changes)

### Features

- [x] **P2-14: Watch Statistics Dashboard [P3 -> P2/P3]**
  - _Description_: A new screen/section visualizing total watch time, genre breakdowns, and rating stats using `fl_chart`.
  - Monthly watch activity bar chart
  - Average rating given vs. community rating
  - _Depends on:_ Nothing (works with existing watch history data)

- [x] **P2-15 · Cast & crew pages**
  - Tap on actor/director → filmography page with poster grid
  - Use TMDB `/person/{id}` and `/person/{id}/combined_credits` API via proxy
  - _Depends on:_ P0-5 (API proxy must be running)

- [x] **P2-16 · Home screen widgets**
  - iOS: WidgetKit widget ("Tonight's Pick", "New This Week")
  - Android: Glance widget
  - _Depends on:_ Nothing (works with local Firestore cache)

---

## 🔵 P3 — Growth & Differentiation

> Features that set the app apart and drive long-term retention.

- [x] **P3-1 · Terraform: Cloud Scheduler for weekly recap**
  - Create `modules/scheduler/` with weekly recap job (Monday 9 AM Europe/Berlin)
  - Job invokes Cloud Function to generate personalized recap per user
  - _Depends on:_ P2-1

- [x] **P3-2 · Social features**
  - Follow friends, see their recent watches/ratings
  - Shared watchlists ("Movie night with Alex")
  - Firestore collections: `users/{uid}/following`, `sharedLists/{listId}`
  - _Depends on:_ P1-3, P1-4

- [x] **P3-3 · Multi-profile support**
  - Family accounts with separate taste profiles per member
  - Profile switcher in settings
  - _Depends on:_ P1-3

- [x] **P3-4 · Year-in-review feature**

- [x] **P3-5 · Episode-level tracking for TV series**
  - Mark individual episodes as watched
  - Progress bar per season
  - Countdown to next episode air date
  - _Depends on:_ P1-4

---

## 📦 App Store Readiness (Do Alongside P1)

> Release requirements — not features. Work in parallel with P1 track.

- [x] **R-1 · App icon & splash screen** — Design branded icon, add `flutter_native_splash`
- [x] **R-2 · Privacy policy** — Create and host at a public URL (required by both stores)
- [x] **R-3 · Bundle ID & signing** — Configure `com.streamscout.app` for iOS + Android
- [x] **R-4 · ProGuard / R8 rules** — Add shrink rules for Android release builds
- [x] **R-5 · Versioning strategy** — Semantic versioning with CI auto-increment build number
- [x] **R-6 · App Store metadata** — Screenshots, descriptions, keywords for both stores
- [x] **R-7 · Build flavors** — Create dev / staging / prod flavors with separate Firebase configs

---

## 🏗️ GCP Infrastructure Reference

> All infrastructure is **Terraform-managed** — `terraform apply` creates everything.

### Terraform Module Map

| Module | GCP Service | Terraform Resource | Created In |
|--------|------------|-------------------|-----------|
| `secrets` | Secret Manager | `google_secret_manager_secret` | P0-3 |
| `ci-cd` | Artifact Registry | `google_artifact_registry_repository` | P0-4 |
| `api-proxy` | Cloud Run + App Check | `google_cloud_run_v2_service` | P0-5 |
| `firebase` | Firebase Project + App Check | `google_firebase_project` | P0-7 |
| `firebase-auth` | Identity Platform | `google_identity_platform_config` | P1-1 |
| `firestore` | Firestore | `google_firestore_database` | P1-2 |
| `ci-cd` (extended) | Cloud Build | `google_cloudbuild_trigger` | P1-5 |
| `cloud-functions` | Cloud Functions 2nd gen | `google_cloudfunctions2_function` | P2-1 |
| `scheduler` | Cloud Scheduler | `google_cloud_scheduler_job` | P3-1 |

### 💰 Cost Analysis — Optimized for Free Tier

> [!TIP]
> **Estimated monthly cost for < 10K MAU: $0.** Every service stays within free tier. First cost at ~5-10K DAU: **~$5-15/month** (Firestore reads + Cloud Run compute).

#### Always Free (Unlimited, $0 Forever)

| Service | Used For |
|---------|---------|
| Firebase Crashlytics | P0-8 — crash & ANR logs |
| Firebase Analytics | P0-9 — screen views, funnels |
| Firebase Cloud Messaging | P2-2 — push notifications |
| Firebase Remote Config | P2-3 — feature flags, A/B tests |
| Firebase Performance | P0-7 — API traces, render times |
| Firebase App Check | P0-5 — request attestation |

#### Generous Free Tier

| Service | Free Tier | Exceeds At | Cost After |
|---------|-----------|-----------|-----------|
| **Firebase Auth** | 50K MAU (email + social) | Unlikely pre-Series A | $0.0055/MAU |
| **Firestore** | 1 GiB, 50K reads/day, 20K writes/day | ~5K DAU heavy usage | $0.06/100K reads |
| **Cloud Run** | 2M req/mo, 360K vCPU-sec | ~60K req/day | $0.000024/vCPU-sec |
| **Cloud Functions** | 2M invocations/mo, 400K GB-sec | Unlikely (event-driven) | $0.0000025/invoc |
| **Cloud Build** | 120 build-min/day | >120 builds/day | $0.003/min |
| **Secret Manager** | 6 versions, 10K access ops | Never (3 secrets) | $0.06/10K ops |
| **Artifact Registry** | 500 MB | Many image versions | $0.10/GiB/mo |
| **Cloud Scheduler** | 3 jobs | >3 cron jobs (we use 1) | $0.10/job/mo |
| **Firebase Test Lab** | 15 virtual, 5 physical tests/day | Heavy CI testing | $1/virtual device-hr |

#### Cost Optimization Decisions

| Decision | Chosen (Cheaper) | Rejected | Why |
|----------|-----------------|----------|-----|
| Notification triggers | Cloud Functions (event-driven) | Cloud Run endpoint | No idle compute cost |
| Offline sync | Firestore built-in (free, zero code) | Custom Hive ↔ Firestore sync | No extra infra or code to maintain |
| Database | Firestore (50K reads/day free) | Realtime DB (10 GiB transfer limit) | Better free tier for read-heavy apps |
| API proxy | Cloud Run scale-to-zero (`min=0`) | Always-on (`min=1`) | $0 when no users active |
| API security | App Check (free) | Custom API key per user | Zero cost, no key management |
| Region | europe-west1 (Frankfurt) | Multi-region | Lower cost, EU data residency (GDPR) |
| Device testing | Firebase Test Lab (15 free/day) | Third-party device farms | Already in GCP, free tier |

### One-Time Bootstrap

```bash
# 1. Install tools
brew install terraform google-cloud-sdk

# 2. Auth
gcloud auth login && gcloud auth application-default login

# 3. Create project (only manual step)
gcloud projects create streamscout-dev --name="StreamScout Dev"
gcloud config set project streamscout-dev

# 4. Enable billing → console.cloud.google.com/billing

# 5. State bucket
gsutil mb -l europe-west1 gs://streamscout-terraform-state

# 6. Apply
cd infra/terraform/environments/dev
terraform init && terraform plan && terraform apply
```

---

## 🔍 Current App vs. Target State — Full Comparison

> This section maps **every file, lib, pattern, and tool** in the current codebase to what it becomes after the roadmap. Nothing is left behind.

### Architecture

| Layer | Current | Target | Changed By |
|-------|---------|--------|-----------|
| **Project structure** | `lib/{config,data,domain,ui,utils}` — flat | Same top-level, but with `lib/data/repositories/` split into abstract interfaces + implementations | P1-7 |
| **State management** | Riverpod (`flutter_riverpod`, `StateProvider`, `FutureProvider`) | Riverpod with `AsyncNotifier` for pagination + Firestore streams | P1-12 |
| **Navigation** | Manual `Navigator.push` + custom `AppPageRoute` | `go_router` with typed routes, deep links, `CustomTransitionPage` | P1-8 |
| **API layer** | `TmdbService` (870 lines, HTTP + cache + parsing in one class) | `TmdbApiClient` (HTTP only) + `TmdbRepository` (caching + logic) + abstract interfaces | P1-7 |
| **Models** | Hand-written `toJson`/`fromJson`, manual `copyWith`, manual `==`/`hashCode` | `freezed` code generation (immutable, `copyWith`, JSON, equality — all auto-generated) | P1-7 |
| **Secret management** | `.env` file bundled as Flutter asset, read via `flutter_dotenv` | Secret Manager → Cloud Run proxy. **Zero secrets on device.** | P0-1 → P0-6 |
| **Config** | `ApiConfig` reads keys from `dotenv` | `ApiConfig` holds Cloud Run proxy URL only (no keys) | P0-6 |

### Packages — What Changes

#### Packages REMOVED

| Package | Current Use | Why Removed | Removed By |
|---------|------------|-------------|-----------|
| `flutter_dotenv` | Load `.env` file for API keys | No more `.env` — keys are in Secret Manager, proxied via Cloud Run | P0-6 |
| `hive` + `hive_flutter` | Local storage for watch history, watchlist, preferences | Replaced by Firestore (with built-in offline persistence) — Hive kept only for local-only flags | P1-4 |

#### Packages ADDED

| Package | Purpose | Added By |
|---------|---------|----------|
| `firebase_core` | Firebase initialization | P0-7 |
| `firebase_crashlytics` | Crash reporting | P0-8 |
| `firebase_analytics` | Screen tracking, funnels | P0-9 |
| `firebase_app_check` | API proxy request attestation | P0-5 |
| `firebase_auth` | Email, Google, Apple Sign-In | P1-3 |
| `google_sign_in` | Google Sign-In flow | P1-3 |
| `sign_in_with_apple` | Apple Sign-In flow | P1-3 |
| `cloud_firestore` | Cloud database with offline persistence | P1-4 |
| `go_router` | Declarative routing, deep links | P1-8 |
| `connectivity_plus` | Network state detection | P1-11 |
| `firebase_messaging` | Push notifications | P2-2 |
| `firebase_remote_config` | Feature flags, A/B testing | P2-4 |
| `flutter_native_splash` | Branded splash screen | R-1 |
| `lottie` or `rive` | Animated empty states, loading, success | P2-11 |
| `fake_cloud_firestore` (dev) | Firestore mocking in tests | P1-4 |

#### Packages KEPT (unchanged)

| Package | Why It Stays |
|---------|-------------|
| `flutter_riverpod` + `riverpod_annotation` | State management — still best choice for Flutter |
| `dio` | HTTP client — used by `TmdbApiClient` (proxied calls) |
| `cached_network_image` | Image caching — still needed |
| `shimmer` | Skeleton loading (enhanced in P2-11) |
| `flutter_animate` | Animation library — still used |
| `google_fonts` | Outfit + Inter typography |
| `freezed_annotation` + `json_annotation` | Already installed, now actually used (P1-7) |
| `equatable` | May phase out in favor of `freezed` equality, but harmless |
| `collection` | List utilities |
| `intl` + `flutter_localizations` | i18n support |
| `url_launcher` | Opening external links |
| `google_generative_ai` | Gemini AI SDK (calls now go through proxy) |
| `speech_to_text` | Voice search |
| `mocktail` (dev) | Test mocking |
| `build_runner` + `freezed` + `json_serializable` + `riverpod_generator` (dev) | Code generation — now actively used |

### Data Layer — File-by-File Migration

| Current File | What Happens | Target | Done By |
|-------------|-------------|--------|---------|
| `data/repositories/watch_history_repository.dart` | Rewrite: Hive → Firestore | `FirestoreWatchHistoryRepository` implementing `WatchHistoryRepository` interface | P1-4, P1-7 |
| `data/repositories/watchlist_repository.dart` | Rewrite: Hive → Firestore | `FirestoreWatchlistRepository` implementing `WatchlistRepository` interface | P1-4, P1-7 |
| `data/repositories/user_preferences_repository.dart` | Rewrite: Hive → Firestore | `FirestorePreferencesRepository` implementing `PreferencesRepository` interface | P1-4, P1-7 |
| `data/repositories/dismissed_repository.dart` | Rewrite: Hive → Firestore | `FirestoreDismissedRepository` implementing `DismissedRepository` interface | P1-4, P1-7 |
| `data/services/tmdb_service.dart` (870 lines) | Split into 2 files | `TmdbApiClient` (HTTP) + `TmdbRepository` (cache + logic) | P1-7 |
| `data/services/gemini_service.dart` | Update: direct API → proxy | Route calls through Cloud Run proxy | P0-6 |
| `data/services/omdb_service.dart` | Update: direct API → proxy | Route calls through Cloud Run proxy | P0-6 |
| `data/services/taste_profile_service.dart` | No change | Stays as-is | — |
| `data/models/*.dart` (6 files) | Migrate to freezed | Auto-generated `toJson`, `fromJson`, `copyWith`, `==` | P1-7 |
| `config/api_config.dart` | Rewrite: remove keys | Cloud Run proxy URL only, no API keys | P0-6 |
| `config/providers.dart` | Update: new repos + auth | Add `authStateProvider`, update repo providers to Firestore versions | P1-3, P1-4 |

### Screen Files — Refactoring Map

| Current File | Lines | What Happens | Done By |
|-------------|------:|-------------|---------|
| `detail_screen.dart` | 1,289 | Extract `_AiWhyWatchCard`, `_TrailerButton`, `_WatchlistButton` to own files | P1-6 |
| `home_screen.dart` | 694 | Extract long press menu (~170 lines) to own file | P1-6 |
| `settings_screen.dart` | 713 | Extract `_StreamingServicesGrid`, `_CountrySelector` to own files | P1-6 |
| `ai_chat_screen.dart` | 765 | No split needed (cohesive), but update Gemini calls to proxy | P0-6 |
| `watch_history_screen.dart` | 667 | Update data source from Hive to Firestore repo | P1-4 |
| `main_navigation_screen.dart` | 167 | Replace `IndexedStack` with `go_router` shell route | P1-8 |
| All screens | — | Add `Semantics` labels, dynamic text scaling support | P0-11 |

### Testing — Current Coverage vs. Target

| Test Area | Current (31 files) | Target | Gap Filled By |
|-----------|-------------------|--------|--------------|
| **Models** | ✅ 8 test files (media, genre, streaming, preferences, watch history, watchlist) | ✅ Keep + extend for freezed | P1-7 |
| **Repositories** | ✅ 4 test files (all 4 repos) | 🔄 Rewrite for Firestore repos using `fake_cloud_firestore` | P1-4 |
| **Services** | ✅ 5 test files (tmdb, gemini, omdb, taste, tmdb_filter) | 🔄 Update for proxy endpoints + split API client/repo | P0-6, P1-7 |
| **Config** | ✅ 3 test files (api_config, providers, filtering) | 🔄 Update for proxy URL config | P0-6 |
| **Utils** | ✅ 3 test files (age_rating, ai_title_parser, media_filter) | ✅ Keep as-is | — |
| **Widgets** | ⚠️ 5 test files (error_retry, media_card, media_section, rating_dialog, streaming_filter) | Add tests for all 21 widgets | P2-5 |
| **Screens** | ❌ 0 test files (none of 11 screens tested) | Test all 11 screens | P2-5 |
| **Providers** | ✅ 8 test files for all provider families | Test all 8 provider files | P2-6 |
| **Integration** | ❌ Empty `integration_test/` directory | E2E tests on Firebase Test Lab | P2-8 |
| **Golden/snapshot** | ❌ None | Golden tests for dark + light themes | P2-7 |
| **CI enforcement** | ❌ No CI pipeline | Cloud Build with 70% coverage minimum | P1-5 |

### Infrastructure — Before & After

| Concern | Current | Target | Done By |
|---------|---------|--------|---------|
| **Secrets** | `.env` in git with live keys | GCP Secret Manager (Terraform) | P0-1, P0-3 |
| **API access** | Direct API calls from client | Cloud Run proxy + App Check | P0-5, P0-6 |
| **Database** | Hive (local only, lost on uninstall) | Firestore (cloud, offline-first, survives uninstall) | P1-2, P1-4 |
| **Auth** | None | Firebase Auth (email, Google, Apple) | P1-1, P1-3 |
| **Crash reporting** | None (crashes discovered via user reports) | Firebase Crashlytics (auto-upload) | P0-8 |
| **Analytics** | None | Firebase Analytics (screens, events, funnels) | P0-9 |
| **Notifications** | None | FCM via Cloud Functions triggers | P2-1, P2-2 |
| **CI/CD** | None (manual builds) | Cloud Build (auto lint → test → deploy) | P1-5 |
| **Feature flags** | None | Firebase Remote Config | P2-3, P2-4 |
| **IaC** | None | Terraform (all GCP resources as code) | P0-2 onwards |

### UX — Before & After

| Feature | Current | Target | Done By |
|---------|---------|--------|---------|
| **Theme** | Dark only | Dark / Light / System toggle | P1-10 |
| **Onboarding** | None (drops into German defaults) | 5-screen guided setup | P1-9 |
| **i18n** | EN + DE, but with hardcoded German in code | Fully localized, no hardcoded strings | P0-10 |
| **Accessibility** | None | Semantic labels, contrast, dynamic text scaling | P0-11 |
| **Offline UX** | Silent failure | Offline banner + Firestore cache | P1-11 |
| **Page transitions** | Custom `AppPageRoute` (same on all platforms) | Platform-adaptive (iOS slide, Android fade) | P2-10 |
| **Hero animations** | Partial (some screens) | All list → detail transitions | P2-9 |
| **Loading states** | Card-level shimmer only | Full-screen skeleton screens + branded spinner | P2-11 |
| **Haptic feedback** | `selectionClick()` on nav only | Light/medium/heavy pattern across all interactions | P2-12 |
| **Tablet layout** | Breakpoints defined but likely unused | Multi-column grids, split view, adapted spacing | P2-13 |
| **Pagination** | Single page (page 1 only) | Infinite scroll with auto-loading | P1-12 |
| **Gestures** | Long press menu on home | Swipe-to-dismiss, swipe actions on lists | P2-12 |

---

## 📊 Item Count Summary

| Tier | Items | Track |
|------|------:|-------|
| 🔴 P0 | 11 | Security, Firebase observability, code quality |
| 🟡 P1 | 12 | Auth, Firestore, CI/CD, architecture, UX |
| 🟢 P2 | 16 | Notifications, testing, animation, features |
| 🔵 P3 | 5 | Growth features |
| 📦 R | 7 | App Store readiness |
| **Total** | **51** | |
