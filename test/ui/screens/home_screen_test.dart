import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_scout/ui/screens/home_screen.dart';
import 'package:stream_scout/data/repositories/tmdb_repository.dart';
import 'package:stream_scout/data/repositories/user_preferences_repository.dart';
import 'package:stream_scout/data/repositories/watch_history_repository.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/config/providers/curated_providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:stream_scout/domain/recommendation_engine.dart';
import '../../utils/test_app_wrapper.dart';

class MockTmdbRepository extends Mock implements ITmdbRepository {}

class MockPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

class MockWatchHistoryRepository extends Mock
    implements WatchHistoryRepository {}

void main() {
  late MockTmdbRepository mockTmdb;
  late MockPreferencesRepository mockPrefs;
  late MockWatchHistoryRepository mockWatchHistory;

  setUp(() {
    mockTmdb = MockTmdbRepository();
    mockPrefs = MockPreferencesRepository();
    mockWatchHistory = MockWatchHistoryRepository();

    final mockMedia = [
      Media(
        id: 1,
        title: 'Mock Movie',
        overview: 'Overview',
        posterPath: '/path.jpg',
        type: MediaType.movie,
        releaseDate: DateTime(2023),
        voteAverage: 8.0,
        voteCount: 1000,
        genreIds: [28, 12],
      ),
    ];

    when(
      () => mockTmdb.getTrending(
        type: any(named: 'type'),
        timeWindow: any(named: 'timeWindow'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => mockMedia);

    when(
      () => mockTmdb.getPopularMovies(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMedia);

    when(
      () => mockTmdb.getPopularTvSeries(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMedia);

    when(
      () => mockTmdb.getTopRatedMovies(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMedia);

    when(
      () => mockTmdb.getTopRatedTvSeries(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMedia);

    when(
      () => mockTmdb.getUpcomingMovies(page: any(named: 'page')),
    ).thenAnswer((_) async => mockMedia);

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
    ).thenAnswer((_) async => mockMedia);

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
    ).thenAnswer((_) async => mockMedia);

    when(() => mockPrefs.getPreferences()).thenAnswer(
      (_) async => const UserPreferences(
        countryCode: 'US',
        countryName: 'United States',
        subscribedServiceIds: [],
      ),
    );

    when(() => mockWatchHistory.getAllEntries()).thenAnswer((_) async => []);
  });

  group('HomeScreen Widget Tests', () {
    testWidgets('renders main sections when data is available', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const HomeScreen(),
          overrides: [
            tmdbRepositoryProvider.overrideWithValue(mockTmdb),
            userPreferencesRepositoryProvider.overrideWithValue(mockPrefs),
            watchHistoryRepositoryProvider.overrideWithValue(mockWatchHistory),

            // Bypass userPreferencesProvider future wrapper
            userPreferencesProvider.overrideWith(
              (ref) => Future.value(
                const UserPreferences(
                  countryCode: 'US',
                  countryName: 'United States',
                  subscribedServiceIds: [],
                ),
              ),
            ),

            // Empty dismissed media to prevent init cycle error
            dismissedMediaIdsProvider.overrideWith(
              (ref) => Future.value(<String>{}),
            ),

            // Because You Watched has complex logic, bypass it for basic layout test
            becauseYouWatchedProvider.overrideWith(
              (ref) => Future.value(<RecommendationGroup>[]),
            ),
            curatedCollectionProvider.overrideWith(
              (ref) => Future.value(<Media>[]),
            ),
          ],
        ),
      );

      // We use pump() with a duration instead of pumpAndSettle() because HomeScreen
      // has infinite animations (shimmer or hero carousel loops) that cause timeouts
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('StreamScout'), findsOneWidget);
    });
  });
}
