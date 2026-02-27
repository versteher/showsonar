import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/watchlist_entry.dart';

void main() {
  group('WatchlistPriority', () {
    test('displayName returns English fallback labels', () {
      // displayName is now an English fallback; use localizedName(l10n) in widgets.
      expect(WatchlistPriority.high.displayName, 'High');
      expect(WatchlistPriority.normal.displayName, 'Normal');
      expect(WatchlistPriority.low.displayName, 'Low');
    });
  });

  group('WatchlistEntry', () {
    final testEntry = WatchlistEntry(
      mediaId: 550,
      mediaType: MediaType.movie,
      title: 'Fight Club',
      posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      backdropPath: '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
      addedAt: DateTime(2024, 6, 1, 10, 0),
      voteAverage: 8.4,
      priority: WatchlistPriority.high,
      notes: 'Must watch',
      genreIds: [18, 53],
    );

    test('should create entry with all required fields', () {
      expect(testEntry.mediaId, 550);
      expect(testEntry.mediaType, MediaType.movie);
      expect(testEntry.title, 'Fight Club');
      expect(testEntry.priority, WatchlistPriority.high);
      expect(testEntry.notes, 'Must watch');
      expect(testEntry.genreIds, [18, 53]);
    });

    test('uniqueKey should combine type and id', () {
      expect(testEntry.uniqueKey, 'movie_550');
      final tvEntry = testEntry.copyWith(mediaType: MediaType.tv);
      expect(tvEntry.uniqueKey, 'tv_550');
    });

    test('fullPosterPath should return complete URL', () {
      expect(
        testEntry.fullPosterPath,
        'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      );
    });

    test(
      'fullPosterPath should return empty string when posterPath is null',
      () {
        final entry = WatchlistEntry(
          mediaId: 123,
          mediaType: MediaType.movie,
          title: 'Test',
          addedAt: DateTime(2024, 1, 1),
        );
        expect(entry.fullPosterPath, '');
      },
    );

    test('addedAgo returns "just now" for very recent entries', () {
      final recentEntry = testEntry.copyWith(addedAt: DateTime.now());
      expect(recentEntry.addedAgo, 'just now');
    });

    test('addedAgo returns hours ago for entries added hours ago', () {
      final hoursAgo = testEntry.copyWith(
        addedAt: DateTime.now().subtract(const Duration(hours: 3)),
      );
      expect(hoursAgo.addedAgo, '3 hours ago');
    });

    test('addedAgo returns singular hour for 1 hour', () {
      final oneHourAgo = testEntry.copyWith(
        addedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(oneHourAgo.addedAgo, '1 hour ago');
    });

    test('addedAgo returns days ago for entries added days ago', () {
      final daysAgo = testEntry.copyWith(
        addedAt: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(daysAgo.addedAgo, '5 days ago');
    });

    test('addedAgo returns singular day for 1 day', () {
      final oneDayAgo = testEntry.copyWith(
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(oneDayAgo.addedAgo, '1 day ago');
    });

    test('addedAgo returns months ago for entries added months ago', () {
      final monthsAgo = testEntry.copyWith(
        addedAt: DateTime.now().subtract(const Duration(days: 65)),
      );
      expect(monthsAgo.addedAgo, '2 months ago');
    });

    test('addedAgo returns singular month for 1 month', () {
      final oneMonthAgo = testEntry.copyWith(
        addedAt: DateTime.now().subtract(const Duration(days: 35)),
      );
      expect(oneMonthAgo.addedAgo, '1 month ago');
    });

    test('addedAgo returns years ago for entries added years ago', () {
      final yearsAgo = testEntry.copyWith(
        addedAt: DateTime.now().subtract(const Duration(days: 800)),
      );
      expect(yearsAgo.addedAgo, '2 years ago');
    });

    test('addedAgo returns singular year for 1 year', () {
      final oneYearAgo = testEntry.copyWith(
        addedAt: DateTime.now().subtract(const Duration(days: 370)),
      );
      expect(oneYearAgo.addedAgo, '1 year ago');
    });

    test('copyWith should create new instance with updated fields', () {
      final updated = testEntry.copyWith(
        title: 'Updated',
        priority: WatchlistPriority.low,
        notes: 'New notes',
      );

      expect(updated.title, 'Updated');
      expect(updated.priority, WatchlistPriority.low);
      expect(updated.notes, 'New notes');
      expect(updated.mediaId, testEntry.mediaId);
    });

    test('defaults: priority is normal, genreIds is empty', () {
      final entry = WatchlistEntry(
        mediaId: 1,
        mediaType: MediaType.movie,
        title: 'T',
        addedAt: DateTime(2024, 1, 1),
      );
      expect(entry.priority, WatchlistPriority.normal);
      expect(entry.genreIds, isEmpty);
    });

    group('JSON serialization', () {
      test('toJson should serialize all fields', () {
        final json = testEntry.toJson();
        expect(json['mediaId'], 550);
        expect(json['mediaType'], 'movie');
        expect(json['title'], 'Fight Club');
        expect(json['posterPath'], '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg');
        expect(json['backdropPath'], '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg');
        expect(json['voteAverage'], 8.4);
        expect(json['priority'], 'high');
        expect(json['notes'], 'Must watch');
        expect(json['genreIds'], [18, 53]);
      });

      test('fromJson should deserialize correctly', () {
        final json = {
          'mediaId': 550,
          'mediaType': 'movie',
          'title': 'Fight Club',
          'posterPath': '/poster.jpg',
          'backdropPath': '/backdrop.jpg',
          'addedAt': '2024-06-01T10:00:00.000',
          'voteAverage': 8.4,
          'priority': 'high',
          'notes': 'Must watch',
          'genreIds': [18, 53],
        };

        final entry = WatchlistEntry.fromJson(json);
        expect(entry.mediaId, 550);
        expect(entry.mediaType, MediaType.movie);
        expect(entry.title, 'Fight Club');
        expect(entry.priority, WatchlistPriority.high);
        expect(entry.notes, 'Must watch');
        expect(entry.genreIds, [18, 53]);
      });

      test('fromJson should handle missing optional fields', () {
        final json = {
          'mediaId': 550,
          'mediaType': 'movie',
          'title': 'Test',
          'addedAt': '2024-01-15T20:30:00.000',
        };

        final entry = WatchlistEntry.fromJson(json);
        expect(entry.posterPath, isNull);
        expect(entry.backdropPath, isNull);
        expect(entry.voteAverage, isNull);
        expect(entry.priority, WatchlistPriority.normal);
        expect(entry.notes, isNull);
        expect(entry.genreIds, isEmpty);
      });

      test('fromJson should default to movie for unknown mediaType', () {
        final json = {
          'mediaId': 550,
          'mediaType': 'unknown',
          'title': 'Test',
          'addedAt': '2024-01-15T20:30:00.000',
        };

        final entry = WatchlistEntry.fromJson(json);
        expect(entry.mediaType, MediaType.movie);
      });

      test('fromJson should default to normal for unknown priority', () {
        final json = {
          'mediaId': 550,
          'mediaType': 'movie',
          'title': 'Test',
          'addedAt': '2024-01-15T20:30:00.000',
          'priority': 'unknown_priority',
        };

        final entry = WatchlistEntry.fromJson(json);
        expect(entry.priority, WatchlistPriority.normal);
      });

      test('round-trip serialization should preserve data', () {
        final json = testEntry.toJson();
        final restored = WatchlistEntry.fromJson(json);

        expect(restored.mediaId, testEntry.mediaId);
        expect(restored.mediaType, testEntry.mediaType);
        expect(restored.title, testEntry.title);
        expect(restored.voteAverage, testEntry.voteAverage);
        expect(restored.priority, testEntry.priority);
        expect(restored.notes, testEntry.notes);
        expect(restored.genreIds, testEntry.genreIds);
      });
    });

    group('fromMedia factory', () {
      test('should create entry from Media object', () {
        final media = Media(
          id: 1399,
          title: 'Game of Thrones',
          overview: 'Seven noble families...',
          posterPath: '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
          backdropPath: '/suopoADq0k8YZr4dQXcU6pToj6s.jpg',
          voteAverage: 8.4,
          voteCount: 21000,
          genreIds: [10765, 18],
          type: MediaType.tv,
        );

        final entry = WatchlistEntry.fromMedia(media);

        expect(entry.mediaId, 1399);
        expect(entry.mediaType, MediaType.tv);
        expect(entry.title, 'Game of Thrones');
        expect(entry.posterPath, '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg');
        expect(entry.backdropPath, '/suopoADq0k8YZr4dQXcU6pToj6s.jpg');
        expect(entry.voteAverage, 8.4);
        expect(entry.genreIds, [10765, 18]);
        expect(entry.priority, WatchlistPriority.normal);
      });
    });

    test('equality should be deep equality due to freezed', () {
      final entry1 = testEntry;
      final entry2 = testEntry.copyWith();
      final entry3 = testEntry.copyWith(title: 'Different');

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
    });
  });
}
