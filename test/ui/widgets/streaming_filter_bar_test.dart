import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/models/streaming_provider.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';
import 'package:neon_voyager/data/repositories/user_preferences_repository.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/ui/widgets/streaming_filter_bar.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';

void main() {
  // Disable flutter_animate delays to avoid FakeAsync timer issues.
  // flutter_animate's _restart() uses Future.delayed(widget.delay, _play).
  // Setting defaultDuration to zero won't help because the timer comes from
  // the Animate delay (not effect duration), but we can work around it with
  // explicit pumps.

  // Helper to wrap StreamingFilterBar with overridden providers (no Hive needed)
  Widget buildWidget({
    required UserPreferences prefs,
    Function(List<String>)? onFilterChanged,
  }) {
    return ProviderScope(
      overrides: [
        userPreferencesProvider.overrideWith((_) async => prefs),
        userPreferencesRepositoryProvider.overrideWithValue(
          _FakePrefsRepo(prefs),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(
          body: StreamingFilterBar(onFilterChanged: onFilterChanged),
        ),
      ),
    );
  }

  /// Pumps the widget, fires zero-duration timers, then advances enough
  /// for all flutter_animate animations to complete.
  Future<void> pumpWidget(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    // Fire the zero-duration Future.delayed timer from _AnimateState._restart
    await tester.pump();
    // Advance past all animations (300ms fadeIn + buffer)
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Disposes the animate widget tree cleanly so FakeAsync has no pending timers.
  Future<void> disposeAnimations(WidgetTester tester) async {
    // Replace widget tree to trigger dispose
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    // Flush any zero-duration timers created during dispose/rebuild
    await tester.pump();
    await tester.pump();
  }

  group('StreamingFilterBar', () {
    testWidgets('renders header with title text', (tester) async {
      await pumpWidget(tester, buildWidget(prefs: UserPreferences.defaultDE()));

      expect(find.text('Streaming-Dienste'), findsOneWidget);

      await disposeAnimations(tester);
    });

    testWidgets('renders streaming provider chips in scrollable list', (
      tester,
    ) async {
      await pumpWidget(tester, buildWidget(prefs: UserPreferences.defaultDE()));

      // ListView only renders visible items — check first few commercial providers
      // which are rendered first and visible in the viewport
      final firstProviders = StreamingProvider.commercialProviders.take(3);
      for (final provider in firstProviders) {
        expect(
          find.text(provider.name),
          findsOneWidget,
          reason: '${provider.name} chip should be visible',
        );
      }

      // Verify the ListView itself is present
      expect(find.byType(ListView), findsOneWidget);

      await disposeAnimations(tester);
    });

    testWidgets('default DE prefs shows count badge of 4', (tester) async {
      await pumpWidget(tester, buildWidget(prefs: UserPreferences.defaultDE()));

      expect(find.text('4'), findsOneWidget);

      await disposeAnimations(tester);
    });

    testWidgets('empty services → no count badge', (tester) async {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: [],
      );
      await pumpWidget(tester, buildWidget(prefs: prefs));

      expect(find.text('0'), findsNothing);

      await disposeAnimations(tester);
    });

    testWidgets('ARD-only shows count badge of 1', (tester) async {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['ard_mediathek'],
      );
      await pumpWidget(tester, buildWidget(prefs: prefs));

      expect(find.text('1'), findsOneWidget);

      await disposeAnimations(tester);
    });

    testWidgets('selected chip shows check icon', (tester) async {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['netflix'],
      );
      await pumpWidget(tester, buildWidget(prefs: prefs));

      expect(find.byIcon(Icons.check), findsAtLeastNWidgets(1));

      await disposeAnimations(tester);
    });

    testWidgets('unselected chip shows initial letter instead of check', (
      tester,
    ) async {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['netflix'],
      );
      await pumpWidget(tester, buildWidget(prefs: prefs));

      expect(find.text('Disney+'), findsOneWidget);
      expect(find.text('D'), findsAtLeastNWidgets(1));

      await disposeAnimations(tester);
    });

    testWidgets('tapping chip triggers onFilterChanged callback', (
      tester,
    ) async {
      List<String>? capturedServices;

      await pumpWidget(
        tester,
        buildWidget(
          prefs: UserPreferences.defaultDE(),
          onFilterChanged: (services) {
            capturedServices = services;
          },
        ),
      );

      await tester.tap(find.text('Netflix'));
      // Pump to process the tap + any new animations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(capturedServices, isNotNull);
      expect(capturedServices, isNot(contains('netflix')));
      expect(capturedServices!.length, 3);

      await disposeAnimations(tester);
    });
  });
}

/// Fake prefs repo that holds preferences in memory (no Hive)
class _FakePrefsRepo implements UserPreferencesRepository {
  UserPreferences _prefs;

  _FakePrefsRepo(this._prefs);

  @override
  String get userId => 'fake_user';

  @override
  String? get profileId => null;

  @override
  Future<void> init() async {}

  @override
  Future<bool> hasPreferences() async => true;

  @override
  Future<UserPreferences> getPreferences() async => _prefs;

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    _prefs = prefs;
  }

  @override
  Future<void> addStreamingService(String serviceId) async {
    if (_prefs.subscribedServiceIds.contains(serviceId)) return;
    _prefs = _prefs.copyWith(
      subscribedServiceIds: [..._prefs.subscribedServiceIds, serviceId],
    );
  }

  @override
  Future<void> removeStreamingService(String serviceId) async {
    _prefs = _prefs.copyWith(
      subscribedServiceIds: _prefs.subscribedServiceIds
          .where((id) => id != serviceId)
          .toList(),
    );
  }

  @override
  Future<void> updateCountry(String countryCode, String countryName) async {
    _prefs = _prefs.copyWith(
      countryCode: countryCode,
      countryName: countryName,
    );
  }

  @override
  Future<void> updateMinimumRating(double rating) async {
    _prefs = _prefs.copyWith(minimumRating: rating);
  }

  @override
  Future<void> updateMaxAgeRating(int? rating) async {
    _prefs = _prefs.copyWith(maxAgeRating: rating ?? _prefs.maxAgeRating);
  }

  @override
  Future<void> updateIncludeAdult(bool includeAdult) async {
    _prefs = _prefs.copyWith(includeAdult: includeAdult);
  }

  @override
  Future<void> addFavoriteGenre(int genreId) async {
    if (_prefs.favoriteGenreIds.contains(genreId)) return;
    _prefs = _prefs.copyWith(
      favoriteGenreIds: [..._prefs.favoriteGenreIds, genreId],
    );
  }

  @override
  Future<void> removeFavoriteGenre(int genreId) async {
    _prefs = _prefs.copyWith(
      favoriteGenreIds: _prefs.favoriteGenreIds
          .where((id) => id != genreId)
          .toList(),
    );
  }

  @override
  Future<void> resetToDefaults() async {
    _prefs = UserPreferences.defaultDE();
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> updateThemeMode(String themeMode) async {}

  @override
  Future<void> close() async {}
}
