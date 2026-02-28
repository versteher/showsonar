import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stream_scout/config/providers/year_in_review_provider.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/watch_history_entry.dart';

import '../../utils/test_provider_container.dart';

void main() {
  late MockDependencies mocks;
  late ProviderContainer container;

  final baseTime = DateTime(2025, 6, 15);

  setUp(() {
    mocks = MockDependencies();
    container = mocks.createContainer();
    when(() => mocks.watchHistoryRepository.init()).thenAnswer((_) async {});
  });

  tearDown(() {
    container.dispose();
  });

  // ============================================================================
  // YearInReviewData.fromEntries
  // ============================================================================

  group('YearInReviewData.fromEntries', () {
    test('empty history → hasEnoughData is false', () {
      final data = YearInReviewData.fromEntries([], 2025);
      expect(data.hasEnoughData, isFalse);
      expect(data.totalTitlesWatched, 0);
      expect(data.totalHoursWatched, 0);
    });

    test('fewer than 3 titles → hasEnoughData is false', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Film A',
          watchedAt: baseTime,
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'Film B',
          watchedAt: baseTime,
        ),
      ];
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.hasEnoughData, isFalse);
    });

    test('3 or more titles → hasEnoughData is true', () {
      final entries = List.generate(
        3,
        (i) => WatchHistoryEntry(
          mediaId: i,
          mediaType: MediaType.movie,
          title: 'Film $i',
          watchedAt: baseTime,
        ),
      );
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.hasEnoughData, isTrue);
    });

    test('only entries from the selected year are counted', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Old',
          watchedAt: DateTime(2024, 3, 1), // different year
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'Current',
          watchedAt: DateTime(2025, 5, 1),
        ),
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.movie,
          title: 'Current 2',
          watchedAt: DateTime(2025, 7, 1),
        ),
        WatchHistoryEntry(
          mediaId: 4,
          mediaType: MediaType.movie,
          title: 'Current 3',
          watchedAt: DateTime(2025, 9, 1),
        ),
      ];
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.totalTitlesWatched, 3);
    });

    test('totalHoursWatched uses runtime field when present', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Long Movie',
          watchedAt: baseTime,
          runtime: 120, // 2 hours
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'Short Movie',
          watchedAt: baseTime,
          runtime: 60, // 1 hour
        ),
      ];
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.totalHoursWatched, 3); // 180 min / 60
    });

    test(
      'totalHoursWatched defaults to 100 min for movies without runtime',
      () {
        final entries = [
          WatchHistoryEntry(
            mediaId: 1,
            mediaType: MediaType.movie,
            title: 'No Runtime',
            watchedAt: baseTime,
            // no runtime set
          ),
        ];
        final data = YearInReviewData.fromEntries(entries, 2025);
        // 100 min default / 60 = 1 hour
        expect(data.totalHoursWatched, 1);
      },
    );

    test('topRated is sorted descending by userRating', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Good',
          watchedAt: baseTime,
          userRating: 6.0,
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'Best',
          watchedAt: baseTime,
          userRating: 9.5,
        ),
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.movie,
          title: 'OK',
          watchedAt: baseTime,
          userRating: 7.0,
        ),
      ];
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.topRated.first.title, 'Best');
      expect(data.topRated.last.title, 'Good');
    });

    test('topRated has at most 5 entries', () {
      final entries = List.generate(
        10,
        (i) => WatchHistoryEntry(
          mediaId: i,
          mediaType: MediaType.movie,
          title: 'Film $i',
          watchedAt: baseTime,
          userRating: i.toDouble(),
        ),
      );
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.topRated.length, 5);
    });

    test('genreFrequency aggregates correctly across entries', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Action A',
          watchedAt: baseTime,
          genreIds: [28],
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'Action B',
          watchedAt: baseTime,
          genreIds: [28, 18],
        ),
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.movie,
          title: 'Drama',
          watchedAt: baseTime,
          genreIds: [18],
        ),
      ];
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.topGenres.first.key, 28); // Action most frequent (2×)
      expect(data.topGenres.first.value, 2);
      expect(data.topGenres[1].key, 18); // Drama second (2×)
    });

    test('topGenres has at most 5 entries', () {
      // Create an entry with 7 genres
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Multi-Genre',
          watchedAt: baseTime,
          genreIds: [28, 12, 16, 35, 80, 99, 18],
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'Multi-Genre 2',
          watchedAt: baseTime,
          genreIds: [28, 12, 16, 35, 80, 99, 18],
        ),
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.movie,
          title: 'Multi-Genre 3',
          watchedAt: baseTime,
          genreIds: [28, 12, 16, 35, 80, 99, 18],
        ),
      ];
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.topGenres.length, lessThanOrEqualTo(5));
    });

    test('averageUserRating is computed correctly', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'A',
          watchedAt: baseTime,
          userRating: 8.0,
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'B',
          watchedAt: baseTime,
          userRating: 6.0,
        ),
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.movie,
          title: 'C',
          watchedAt: baseTime,
          // no rating
        ),
      ];
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.averageUserRating, 7.0);
      expect(data.ratedCount, 2);
    });

    test('averageUserRating is 0.0 when no entries are rated', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Unrated',
          watchedAt: baseTime,
        ),
      ];
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.averageUserRating, 0.0);
      expect(data.ratedCount, 0);
    });

    test('totalMovies and totalSeries counted correctly', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'M1',
          watchedAt: baseTime,
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'M2',
          watchedAt: baseTime,
        ),
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.tv,
          title: 'S1',
          watchedAt: baseTime,
        ),
      ];
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.totalMovies, 2);
      expect(data.totalSeries, 1);
    });

    test('topGenreName returns genre name for top genre', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Action Film',
          watchedAt: baseTime,
          genreIds: [28], // Action
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'Another',
          watchedAt: baseTime,
          genreIds: [28],
        ),
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.movie,
          title: 'Third',
          watchedAt: baseTime,
          genreIds: [28],
        ),
      ];
      final data = YearInReviewData.fromEntries(entries, 2025);
      expect(data.topGenreName, 'Action');
    });
  });

  // ============================================================================
  // yearInReviewProvider
  // ============================================================================

  group('yearInReviewProvider', () {
    test('returns data for the correct year via provider', () async {
      final entries = List.generate(
        5,
        (i) => WatchHistoryEntry(
          mediaId: i,
          mediaType: MediaType.movie,
          title: 'Film $i',
          watchedAt: DateTime(2025, i + 1, 1),
        ),
      );
      when(
        () => mocks.watchHistoryRepository.getAllEntries(),
      ).thenAnswer((_) async => entries);

      final data = await container.read(yearInReviewProvider(2025).future);
      expect(data.year, 2025);
      expect(data.totalTitlesWatched, 5);
    });

    test('filters out entries from other years', () async {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Old',
          watchedAt: DateTime(2024, 1, 1),
        ),
        ...List.generate(
          3,
          (i) => WatchHistoryEntry(
            mediaId: i + 10,
            mediaType: MediaType.movie,
            title: 'Current $i',
            watchedAt: DateTime(2025, i + 1, 1),
          ),
        ),
      ];
      when(
        () => mocks.watchHistoryRepository.getAllEntries(),
      ).thenAnswer((_) async => entries);

      final data = await container.read(yearInReviewProvider(2025).future);
      expect(data.totalTitlesWatched, 3);
    });
  });

  // ============================================================================
  // reviewableYearsProvider
  // ============================================================================

  group('reviewableYearsProvider', () {
    test('returns distinct years sorted descending', () async {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Old',
          watchedAt: DateTime(2023, 1, 1),
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'Mid',
          watchedAt: DateTime(2024, 1, 1),
        ),
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.movie,
          title: 'New',
          watchedAt: DateTime(2025, 1, 1),
        ),
        // Duplicate year
        WatchHistoryEntry(
          mediaId: 4,
          mediaType: MediaType.movie,
          title: 'New 2',
          watchedAt: DateTime(2025, 6, 1),
        ),
      ];
      when(
        () => mocks.watchHistoryRepository.getAllEntries(),
      ).thenAnswer((_) async => entries);

      final years = await container.read(reviewableYearsProvider.future);
      expect(years, [2025, 2024, 2023]);
    });

    test('returns empty list when no history', () async {
      when(
        () => mocks.watchHistoryRepository.getAllEntries(),
      ).thenAnswer((_) async => []);

      final years = await container.read(reviewableYearsProvider.future);
      expect(years, isEmpty);
    });
  });
}
