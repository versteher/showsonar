---
description: "{{APP_NAME}} — Daily Development Rules (features & bug fixes)"
---

# {{APP_NAME}} — AI Agent Rules

AI Agents MUST adhere to these rules when writing or modifying code.

> [!IMPORTANT]
> **VERIFY AFTER COMPLETING A LOGICAL UNIT OF WORK**
> (e.g., finishing a feature, fixing a bug, completing a TDD Red-Green-Refactor cycle)
>
> Run these as **separate `run_command` tool calls** (never combined into one shell line):
>
> **Step 1 — Kill existing processes (run first, wait for it to finish):**
> ```
> pkill -f "flutter" || true; pkill -f "dart" || true; pkill -f "python" || true; sleep 2
> ```
>
> **Step 2 — Start the web server (run after Step 1 completes):**
> ```
> make run-web
> ```
>
> **Step 3 — Verify in browser:**
> Use the **browser subagent** to navigate to `http://localhost:3000` and visually verify the change.
>
> Do NOT combine the kill and start steps into a single shell command — that causes signal 15 termination.
> Use `make run-macos` only when web-incompatible features are involved (e.g., speech_to_text, home widgets).

> **Setting up a new project?** You MUST also read [project_setup.md](./.agent/project_setup.md) before doing anything else. It contains the full tech stack, environment flavors, GCP/Terraform, DevContainer, CI/CD, and all feature scaffolding rules.

---

## 1. Architecture

- **Layer-First only.** Never Feature-First.
- **State:** Riverpod with `@riverpod` annotation + `AsyncNotifier` for async/pagination. Central barrel: `lib/config/providers.dart`. Run `make gen` after every provider file change.
- **Navigation:** `go_router` with platform-adaptive transitions. Always `context.go()` / `context.push()`. Never raw `Navigator`.
- **Models:** `freezed` + `json_serializable`. Never hand-write `copyWith`/`==`/JSON. Run `make gen`.
- **File size:** Max 300 lines. Split large screens into composable widget files in the same directory.
- **Services vs Repos:** Pure HTTP/Dio → `lib/data/services/`. Business logic, Firestore, caching → `lib/data/repositories/`.
- **Secrets:** Zero on device. All API keys via GCP Secret Manager → Cloud Run `api-proxy`.
- **API calls:** Never call external APIs directly from the client. Always route through the `api-proxy`.
- **Database:** Firestore for cloud data (built-in offline persistence). `shared_preferences` for local device flags (theme, onboarding).
- **Error handling:** Use reusable `ErrorRetryWidget` (compact for inline, full for full-screen). Never show raw error messages to users.

```
lib/
  config/          # Providers barrel, router, Firebase config, providers/
  data/
    models/        # Freezed data classes (.freezed.dart, .g.dart)
    services/      # HTTP clients (Dio-based, talk to api-proxy)
    repositories/  # Business logic, Firestore CRUD, caching
  domain/          # Pure business rules, engines, enums
  l10n/            # Hand-maintained localizations (NOT auto-generated)
  ui/
    screens/       # Screen widgets (max 300 lines each)
    widgets/       # Reusable composable widgets
    theme/         # AppTheme: colors, typography, breakpoints
  utils/           # Pure helpers: haptics, filters, analytics, crashlytics
```

---

## 2. State Management Gotchas

**@riverpod family providers — instance-level overrides only in tests:**
```dart
// CORRECT: override individual instance
mediaDetailsProvider(id: m.id, type: m.type)
    .overrideWith((ref) async => testData)

// WRONG: family-level (compile error — generated families have no overrideWith)
mediaDetailsProvider.overrideWith((ref) async => testData)
```

**Non-migrated `FutureProvider.family` — record syntax still needs outer parens:**
```dart
// Old-style (record params): keep outer parens
omdbRatingsProvider((imdbId: X, title: Y, year: Z))

// Migrated @riverpod families: drop the outer parens
mediaDetailsProvider(id: 123, type: MediaType.movie)
```

**PaginationNotifier — never declare `final Ref ref;`:**
```dart
// Subclasses use inherited `ref` from AsyncNotifier
abstract class PaginationNotifier extends AsyncNotifier<PaginationState<Media>> {
  Future<List<Media>> fetchPage(int page);
  // Use `ref` directly — do NOT declare your own Ref field
}

// Provider declaration:
final myProvider = AsyncNotifierProvider<MyNotifier, PaginationState<Media>>(MyNotifier.new);
```

**Provider barrel:** All sub-provider files export from `lib/config/providers.dart`. Core service/repo providers live in the barrel to avoid circular imports.

**After every provider change:** Always run `make gen` to regenerate `.g.dart` files.

---

## 3. Testing (Non-Negotiable)

Every feature, bugfix, or modification MUST include tests. CI enforces **70% coverage minimum**.

