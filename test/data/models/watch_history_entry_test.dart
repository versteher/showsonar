import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/watch_history_entry.dart';

void main() {
  group('WatchHistoryEntry', () {
    final testEntry = WatchHistoryEntry(
      mediaId: 550,
      mediaType: MediaType.movie,
      title: 'Fight Club',
      posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      watchedAt: DateTime(2024, 1, 15, 20, 30),
      userRating: 9.0,
      completed: true,
    );

    test('should create entry with all required fields', () {
      expect(testEntry.mediaId, 550);
      expect(testEntry.mediaType, MediaType.movie);
      expect(testEntry.title, 'Fight Club');
      expect(testEntry.userRating, 9.0);
      expect(testEntry.completed, isTrue);
    });

    test('uniqueKey should combine type and id', () {
      expect(testEntry.uniqueKey, 'movie_550');

      final tvEntry = testEntry.copyWith(mediaType: MediaType.tv);
      expect(tvEntry.uniqueKey, 'tv_550');
    });

    test('isRated should check if userRating exists', () {
      expect(testEntry.isRated, isTrue);

      final unratedEntry = WatchHistoryEntry(
        mediaId: 550,
        mediaType: MediaType.movie,
        title: 'Test',
        watchedAt: DateTime(2024, 1, 15),
        userRating: null,
      );
      expect(unratedEntry.isRated, isFalse);
    });

    test('copyWith should create new instance with updated fields', () {
      final updated = testEntry.copyWith(
        userRating: 8.0,
        completed: false,
        currentSeason: 2,
        currentEpisode: 5,
      );

      expect(updated.userRating, 8.0);
      expect(updated.completed, isFalse);
      expect(updated.currentSeason, 2);
      expect(updated.currentEpisode, 5);
      expect(updated.mediaId, testEntry.mediaId);
      expect(updated.title, testEntry.title);
    });

    group('JSON serialization', () {
      test('toJson should serialize all fields', () {
        final json = testEntry.toJson();

        expect(json['mediaId'], 550);
        expect(json['mediaType'], 'movie');
        expect(json['title'], 'Fight Club');
        expect(json['posterPath'], '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg');
        expect(json['watchedAt'], '2024-01-15T20:30:00.000');
        expect(json['userRating'], 9.0);
        expect(json['completed'], true);
      });

      test('fromJson should deserialize correctly', () {
        final json = {
          'mediaId': 550,
          'mediaType': 'movie',
          'title': 'Fight Club',
          'posterPath': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
          'watchedAt': '2024-01-15T20:30:00.000',
          'userRating': 9.0,
          'completed': true,
        };

        final entry = WatchHistoryEntry.fromJson(json);

        expect(entry.mediaId, 550);
        expect(entry.mediaType, MediaType.movie);
        expect(entry.title, 'Fight Club');
        expect(entry.userRating, 9.0);
        expect(entry.completed, isTrue);
      });

      test('fromJson should handle missing optional fields', () {
        final json = {
          'mediaId': 550,
          'mediaType': 'movie',
          'title': 'Test',
          'watchedAt': '2024-01-15T20:30:00.000',
        };

        final entry = WatchHistoryEntry.fromJson(json);

        expect(entry.posterPath, isNull);
        expect(entry.userRating, isNull);
        expect(entry.completed, isFalse);
        expect(entry.currentSeason, isNull);
        expect(entry.currentEpisode, isNull);
      });

      test('fromJson should default to movie for unknown mediaType', () {
        final json = {
          'mediaId': 550,
          'mediaType': 'unknown_type',
          'title': 'Test',
          'watchedAt': '2024-01-15T20:30:00.000',
        };

        final entry = WatchHistoryEntry.fromJson(json);
        expect(entry.mediaType, MediaType.movie);
      });

      test('round-trip serialization should preserve data', () {
        final json = testEntry.toJson();
        final restored = WatchHistoryEntry.fromJson(json);

        expect(restored.mediaId, testEntry.mediaId);
        expect(restored.mediaType, testEntry.mediaType);
        expect(restored.title, testEntry.title);
        expect(restored.userRating, testEntry.userRating);
        expect(restored.completed, testEntry.completed);
      });
    });

    group('fromMedia factory', () {
      test('should create entry from Media object', () {
        final media = Media(
          id: 1399,
          title: 'Game of Thrones',
          overview: 'Seven noble families...',
          posterPath: '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
          voteAverage: 8.4,
          voteCount: 21000,
          genreIds: [10765, 18],
          type: MediaType.tv,
        );

        final entry = WatchHistoryEntry.fromMedia(media, rating: 9.5);

        expect(entry.mediaId, 1399);
        expect(entry.mediaType, MediaType.tv);
        expect(entry.title, 'Game of Thrones');
        expect(entry.posterPath, '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg');
        expect(entry.userRating, 9.5);
        expect(entry.completed, isFalse);
      });

      test('should create entry without rating', () {
        final media = Media(
          id: 550,
          title: 'Fight Club',
          overview: 'Test',
          voteAverage: 8.4,
          voteCount: 26500,
          genreIds: [18],
          type: MediaType.movie,
        );

        final entry = WatchHistoryEntry.fromMedia(media);

        expect(entry.userRating, isNull);
        expect(entry.isRated, isFalse);
      });
    });

    test('equality should be deep equality due to freezed', () {
      final entry1 = testEntry;
      final entry2 = testEntry.copyWith();
      final entry3 = testEntry.copyWith(userRating: 5.0);

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
    });
  });
}
