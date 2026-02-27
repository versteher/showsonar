---
description: Test-Driven Development workflow for implementing new features
---

# TDD Workflow — Red-Green-Refactor

Every new feature MUST follow this workflow. No production code is written before a failing test exists.

## 1. Understand the Feature
- Clarify requirements with the user
- Identify all layers involved: **model → service → repository → provider → widget**
- Plan test files **before** any production code

## 2. 🔴 Red — Write Failing Tests First
- Create the test file(s) for the feature **BEFORE** any production code
- Write tests covering:
  - ✅ Happy path
  - ⚠️ Edge cases (empty input, null values, boundary values)
  - ❌ Error states (network failure, missing data, invalid input)
  - 🔄 Idempotency (e.g., adding same item twice)
- Run the tests to confirm they **fail** (compilation errors count as red)

// turbo
```bash
flutter test <path_to_new_test_file>
```

## 3. 🟢 Green — Write Minimum Production Code
- Write ONLY the code needed to make the failing tests pass
- Do not add extra functionality beyond what the tests require
- Run the tests to confirm they **pass**

// turbo
```bash
flutter test <path_to_new_test_file>
```

## 4. 🔵 Refactor — Clean Up
- Improve code quality without changing behavior
- Extract helpers, rename variables, reduce duplication
- Run ALL tests to confirm nothing broke

// turbo
```bash
flutter test
```

## 5. Repeat
- Go back to step 2 for the next piece of behavior
- Work layer by layer: model → service/repository → provider → widget

---

## Layer-by-Layer Test Patterns

### Models
- Test JSON round-trip: `fromJson(toJson(model)) == model`
- Test `copyWith` preserves unmodified fields
- Test `operator ==` and `hashCode` consistency
- Test computed getters (e.g., `uniqueKey`, `watchedAgo`)
- Test factory constructors (e.g., `fromMedia`)

### Services (upstream API)
- **Always mock Dio** — never make real HTTP calls in tests
- Inject `MockDio` via constructor: `TmdbService(dio: mockDio)`
- Verify correct endpoint path and query parameters
- Test successful response parsing
- Test `DioException` → service-level exception mapping
- Test caching behavior:
  - First call hits API
  - Second call within TTL returns cached (verify Dio NOT called again)
  - Call after TTL hits API again
  - Offline fallback: stale cache served on `DioException`
  - No cache + failure: exception propagates

```dart
// Pattern: Mock Dio
class MockDio extends Mock implements Dio {}

setUp(() {
  mockDio = MockDio();
  service = TmdbService(dio: mockDio);
});

// Pattern: Verify endpoint + params
when(() => mockDio.get('/path', queryParameters: any(named: 'queryParameters')))
  .thenAnswer((_) async => Response(
    requestOptions: RequestOptions(path: '/path'),
    data: { 'results': [...] },
  ));
```

### Repositories (Hive-backed)
- Use `Hive.init()` with a temp directory in `setUp`
- Test full CRUD cycle: add → get → update → remove → verify gone
- Test `_safeBox` throws `StateError` when not initialized
- Test `getAllEntries` returns sorted results
- Test idempotent operations (e.g., add same service twice)
- Clean up in `tearDown`: close boxes, delete temp dir

```dart
// Pattern: Hive in tests
late Directory tempDir;

setUp(() async {
  tempDir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(tempDir.path);
  repo = WatchHistoryRepository();
  await repo.init();
});

tearDown(() async {
  await repo.close();
  await Hive.close();
  tempDir.deleteSync(recursive: true);
});
```

### Providers (Riverpod)
- Use `ProviderContainer` with overrides for dependencies
- Override service/repo providers with mocks
- Test provider output given specific mock responses
- Test invalidation triggers re-fetch
- Dispose container in `tearDown`

```dart
// Pattern: Riverpod provider testing
final container = ProviderContainer(overrides: [
  tmdbServiceProvider.overrideWithValue(mockTmdb),
  userPreferencesProvider.overrideWith((_) async => testPrefs),
]);
addTearDown(container.dispose);

final result = await container.read(trendingProvider.future);
expect(result, isNotEmpty);
```

### Utilities
- Test pure functions with table-driven inputs
- Cover all branches (min-rating, age-rating, watched exclusion)
- Test empty input lists

### Widgets
- Use `pump()` instead of `pumpAndSettle()` for animated widgets (Shimmer, flutter_animate)
- Wrap in `MaterialApp` + `ProviderScope` with overrides
- Test user interactions: tap, long-press, scroll
- Verify text, icons, and widget tree structure
- Use unique IDs for testability: `Key('widget_name')`

---

## Rules
- **Never skip Red**: If you catch yourself writing production code first, stop and write the test
- **One behavior at a time**: Each Red-Green-Refactor cycle should test one specific behavior
- **Tests are documentation**: Test names should read like specifications (e.g., `should return empty list when user has no watch history`)
- **Mock external dependencies**: Use `mocktail` for services, repositories, and API clients
- **Use `pump()` for animated widgets**: Avoid `pumpAndSettle()` with Shimmer, flutter_animate, or other infinite animations
- **Coverage check after**: Run `flutter test --coverage` and verify new files are covered
- **No `print` in production**: Use `debugPrint` or logging framework if needed
