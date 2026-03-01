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

/// A fake TMDB repository that returns canned data.
class FakeTmdbRepository extends Fake implements ITmdbRepository {
  final List<Media> media;
  FakeTmdbRepository(this.media);

  @override
  Future<List<Media>> discoverMovies({
    List<int>? genreIds, List<int>? withoutGenreIds,
    GenreFilterMode genreMode = GenreFilterMode.and,
    double? minRating, int? year, List<int>? withProviders,
    String? watchRegion, int? maxAgeRating,
    String sortBy = 'popularity.desc', int page = 1, bool includeAdult = false,
  }) async => media;

  @override
  Future<List<Media>> discoverTvSeries({
    List<int>? genreIds, List<int>? withoutGenreIds,
    GenreFilterMode genreMode = GenreFilterMode.and,
    double? minRating, int? year, List<int>? withProviders,
    String? watchRegion, int? maxAgeRating,
    String sortBy = 'popularity.desc', int page = 1, bool includeAdult = false,
  }) async => media;

  @override
  Future<List<Media>> getUpcomingMovies({
    List<int>? withProviders, String? watchRegion, int? maxAgeRating,
    double? minRating, int page = 1, bool includeAdult = false,
  }) async => media;

  @override
  Future<List<Media>> getUpcomingTvSeries({
    List<int>? withProviders, String? watchRegion, int? maxAgeRating,
    double? minRating, int page = 1, bool includeAdult = false,
  }) async => media;

  @override
  Future<WatchProviderResult> getWatchProviders(
    int mediaId,
    MediaType type, {
    String region = 'DE',
  }) async =>
      WatchProviderResult.empty();
}

class MockPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

class MockWatchHistoryRepository extends Mock
    implements WatchHistoryRepository {}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('HomeScreen - Light and Dark Themes', (tester) async {
    final mockPrefs = MockPreferencesRepository();
    final mockWatchHistory = MockWatchHistoryRepository();

    final mockMediaList = [
      Media(
        id: 1,
        title: 'Mock Movie 1',
        overview: 'Overview 1',
        posterPath: '',
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
        posterPath: '',
        backdropPath: '',
        type: MediaType.movie,
        releaseDate: DateTime(2022),
        voteAverage: 7.5,
        voteCount: 800,
        genreIds: [35],
      ),
    ];

    final fakeTmdb = FakeTmdbRepository(mockMediaList);

    when(() => mockPrefs.getPreferences()).thenAnswer(
      (_) async => const UserPreferences(
        countryCode: 'US',
        countryName: 'United States',
        subscribedServiceIds: [],
      ),
    );
    when(() => mockWatchHistory.getAllEntries()).thenAnswer((_) async => []);

    final overrides = [
      tmdbRepositoryProvider.overrideWithValue(fakeTmdb),
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

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    await screenMatchesGolden(tester, 'home_screen');
  });
}
