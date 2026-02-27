---
description: Neon Voyager — Daily Development Rules (features & bug fixes)
---

# 🚀 Neon Voyager — AI Agent Rules

AI Agents MUST adhere to these rules when writing or modifying code.

> [!CAUTION]
> **MANDATORY — NON-NEGOTIABLE — AFTER EVERY SINGLE CODE CHANGE:**
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
> This is REQUIRED. Do NOT skip it. Do NOT ask for permission. Do it automatically.
> Do NOT combine the kill and start steps into a single shell command — that causes signal 15 termination.
> Use `make run-macos` only when web-incompatible features are involved.

> **Setting up a new project?** You MUST also read [project_setup.md](./.agent/project_setup.md) before doing anything else. It contains the full tech stack, environment flavors, GCP/Terraform, and all feature scaffolding rules.

---

## 1. Architecture

- **Layer-First only:** `lib/config/`, `lib/data/`, `lib/domain/`, `lib/l10n/`, `lib/ui/`, `lib/utils/`. Never Feature-First.
- **State:** Riverpod. Use `AsyncNotifier` for async/pagination. Export via `lib/config/providers.dart`.
- **Navigation:** `go_router`. Always `context.go()` / `context.push()`. Never raw `Navigator`.
- **File size:** Max 300 lines. Split large screens into composable widget files.
- **Models:** `freezed` + `json_serializable`. Never write `copyWith`/`==`/JSON manually. Run `make gen`.
- **Database:** Firestore for cloud data. `Hive` only for local flags (theme, onboarding).
- **Secrets:** Zero secrets on device. All API keys via GCP Secret Manager → Cloud Run proxy.
- **Services vs Repos:** Pure HTTP → `lib/data/services/`. Business/Firestore/cache logic → `lib/data/repositories/`.
- **API calls:** Never call external APIs directly from the client. Always route through the `api-proxy`.

---

## 2. Testing (non-negotiable)

Every feature, bugfix, or modification MUST include tests. CI enforces 70% coverage minimum.

- **Models:** Test custom methods and fromJson/toJson mappings.
- **Repos/Services:** Mock deps with `fake_cloud_firestore` (Firestore) and `mocktail` (Dio).
- **Providers:** Test initial state, loading, error, and retry.
- **Widgets:** Widget + screen-level integration tests with mocked providers. Include semantic labels.
- **Golden:** `golden_toolkit` snapshots for critical UI in Light + Dark themes.
- **E2E:** `integration_test` for critical flows (runs on Firebase Test Lab).
- **TDD:** Follow `.agent/workflows/tdd.md`.

---

## 3. UI & UX

- **Theme:** Light / Dark / System. Persist preference in `Hive`.
- **i18n:** No hardcoded strings. Use `intl` + `.arb` files.
- **Accessibility:** `Semantics` on all interactive widgets. `ExcludeSemantics` for decorative items. WCAG AA contrast.
- **Animations:** `Hero` transitions, skeleton shimmer loaders, platform-adaptive page transitions via `go_router`.
- **Layouts:** Tablet/iPad breakpoints in `AppTheme` — single vs multi-column grids.

---

## 4. AI Agent Workflow

1. **Analyze first:** Check architectural consistency before changing code.
2. **No shortcuts:** Use `freezed` for models. Never bypass the proxy. Never hardcode secrets.
3. **Commands:** `make gen` for code generation, `make test` for validation.
4. **Verify always — MANDATORY:** After EVERY code change that affects UI or logic, verify using the web build:
   - **First:** Kill existing processes:
     ```
     pkill -f "flutter" || true; pkill -f "dart" || true; pkill -f "python" || true; sleep 2
     ```
   - **Then:** Start the web server:
     ```
     make run-web
     ```
   - **Then:** Use the **browser subagent** to navigate to `http://localhost:3000` and visually verify the change works correctly. Navigate to the relevant screen and check for errors.
   - Fresh restart the server each time to avoid stale state.
   - Use `make run-macos` only when web-incompatible features are involved.
5. **TDD:** Output `_test.dart` alongside every new widget or service.

