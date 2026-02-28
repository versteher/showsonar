import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/watch_history_entry.dart';
import 'package:stream_scout/config/providers.dart';

void main() {
  group('WatchHistoryStats', () {
    test('fromEntries with empty list', () {
      final stats = WatchHistoryStats.fromEntries([]);
      expect(stats.totalCount, 0);
      expect(stats.movieCount, 0);
      expect(stats.seriesCount, 0);
      expect(stats.ratedCount, 0);
      expect(stats.averageRating, 0.0);
      expect(stats.genreFrequency, isEmpty);
    });

    test('fromEntries computes counts correctly', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Movie 1',
          watchedAt: DateTime(2024, 1, 1),
          userRating: 8.0,
          genreIds: [28, 18],
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'Movie 2',
          watchedAt: DateTime(2024, 1, 2),
          userRating: 6.0,
          genreIds: [28],
        ),
        WatchHistoryEntry(
          mediaId: 10,
          mediaType: MediaType.tv,
          title: 'TV Show',
          watchedAt: DateTime(2024, 1, 3),
          genreIds: [18],
        ),
      ];

      final stats = WatchHistoryStats.fromEntries(entries);
      expect(stats.totalCount, 3);
      expect(stats.movieCount, 2);
      expect(stats.seriesCount, 1);
      expect(stats.ratedCount, 2);
      expect(stats.averageRating, 7.0); // (8 + 6) / 2
    });

    test('genreFrequency counts correctly', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'A',
          watchedAt: DateTime(2024, 1, 1),
          genreIds: [28, 18],
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'B',
          watchedAt: DateTime(2024, 1, 2),
          genreIds: [28, 35],
        ),
      ];

      final stats = WatchHistoryStats.fromEntries(entries);
      expect(stats.genreFrequency[28], 2); // Action appears twice
      expect(stats.genreFrequency[18], 1); // Drama once
      expect(stats.genreFrequency[35], 1); // Comedy once
    });

    test('topGenres returns top 5 sorted by frequency', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'A',
          watchedAt: DateTime(2024, 1, 1),
          genreIds: [28, 18, 35, 878, 12, 27],
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'B',
          watchedAt: DateTime(2024, 1, 2),
          genreIds: [28, 18, 35],
        ),
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.movie,
          title: 'C',
          watchedAt: DateTime(2024, 1, 3),
          genreIds: [28],
        ),
      ];

      final stats = WatchHistoryStats.fromEntries(entries);
      final topGenres = stats.topGenres;

      expect(topGenres.length, 5);
      expect(topGenres.first, 28); // Action: 3 times
    });

    test('topGenres returns fewer than 5 if not enough genres', () {
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'A',
          watchedAt: DateTime(2024, 1, 1),
          genreIds: [28],
        ),
      ];

      final stats = WatchHistoryStats.fromEntries(entries);
      expect(stats.topGenres.length, 1);
      expect(stats.topGenres, [28]);
    });
  });

  group('WeeklyRecap', () {
    test('fromEntries with empty list', () {
      final recap = WeeklyRecap.fromEntries([]);
      expect(recap.watchedThisWeek, 0);
      expect(recap.estimatedHours, 0.0);
      expect(recap.averageRating, 0.0);
      expect(recap.topGenreName, isNull);
      expect(recap.streakDays, 0);
    });

    test('fromEntries counts this week entries', () {
      final now = DateTime.now();
      final entries = [
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Recent Movie',
          watchedAt: now.subtract(const Duration(hours: 12)),
          userRating: 8.0,
          genreIds: [28],
        ),
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.tv,
          title: 'Recent Show',
          watchedAt: now.subtract(const Duration(days: 2)),
          userRating: 7.0,
          genreIds: [18],
        ),
        // Old entry, should not be counted this week
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.movie,
          title: 'Old Movie',
          watchedAt: now.subtract(const Duration(days: 30)),
          genreIds: [35],
        ),
      ];

      final recap = WeeklyRecap.fromEntries(entries);
      expect(recap.watchedThisWeek, 2);
      expect(recap.estimatedHours, 2.75); // 2.0 (movie) + 0.75 (tv)
      expect(recap.averageRating, 7.5); // (8 + 7) / 2
      expect(recap.topGenreName, isNotNull);
    });

    test('streak counts consecutive days from today', () {
      final now = DateTime.now();
      final entries = [
        // Today
        WatchHistoryEntry(
          mediaId: 1,
          mediaType: MediaType.movie,
          title: 'Today',
          watchedAt: now.subtract(const Duration(hours: 1)),
        ),
        // Yesterday
        WatchHistoryEntry(
          mediaId: 2,
          mediaType: MediaType.movie,
          title: 'Yesterday',
          watchedAt: now.subtract(const Duration(days: 1, hours: 2)),
        ),
        // Day before yesterday
        WatchHistoryEntry(
          mediaId: 3,
          mediaType: MediaType.movie,
          title: 'DayBefore',
          watchedAt: now.subtract(const Duration(days: 2, hours: 3)),
        ),
        // Gap: day 3 has nothing
        // Day 4
        WatchHistoryEntry(
          mediaId: 4,
          mediaType: MediaType.movie,
          title: 'OldDay',
          watchedAt: now.subtract(const Duration(days: 4, hours: 2)),
        ),
      ];

      final recap = WeeklyRecap.fromEntries(entries);
      expect(recap.streakDays, 3); // today + yesterday + day before
    });
  });

  group('DiscoveryMood', () {
    test('has all expected values', () {
      expect(DiscoveryMood.values.length, 6);
    });

    test('each mood has emoji, label, and genreIds', () {
      for (final mood in DiscoveryMood.values) {
        expect(mood.emoji, isNotEmpty);
        expect(mood.label, isNotEmpty);
        expect(mood.genreIds, isNotEmpty);
      }
    });

    test('feelGood has comedy and family genres', () {
      expect(DiscoveryMood.feelGood.genreIds, [35, 10751, 16]);
      expect(DiscoveryMood.feelGood.label, 'Feel-Good');
      expect(DiscoveryMood.feelGood.emoji, '😊');
    });

    test('thrilling has correct genres', () {
      expect(DiscoveryMood.thrilling.genreIds, [53, 28, 80]);
    });

    test('mindBending has sci-fi and mystery', () {
      expect(DiscoveryMood.mindBending.genreIds, [878, 9648]);
    });

    test('romantic has romance and drama', () {
      expect(DiscoveryMood.romantic.genreIds, [10749, 18]);
    });

    test('documentary has documentary genre', () {
      expect(DiscoveryMood.documentary.genreIds, [99]);
    });

    test('darkGritty has horror, war, drama', () {
      expect(DiscoveryMood.darkGritty.genreIds, [27, 10752, 18]);
    });
  });

  group('RandomPickerFilter', () {
    test('has all expected values', () {
      expect(RandomPickerFilter.values, [
        RandomPickerFilter.movies,
        RandomPickerFilter.series,
        RandomPickerFilter.both,
      ]);
    });
  });
}