| Layer | What to test | Mock strategy |
|-------|-------------|---------------|
| Models | JSON round-trip, `copyWith`, computed getters, factory constructors | None needed |
| Services | Endpoint paths, query params, response parsing, caching (TTL + offline fallback), error mapping | `MockDio` via `mocktail` |
| Repositories | Full CRUD, idempotent ops, sorted results | `fake_cloud_firestore` for Firestore |
| Providers | Initial state, loading, error, retry, invalidation | `ProviderContainer` + `MockDependencies` |
| Utilities | Table-driven pure function tests, all branches | None needed |
| Widgets | User interactions, text/icons, semantic labels | `pumpAppScreen` wrapper |
| Golden | Light + Dark theme snapshots | `golden_toolkit` |
| E2E | Critical user flows | `integration_test` on Firebase Test Lab |

**Key test patterns:**

- **Test utilities:** `test/utils/test_provider_container.dart` (`MockDependencies`) and `test/utils/test_app_wrapper.dart` (`pumpAppScreen`).
- **Animated widgets:** Use `pump()` — never `pumpAndSettle()` with Shimmer, `flutter_animate`, or infinite animations.
- **Many-param methods:** Use `FakeRepository extends Fake` pattern instead of mocktail matchers when methods have many named params.
- **Family providers in widget tests:** Resolve the media first (`final m = media ?? testMedia;`), then override with `m.id`/`m.type`.
- **Test locale:** Defaults to EN (`Locale('en', 'US')`) — assertions must use English strings.
- **TDD workflow:** Follow `.agent/workflows/tdd.md`. Red-Green-Refactor, one behavior at a time.

---

## 4. UI & UX Standards

- **Theme:** Light / Dark / System. Persist preference in `shared_preferences` via `LocalPreferencesRepository`. Centralized `AppTheme` class holds brand colors, spacing scale, border radii, breakpoints, typography.
- **Localization:** Hand-maintained l10n (NOT auto-generated). Four files must be edited for every new key:
  1. `lib/l10n/app_localizations.dart` — abstract interface
  2. `lib/l10n/app_localizations_en.dart` — English implementation
  3. `lib/l10n/app_localizations_<locale>.dart` — additional locale implementation
  4. `lib/l10n/arb/app_en.arb` + `app_<locale>.arb` — ARB source files
- **Accessibility:** `Semantics` on all interactive widgets. `ExcludeSemantics` for decorative elements. WCAG AA contrast minimum. Dynamic text scaling support. Min touch target: 48px.
- **Animations:** `Hero` transitions for navigation. Shimmer skeleton loaders for loading states. Platform-adaptive page transitions via `go_router` (`CustomTransitionPage`): iOS/macOS = slide, Android = fade. `flutter_animate` for micro-interactions.
- **Responsive:** Breakpoints in `AppTheme` — mobile (<768), tablet (768–1024), desktop (>1024). Use `AppTheme.responsive()` helper for value selection. Single vs multi-column grids.
- **Haptics:** Centralized `AppHaptics` utility — `lightImpact()` for navigation/tabs, `mediumImpact()` for primary actions, `heavyImpact()` for destructive actions, `selectionClick()` for granular selection.
- **Content filtering:** Viewing context chips pattern — filter all content sections by genre include/exclude + age-rating constraints. `ViewingContext` enum + `ViewingContextFilter` domain model.

---

## 5. Key Commands

| Command | Purpose |
|---------|---------|
| `make run-web` | Run on web (port 3000) with API proxy (port 8080) |
| `make run-macos` | Run on macOS with API proxy |
| `make run-ios` | Run on iOS (default: dev; `FLAVOR=prod make run-ios` for prod) |
| `make run-android` | Run on Android |
| `make gen` | Run build_runner (freezed, json_serializable, riverpod) |
| `make watch` | Continuous build_runner watch |
| `make clean` | Clean project + `flutter pub get` |
| `make test` | Run all tests |
| `make lint` | Run Flutter analyzer |

---

## 6. Agent Workflow

1. **Analyze first:** Check architectural consistency before changing code. Read existing patterns.
2. **No shortcuts:** Use `freezed` for models. Never bypass the proxy. Never hardcode secrets. Never use raw `Navigator`.
3. **TDD always:** Write `_test.dart` alongside every new widget or service. Follow Red-Green-Refactor (`.agent/workflows/tdd.md`).
4. **Code generation:** `make gen` after any change to models, providers, or freezed classes.
5. **Verify after logical units:** After completing a feature, bug fix, or TDD cycle — kill processes, `make run-web`, verify at `http://localhost:3000`. See note block at top.
6. **File size:** If a file approaches 300 lines, split it immediately. Extract composable widgets or use Dart `part` files for repositories.
7. **Commit style:** Conventional commits — `feat:`, `fix:`, `refactor:`, `test:`, `docs:`.
