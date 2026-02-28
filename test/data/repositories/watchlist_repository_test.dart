import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/watchlist_entry.dart';
import 'package:stream_scout/data/repositories/watchlist_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late WatchlistRepository repo;
  const userId = 'guest';

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    repo = WatchlistRepository(userId, firestore: fakeFirestore);
    await repo.init();
  });

  // --- Test data ---
  final entry1 = WatchlistEntry(
    mediaId: 550,
    mediaType: MediaType.movie,
    title: 'Fight Club',
    addedAt: DateTime(2024, 3, 1),
    voteAverage: 8.4,
    genreIds: [18, 53],
  );

  final entry2 = WatchlistEntry(
    mediaId: 1399,
    mediaType: MediaType.tv,
    title: 'Game of Thrones',
    addedAt: DateTime(2024, 3, 15),
    voteAverage: 8.4,
    genreIds: [18, 10765],
  );

  final entry3 = WatchlistEntry(
    mediaId: 278,
    mediaType: MediaType.movie,
    title: 'Shawshank Redemption',
    addedAt: DateTime(2024, 2, 1),
    voteAverage: 8.7,
    genreIds: [18, 80],
  );

  group('WatchlistRepository', () {
    group('addToWatchlist / getEntry', () {
      test('stores and retrieves an entry', () async {
        await repo.addToWatchlist(entry1);

        final retrieved = await repo.getEntry(550, MediaType.movie);

        expect(retrieved, isNotNull);
        expect(retrieved!.mediaId, 550);
        expect(retrieved.title, 'Fight Club');
        expect(retrieved.voteAverage, 8.4);
        expect(retrieved.genreIds, [18, 53]);
      });

      test('returns null for non-existent entry', () async {
        final result = await repo.getEntry(999, MediaType.movie);
        expect(result, isNull);
      });
    });

    group('addMedia', () {
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

        final result = await repo.addMedia(media);

        expect(result.mediaId, 700);
        expect(result.title, 'Test Movie');
        expect(result.voteAverage, 7.5);
        expect(result.genreIds, [28, 12]);

        final retrieved = await repo.getEntry(700, MediaType.movie);
        expect(retrieved, isNotNull);
        expect(retrieved!.title, 'Test Movie');
      });
    });

    group('updateEntry', () {
      test('updates an existing entry in place', () async {
        await repo.addToWatchlist(entry1);

        final updated = entry1.copyWith(
          priority: WatchlistPriority.high,
          notes: 'Must watch soon',
        );

        await repo.updateEntry(updated);

        final retrieved = await repo.getEntry(550, MediaType.movie);
        expect(retrieved!.priority, WatchlistPriority.high);
        expect(retrieved.notes, 'Must watch soon');
      });
    });

    group('removeFromWatchlist', () {
      test('removes an existing entry', () async {
        await repo.addToWatchlist(entry1);
        expect(await repo.isOnWatchlist(550, MediaType.movie), isTrue);

        await repo.removeFromWatchlist(550, MediaType.movie);

        expect(await repo.isOnWatchlist(550, MediaType.movie), isFalse);
        expect(await repo.getEntry(550, MediaType.movie), isNull);
      });

      test('does nothing for non-existent entry', () async {
        await repo.removeFromWatchlist(999, MediaType.movie);
        expect((await repo.getAllEntries()).length, 0);
      });
    });

    group('isOnWatchlist', () {
      test('returns true when entry exists', () async {
        await repo.addToWatchlist(entry1);
        expect(await repo.isOnWatchlist(550, MediaType.movie), isTrue);
      });

      test('returns false when entry does not exist', () async {
        expect(await repo.isOnWatchlist(550, MediaType.movie), isFalse);
      });

      test('distinguishes by media type', () async {
        await repo.addToWatchlist(entry1); // movie id=550
        expect(await repo.isOnWatchlist(550, MediaType.movie), isTrue);
        expect(await repo.isOnWatchlist(550, MediaType.tv), isFalse);
      });
    });

    group('getAllEntries', () {
      test('returns empty list when no entries', () async {
        expect(await repo.getAllEntries(), isEmpty);
      });

      test('returns all entries sorted by addedAt descending', () async {
        await repo.addToWatchlist(entry1); // March 1
        await repo.addToWatchlist(entry2); // March 15
        await repo.addToWatchlist(entry3); // Feb 1

        final entries = await repo.getAllEntries();

        expect(entries.length, 3);
        expect(entries[0].mediaId, 1399); // March 15 (newest)
        expect(entries[1].mediaId, 550); // March 1
        expect(entries[2].mediaId, 278); // Feb 1 (oldest)
      });
    });

    group('totalCount', () {
      test('returns 0 when empty', () async {
        expect((await repo.getAllEntries()).length, 0);
      });

      test('returns correct count', () async {
        await repo.addToWatchlist(entry1);
        await repo.addToWatchlist(entry2);
        expect((await repo.getAllEntries()).length, 2);
      });
    });

    group('clearAll', () {
      test('removes all entries', () async {
        await repo.addToWatchlist(entry1);
        await repo.addToWatchlist(entry2);
        expect((await repo.getAllEntries()).length, 2);

        await repo.clearAll();

        expect((await repo.getAllEntries()).length, 0);
        expect(await repo.getAllEntries(), isEmpty);
      });
    });
  });
}
