import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

import 'package:stream_scout/ui/screens/home_screen.dart';
import 'package:stream_scout/data/repositories/tmdb_repository.dart';
import 'package:stream_scout/data/repositories/user_preferences_repository.dart';
import 'package:stream_scout/data/repositories/watch_history_repository.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/config/providers/curated_providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:stream_scout/domain/recommendation_engine.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';

import '../../../utils/test_app_wrapper.dart';

class MockTmdbRepository extends Mock implements ITmdbRepository {}

class MockPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

class MockWatchHistoryRepository extends Mock
    implements WatchHistoryRepository {}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('HomeScreen - Light and Dark Themes', (tester) async {
    final mockTmdb = MockTmdbRepository();
    final mockPrefs = MockPreferencesRepository();
    final mockWatchHistory = MockWatchHistoryRepository();

    final mockMediaList = [
      Media(
        id: 1,
        title: 'Mock Movie 1',
        overview: 'Overview 1',
        posterPath: '', // Bypass network loading
        backdropPath: '',
        type: MediaType.movie,
        releaseDate: DateTime(2023),
        voteAverage: 8.5,
        voteCount: 1500,
        genreIds: [28, 12],
      ),
      Media(
        id: 2,
        title: 'Mock Movie 2',
        overview: 'Overview 2',
        posterPath: '', // Bypass network loading
        backdropPath: '',
        type: MediaType.movie,
        releaseDate: DateTime(2022),
        voteAverage: 7.5,
        voteCount: 800,
        genreIds: [35],
      ),
    ];

    when(
      () => mockTmdb.getTrending(
        type: any(named: 'type'),
        timeWindow: any(named: 'timeWindow'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => mockMediaList);
    when(
      () => mockTmdb.getPopularMovies(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMediaList);
    when(
      () => mockTmdb.getPopularTvSeries(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMediaList);
    when(
      () => mockTmdb.getTopRatedMovies(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMediaList);
    when(
      () => mockTmdb.getTopRatedTvSeries(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMediaList);
    when(
      () => mockTmdb.getUpcomingMovies(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMediaList);
    when(
      () => mockTmdb.getUpcomingTvSeries(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMediaList);
    when(
      () => mockTmdb.discoverMovies(
        genreIds: any(named: 'genreIds'),
        withProviders: any(named: 'withProviders'),
        watchRegion: any(named: 'watchRegion'),
        sortBy: any(named: 'sortBy'),
        minRating: any(named: 'minRating'),
        maxAgeRating: any(named: 'maxAgeRating'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => mockMediaList);
    when(
      () => mockTmdb.discoverTvSeries(
        genreIds: any(named: 'genreIds'),
        withProviders: any(named: 'withProviders'),
        watchRegion: any(named: 'watchRegion'),
        sortBy: any(named: 'sortBy'),
        minRating: any(named: 'minRating'),
        maxAgeRating: any(named: 'maxAgeRating'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => mockMediaList);
    when(() => mockPrefs.getPreferences()).thenAnswer(
      (_) async => const UserPreferences(
        countryCode: 'US',
        countryName: 'United States',
        subscribedServiceIds: [],
      ),
    );
    when(() => mockWatchHistory.getAllEntries()).thenAnswer((_) async => []);

    final overrides = [
      tmdbRepositoryProvider.overrideWithValue(mockTmdb),
      userPreferencesRepositoryProvider.overrideWithValue(mockPrefs),
      watchHistoryRepositoryProvider.overrideWithValue(mockWatchHistory),
      userPreferencesProvider.overrideWith(
        (ref) => Future.value(
          const UserPreferences(
            countryCode: 'US',
            countryName: 'United States',
            subscribedServiceIds: [],
          ),
        ),
      ),
      dismissedMediaIdsProvider.overrideWith((ref) => Future.value(<String>{})),
      becauseYouWatchedProvider.overrideWith(
        (ref) => Future.value(<RecommendationGroup>[]),
      ),
      curatedCollectionProvider.overrideWith((ref) => Future.value(<Media>[])),
    ];

    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [Device.phone, Device.iphone11])
      ..addScenario(
        widget: Theme(
          data: AppTheme.lightTheme,
          child: pumpAppScreen(child: const HomeScreen(), overrides: overrides),
        ),
        name: 'Light Theme',
      )
      ..addScenario(
        widget: Theme(
          data: AppTheme.darkTheme,
          child: pumpAppScreen(child: const HomeScreen(), overrides: overrides),
        ),
        name: 'Dark Theme',
      );

    await tester.pumpDeviceBuilder(builder);

    // Let the Futures resolve and animations settle
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    await screenMatchesGolden(tester, 'home_screen');
  });
}
