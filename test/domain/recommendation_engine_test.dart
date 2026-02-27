import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';
import 'package:neon_voyager/data/models/watch_history_entry.dart';
import 'package:neon_voyager/data/repositories/tmdb_repository.dart';
import 'package:neon_voyager/data/repositories/watch_history_repository.dart';
import 'package:neon_voyager/domain/recommendation_engine.dart';

class MockITmdbRepository extends Mock implements ITmdbRepository {}

class MockWatchHistoryRepository extends Mock
    implements WatchHistoryRepository {}

void main() {
  late MockITmdbRepository mockTmdb;
  late MockWatchHistoryRepository mockWatchHistory;
  late UserPreferences prefs;
  late RecommendationEngine engine;

  setUp(() {
    mockTmdb = MockITmdbRepository();
    mockWatchHistory = MockWatchHistoryRepository();
    prefs = UserPreferences.defaultDE();
    engine = RecommendationEngine(
      tmdbRepository: mockTmdb,
      watchHistoryRepo: mockWatchHistory,
      preferences: prefs,
    );
  });

  final testMedia = Media(
    id: 550,
    title: 'Fight Club',
    overview: 'Test',
    voteAverage: 8.0,
    voteCount: 1000,
    genreIds: [18],
    type: MediaType.movie,
  );

  final lowVoteCountMedia = Media(
    id: 999,
    title: 'Obscure Film',
    overview: 'Test',
    voteAverage: 9.0,
    voteCount: 50, // below threshold
    genreIds: [18],
    type: MediaType.movie,
  );

  final lowRatedMedia = Media(
    id: 888,
    title: 'Bad Film',
    overview: 'Test',
    voteAverage: 3.0,
    voteCount: 1000,
    genreIds: [18],
    type: MediaType.movie,
  );

  group('RecommendationEngine', () {
    group('getPersonalizedRecommendations', () {
      test('returns trending when watch history is empty', () async {
        when(
          () => mockWatchHistory.getAllEntries(),
        ).thenAnswer((_) async => <WatchHistoryEntry>[]);
        when(() => mockTmdb.getTrending()).thenAnswer((_) async => [testMedia]);

        final results = await engine.getPersonalizedRecommendations();

        expect(results, isNotEmpty);
        verify(() => mockTmdb.getTrending()).called(1);
      });

      test('returns empty list when trending fails and no history', () async {
        when(
          () => mockWatchHistory.getAllEntries(),
        ).thenAnswer((_) async => <WatchHistoryEntry>[]);
        when(
          () => mockTmdb.getTrending(),
        ).thenThrow(Exception('Network error'));

        final results = await engine.getPersonalizedRecommendations();

        expect(results, isEmpty);
      });

      test('fetches recommendations from highly rated entries', () async {
        final historyEntry = WatchHistoryEntry(
          mediaId: 550,
          mediaType: MediaType.movie,
          title: 'Fight Club',
          watchedAt: DateTime(2024, 1, 1),
          userRating: 9.0,
        );

        when(
          () => mockWatchHistory.getAllEntries(),
        ).thenAnswer((_) async => <WatchHistoryEntry>[historyEntry]);
        when(
          () => mockTmdb.getRecommendations(550, MediaType.movie),
        ).thenAnswer((_) async => [testMedia.copyWith(id: 551)]);
        // For genre-based recs fallback:
        when(
          () => mockTmdb.discoverMovies(
            genreIds: any(named: 'genreIds'),
            minRating: any(named: 'minRating'),
          ),
        ).thenAnswer((_) async => []);
        when(
          () => mockTmdb.discoverTvSeries(
            genreIds: any(named: 'genreIds'),
            minRating: any(named: 'minRating'),
          ),
        ).thenAnswer((_) async => []);

        final results = await engine.getPersonalizedRecommendations();

        verify(
          () => mockTmdb.getRecommendations(550, MediaType.movie),
        ).called(1);
        expect(results.isNotEmpty, isTrue);
      });

      test('filters out already watched items', () async {
        final historyEntry = WatchHistoryEntry(
          mediaId: 550,
          mediaType: MediaType.movie,
          title: 'Fight Club',
          watchedAt: DateTime(2024, 1, 1),
          userRating: 9.0,
        );

        // Recommendation is the same as a watched item
        when(
          () => mockWatchHistory.getAllEntries(),
        ).thenAnswer((_) async => <WatchHistoryEntry>[historyEntry]);
        when(
          () => mockTmdb.getRecommendations(550, MediaType.movie),
        ).thenAnswer((_) async => [testMedia]); // same id=550
        when(
          () => mockTmdb.discoverMovies(
            genreIds: any(named: 'genreIds'),
            minRating: any(named: 'minRating'),
          ),
        ).thenAnswer((_) async => []);
        when(
          () => mockTmdb.discoverTvSeries(
            genreIds: any(named: 'genreIds'),
            minRating: any(named: 'minRating'),
          ),
        ).thenAnswer((_) async => []);

        final results = await engine.getPersonalizedRecommendations();

        // The watched item should be filtered out
        expect(results.where((m) => m.id == 550), isEmpty);
      });

      test('filters out low vote count media', () async {
        when(
          () => mockWatchHistory.getAllEntries(),
        ).thenAnswer((_) async => <WatchHistoryEntry>[]);
        when(
          () => mockTmdb.getTrending(),
        ).thenAnswer((_) async => [lowVoteCountMedia]);

        final results = await engine.getPersonalizedRecommendations();

        expect(results, isEmpty);
      });

      test('filters out media below minimum rating', () async {
        final strictPrefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: ['netflix'],
          minimumRating: 7.0,
        );
        final strictEngine = RecommendationEngine(
          tmdbRepository: mockTmdb,
          watchHistoryRepo: mockWatchHistory,
          preferences: strictPrefs,
        );

        when(
          () => mockWatchHistory.getAllEntries(),
        ).thenAnswer((_) async => <WatchHistoryEntry>[]);
        when(
          () => mockTmdb.getTrending(),
        ).thenAnswer((_) async => [lowRatedMedia]);

        final results = await strictEngine.getPersonalizedRecommendations();

        expect(results, isEmpty);
      });
    });

    group('getBecauseYouWatched', () {
      test('returns empty when no qualifying entries', () async {
        when(
          () => mockWatchHistory.getAllEntries(),
        ).thenAnswer((_) async => <WatchHistoryEntry>[]);

        final groups = await engine.getBecauseYouWatched();

        expect(groups, isEmpty);
      });

      test('returns groups for highly rated entries', () async {
        final entry = WatchHistoryEntry(
          mediaId: 550,
          mediaType: MediaType.movie,
          title: 'Fight Club',
          watchedAt: DateTime(2024, 1, 1),
          userRating: 8.0,
        );

        when(
          () => mockWatchHistory.getAllEntries(),
        ).thenAnswer((_) async => <WatchHistoryEntry>[entry]);
        when(
          () => mockTmdb.getRecommendations(550, MediaType.movie),
        ).thenAnswer((_) async => [testMedia.copyWith(id: 551)]);

        final groups = await engine.getBecauseYouWatched();

        expect(groups.length, 1);
        expect(groups.first.title, contains('Fight Club'));
        expect(groups.first.reason, RecommendationReason.becauseYouWatched);
      });

      test('skips entries rated below 7.0', () async {
        final lowRatedEntry = WatchHistoryEntry(
          mediaId: 550,
          mediaType: MediaType.movie,
          title: 'Meh Film',
          watchedAt: DateTime(2024, 1, 1),
          userRating: 5.0,
        );

        when(
          () => mockWatchHistory.getAllEntries(),
        ).thenAnswer((_) async => <WatchHistoryEntry>[lowRatedEntry]);

        final groups = await engine.getBecauseYouWatched();

        expect(groups, isEmpty);
      });
    });

    group('getByGenre', () {
      test('uses default genres when no history', () async {
        when(
          () => mockWatchHistory.getAllEntries(),
        ).thenAnswer((_) async => <WatchHistoryEntry>[]);
        when(
          () => mockTmdb.discoverMovies(
            genreIds: any(named: 'genreIds'),
            minRating: any(named: 'minRating'),
          ),
        ).thenAnswer((_) async => [testMedia]);

        final groups = await engine.getByGenre();

        expect(groups, isNotEmpty);
      });
    });

    group('getTopRated', () {
      test('returns movies only when type is movie', () async {
        when(
          () => mockTmdb.getTopRatedMovies(),
        ).thenAnswer((_) async => [testMedia]);

        final group = await engine.getTopRated(type: MediaType.movie);

        expect(group.title, 'Top bewertete Filme');
        expect(group.reason, RecommendationReason.topRated);
        verify(() => mockTmdb.getTopRatedMovies()).called(1);
      });

      test('returns TV only when type is tv', () async {
        when(
          () => mockTmdb.getTopRatedTvSeries(),
        ).thenAnswer((_) async => [testMedia.copyWith(type: MediaType.tv)]);

        final group = await engine.getTopRated(type: MediaType.tv);

        expect(group.title, 'Top bewertete Serien');
        verify(() => mockTmdb.getTopRatedTvSeries()).called(1);
      });

      test('returns both when no type specified', () async {
        when(
          () => mockTmdb.getTopRatedMovies(),
        ).thenAnswer((_) async => [testMedia]);
        when(() => mockTmdb.getTopRatedTvSeries()).thenAnswer(
          (_) async => [testMedia.copyWith(id: 2, type: MediaType.tv)],
        );

        final group = await engine.getTopRated();

        expect(group.title, 'Top bewertet');
      });

      test('returns empty group on error', () async {
        when(() => mockTmdb.getTopRatedMovies()).thenThrow(Exception('fail'));

        final group = await engine.getTopRated(type: MediaType.movie);

        expect(group.items, isEmpty);
      });
    });

    group('getTrending', () {
      test('returns trending group', () async {
        when(() => mockTmdb.getTrending()).thenAnswer((_) async => [testMedia]);

        final group = await engine.getTrending();

        expect(group.title, 'Gerade im Trend');
        expect(group.reason, RecommendationReason.trending);
        expect(group.items, isNotEmpty);
      });

      test('returns empty group on error', () async {
        when(() => mockTmdb.getTrending()).thenThrow(Exception('fail'));

        final group = await engine.getTrending();

        expect(group.items, isEmpty);
        expect(group.title, 'Gerade im Trend');
      });
    });
  });

  group('RecommendationGroup', () {
    test('isEmpty returns true for empty items', () {
      const group = RecommendationGroup(
        title: 'Test',
        reason: RecommendationReason.trending,
        items: [],
      );
      expect(group.isEmpty, isTrue);
      expect(group.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true for non-empty items', () {
      final group = RecommendationGroup(
        title: 'Test',
        reason: RecommendationReason.genre,
        items: [testMedia],
      );
      expect(group.isNotEmpty, isTrue);
      expect(group.isEmpty, isFalse);
    });

    test('sourceMediaId can be set', () {
      const group = RecommendationGroup(
        title: 'Test',
        reason: RecommendationReason.becauseYouWatched,
        sourceMediaId: 550,
        items: [],
      );
      expect(group.sourceMediaId, 550);
    });
  });

  group('RecommendationReason', () {
    test('has all expected values', () {
      expect(
        RecommendationReason.values,
        containsAll([
          RecommendationReason.becauseYouWatched,
          RecommendationReason.genre,
          RecommendationReason.topRated,
          RecommendationReason.trending,
          RecommendationReason.popular,
          RecommendationReason.similar,
        ]),
      );
    });
  });
}
