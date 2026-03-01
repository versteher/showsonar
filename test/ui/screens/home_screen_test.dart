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
import 'package:stream_scout/ui/widgets/error_retry_widget.dart';
import '../../utils/test_app_wrapper.dart';

class MockPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

class MockWatchHistoryRepository extends Mock
    implements WatchHistoryRepository {}

/// A fake TMDB repository that returns canned data or throws.
/// Avoids mocktail matcher issues with many named params.
class FakeTmdbRepository extends Fake implements ITmdbRepository {
  final List<Media> Function()? _discoverResult;
  final List<Media> Function()? _upcomingResult;

  FakeTmdbRepository({
    List<Media> Function()? discoverResult,
    List<Media> Function()? upcomingResult,
  }) : _discoverResult = discoverResult,
       _upcomingResult = upcomingResult;

  List<Media> _defaultResult() => [];

  @override
  Future<List<Media>> discoverMovies({
    List<int>? genreIds,
    List<int>? withoutGenreIds,
    GenreFilterMode genreMode = GenreFilterMode.and,
    double? minRating,
    int? year,
    List<int>? withProviders,
    List<int>? withKeywords,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  }) async => (_discoverResult ?? _defaultResult)();

  @override
  Future<List<Media>> discoverTvSeries({
    List<int>? genreIds,
    List<int>? withoutGenreIds,
    GenreFilterMode genreMode = GenreFilterMode.and,
    double? minRating,
    int? year,
    List<int>? withProviders,
    List<int>? withKeywords,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  }) async => (_discoverResult ?? _defaultResult)();

  @override
  Future<List<Media>> getUpcomingMovies({
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  }) async => (_upcomingResult ?? _discoverResult ?? _defaultResult)();

  @override
  Future<List<Media>> getUpcomingTvSeries({
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  }) async => (_upcomingResult ?? _discoverResult ?? _defaultResult)();

  @override
  Future<WatchProviderResult> getWatchProviders(
    int mediaId,
    MediaType type, {
    String region = 'DE',
  }) async => WatchProviderResult.empty();

  @override
  Future<List<Media>> getList(int listId) async => [];
}

void main() {
  late MockPreferencesRepository mockPrefs;
  late MockWatchHistoryRepository mockWatchHistory;

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

  setUp(() {
    mockPrefs = MockPreferencesRepository();
    mockWatchHistory = MockWatchHistoryRepository();

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
      final fakeTmdb = FakeTmdbRepository(discoverResult: () => mockMedia);

      await tester.pumpWidget(
        pumpAppScreen(
          child: const HomeScreen(),
          overrides: [
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
            dismissedMediaIdsProvider.overrideWith(
              (ref) => Future.value(<String>{}),
            ),
            becauseYouWatchedProvider.overrideWith(
              (ref) => Future.value(<RecommendationGroup>[]),
            ),
            curatedCollectionProvider.overrideWith(
              (ref) => Future.value(<Media>[]),
            ),
          ],
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('ShowSonar'), findsOneWidget);
    });

    testWidgets('renders error states when data fetching fails', (
      tester,
    ) async {
      final fakeTmdb = FakeTmdbRepository(
        discoverResult: () => throw Exception('Failed to fetch from TMDB'),
        upcomingResult: () => throw Exception('Failed to fetch from TMDB'),
      );

      const errorPrefs = UserPreferences(
        countryCode: 'US',
        countryName: 'United States',
        subscribedServiceIds: ['netflix'],
      );

      await tester.pumpWidget(
        pumpAppScreen(
          child: const HomeScreen(),
          overrides: [
            tmdbRepositoryProvider.overrideWithValue(fakeTmdb),
            userPreferencesRepositoryProvider.overrideWithValue(mockPrefs),
            watchHistoryRepositoryProvider.overrideWithValue(mockWatchHistory),
            userPreferencesProvider.overrideWith(
              (ref) => Future.value(errorPrefs),
            ),
            dismissedMediaIdsProvider.overrideWith(
              (ref) => Future.value(<String>{}),
            ),
            becauseYouWatchedProvider.overrideWith(
              (ref) => Future.value(<RecommendationGroup>[]),
            ),
            curatedCollectionProvider.overrideWith(
              (ref) => Future.value(<Media>[]),
            ),
          ],
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));

      // ErrorRetryWidget should be present at least once
      expect(find.byType(ErrorRetryWidget), findsWidgets);
    });
  });
}
