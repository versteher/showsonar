import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/watch_history_entry.dart';
import 'package:neon_voyager/data/repositories/watch_history_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late WatchHistoryRepository repo;
  const userId = 'guest';

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    repo = WatchHistoryRepository(userId, firestore: fakeFirestore);
    await repo.init();
  });

  // --- Test data ---
  final entry1 = WatchHistoryEntry(
    mediaId: 550,
    mediaType: MediaType.movie,
    title: 'Fight Club',
    watchedAt: DateTime(2024, 3, 1),
    userRating: 9.0,
    genreIds: [18, 53],
  );

  final entry2 = WatchHistoryEntry(
    mediaId: 1399,
    mediaType: MediaType.tv,
    title: 'Game of Thrones',
    watchedAt: DateTime(2024, 3, 15),
    userRating: 8.0,
    genreIds: [18, 10765],
  );

  final entry3 = WatchHistoryEntry(
    mediaId: 278,
    mediaType: MediaType.movie,
    title: 'Shawshank Redemption',
    watchedAt: DateTime(2024, 2, 1),
    userRating: 5.0,
    genreIds: [18, 80],
  );

  final entryNoRating = WatchHistoryEntry(
    mediaId: 100,
    mediaType: MediaType.movie,
    title: 'Unrated Movie',
    watchedAt: DateTime(2024, 1, 1),
    genreIds: [28],
  );

  group('WatchHistoryRepository', () {
    group('addToHistory / getEntry', () {
      test('stores and retrieves an entry', () async {
        await repo.addToHistory(entry1);

        final retrieved = await repo.getEntry(550, MediaType.movie);

        expect(retrieved, isNotNull);
        expect(retrieved!.mediaId, 550);
        expect(retrieved.title, 'Fight Club');
        expect(retrieved.userRating, 9.0);
        expect(retrieved.genreIds, [18, 53]);
      });

      test('returns null for non-existent entry', () async {
        final result = await repo.getEntry(999, MediaType.movie);
        expect(result, isNull);
      });
    });

    group('markAsWatched', () {
      test('creates entry from Media and stores it', () async {
        final media = Media(
          id: 700,
          title: 'Test Movie',
          overview: 'Test',
          voteAverage: 7.5,
          voteCount: 1000,
          genreIds: [28, 12],
          type: MediaType.movie,
          posterPath: '/poster.jpg',
        );

        final result = await repo.markAsWatched(media, rating: 8.0);

        expect(result.mediaId, 700);
        expect(result.title, 'Test Movie');
        expect(result.userRating, 8.0);

        final retrieved = await repo.getEntry(700, MediaType.movie);
        expect(retrieved, isNotNull);
        expect(retrieved!.title, 'Test Movie');
      });
    });

    group('updateEntry', () {
      test('updates an existing entry in place', () async {
        await repo.addToHistory(entry1);

        final updated = WatchHistoryEntry(
          mediaId: 550,
          mediaType: MediaType.movie,
          title: 'Fight Club',
          watchedAt: entry1.watchedAt,
          userRating: 10.0, // changed rating
          genreIds: [18, 53],
        );

        await repo.updateEntry(updated);

        final retrieved = await repo.getEntry(550, MediaType.movie);
        expect(retrieved!.userRating, 10.0);
      });
    });

    group('removeFromHistory', () {
      test('removes an existing entry', () async {
        await repo.addToHistory(entry1);
        expect(await repo.hasWatched(550, MediaType.movie), isTrue);

        await repo.removeFromHistory(550, MediaType.movie);

        expect(await repo.hasWatched(550, MediaType.movie), isFalse);
        expect(await repo.getEntry(550, MediaType.movie), isNull);
      });

      test('does nothing for non-existent entry', () async {
        await repo.removeFromHistory(999, MediaType.movie);
        expect((await repo.getAllEntries()).length, 0);
      });
    });

    group('hasWatched', () {
      test('returns true when entry exists', () async {
        await repo.addToHistory(entry1);
        expect(await repo.hasWatched(550, MediaType.movie), isTrue);
      });

      test('returns false when entry does not exist', () async {
        expect(await repo.hasWatched(550, MediaType.movie), isFalse);
      });

      test('distinguishes by media type', () async {
        await repo.addToHistory(entry1); // movie id=550
        expect(await repo.hasWatched(550, MediaType.movie), isTrue);
        expect(await repo.hasWatched(550, MediaType.tv), isFalse);
      });
    });

    group('getAllEntries', () {
      test('returns empty list when no entries', () async {
        expect(await repo.getAllEntries(), isEmpty);
      });

      test('returns all entries sorted by watchedAt descending', () async {
        await repo.addToHistory(entry1); // March 1
        await repo.addToHistory(entry2); // March 15
        await repo.addToHistory(entry3); // Feb 1

        final entries = await repo.getAllEntries();

        expect(entries.length, 3);
        expect(entries[0].mediaId, 1399); // March 15 (newest)
        expect(entries[1].mediaId, 550); // March 1
        expect(entries[2].mediaId, 278); // Feb 1 (oldest)
      });
    });

    group('getRecentlyWatched', () {
      test('returns limited number of entries', () async {
        await repo.addToHistory(entry1);
        await repo.addToHistory(entry2);
        await repo.addToHistory(entry3);

        final recent = await repo.getRecentlyWatched(limit: 2);

        expect(recent.length, 2);
        expect(recent[0].mediaId, 1399); // newest first
      });

      test('returns all if fewer than limit', () async {
        await repo.addToHistory(entry1);

        final recent = await repo.getRecentlyWatched(limit: 10);
        expect(recent.length, 1);
      });
    });

    group('getEntriesByType', () {
      test('filters by movie type', () async {
        await repo.addToHistory(entry1); // movie
        await repo.addToHistory(entry2); // tv
        await repo.addToHistory(entry3); // movie

        final movies = await repo.getEntriesByType(MediaType.movie);
        expect(movies.length, 2);
        expect(movies.every((e) => e.mediaType == MediaType.movie), isTrue);
      });

      test('filters by tv type', () async {
        await repo.addToHistory(entry1); // movie
        await repo.addToHistory(entry2); // tv

        final tvShows = await repo.getEntriesByType(MediaType.tv);
        expect(tvShows.length, 1);
        expect(tvShows[0].mediaId, 1399);
      });
    });

    group('getRatedEntries', () {
      test('returns only entries with ratings', () async {
        await repo.addToHistory(entry1); // rated 9.0
        await repo.addToHistory(entryNoRating); // no rating

        final rated = await repo.getRatedEntries();
        expect(rated.length, 1);
        expect(rated[0].mediaId, 550);
      });
    });

    group('getHighlyRated', () {
      test('returns entries rated above default threshold (7.0)', () async {
        await repo.addToHistory(entry1); // 9.0
        await repo.addToHistory(entry2); // 8.0
        await repo.addToHistory(entry3); // 5.0

        final highly = await repo.getHighlyRated();
        expect(highly.length, 2);
      });

      test('respects custom minimum rating', () async {
        await repo.addToHistory(entry1); // 9.0
        await repo.addToHistory(entry2); // 8.0
        await repo.addToHistory(entry3); // 5.0

        final highly = await repo.getHighlyRated(minRating: 8.5);
        expect(highly.length, 1);
        expect(highly[0].mediaId, 550);
      });
    });

    group('getGenreFrequency', () {
      test('counts genre occurrences using callback', () async {
        await repo.addToHistory(entry1); // genres: [18, 53]
        await repo.addToHistory(entry3); // genres: [18, 80]

        // Simulate callback that returns stored genreIds
        List<int> getGenres(int id, MediaType type) {
          if (id == 550) return [18, 53];
          if (id == 278) return [18, 80];
          return <int>[];
        }

        final freq = await repo.getGenreFrequency(getGenres);

        expect(freq[18], 2); // Drama appears in both
        expect(freq[53], 1); // Thriller in entry1 only
        expect(freq[80], 1); // Crime in entry3 only
      });
    });

    group('totalCount', () {
      test('returns 0 when empty', () async {
        expect((await repo.getAllEntries()).length, 0);
      });

      test('returns correct count', () async {
        await repo.addToHistory(entry1);
        await repo.addToHistory(entry2);
        expect((await repo.getAllEntries()).length, 2);
      });
    });

    group('getCountByType', () {
      test('returns correct count by type', () async {
        await repo.addToHistory(entry1); // movie
        await repo.addToHistory(entry2); // tv
        await repo.addToHistory(entry3); // movie

        expect(await repo.getCountByType(MediaType.movie), 2);
        expect(await repo.getCountByType(MediaType.tv), 1);
      });
    });

    group('clearAll', () {
      test('removes all entries', () async {
        await repo.addToHistory(entry1);
        await repo.addToHistory(entry2);
        expect((await repo.getAllEntries()).length, 2);

        await repo.clearAll();

        expect((await repo.getAllEntries()).length, 0);
        expect(await repo.getAllEntries(), isEmpty);
      });
    });
  });
}
