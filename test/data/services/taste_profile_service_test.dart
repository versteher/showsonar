import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/watch_history_entry.dart';
import 'package:neon_voyager/data/repositories/watch_history_repository.dart';
import 'package:neon_voyager/data/services/taste_profile_service.dart';

void main() {
  late Directory tempDir;
  late FakeFirebaseFirestore fakeFirestore;
  late WatchHistoryRepository repo;
  late TasteProfileService service;

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
    userRating: 10.0,
    genreIds: [18, 80],
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_taste_');
    Hive.init(tempDir.path);
    fakeFirestore = FakeFirebaseFirestore();
    repo = WatchHistoryRepository('test_user', firestore: fakeFirestore);
    await repo.init();
    service = TasteProfileService(repo);
  });

  tearDown(() async {
    await repo.close();
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('TasteProfile model', () {
    test('toJson produces expected structure', () {
      final profile = TasteProfile(
        exportedAt: '2024-01-01T00:00:00.000',
        schemaVersion: 1,
        entries: [
          {'mediaId': 550, 'title': 'Fight Club'},
        ],
        stats: {'totalWatched': 1},
      );
      final json = profile.toJson();
      expect(json['version'], 1);
      expect(json['exportedAt'], '2024-01-01T00:00:00.000');
      expect(json['entries'], isList);
      expect(json['stats']['totalWatched'], 1);
    });

    test('fromJson roundtrip', () {
      final original = TasteProfile(
        exportedAt: '2024-06-15T12:00:00.000',
        schemaVersion: 1,
        entries: [
          {'mediaId': 1, 'title': 'Test'},
        ],
        stats: {'totalWatched': 1, 'averageRating': 8.5},
      );
      final json = original.toJson();
      final restored = TasteProfile.fromJson(json);
      expect(restored.schemaVersion, 1);
      expect(restored.exportedAt, original.exportedAt);
      expect(restored.entries.length, 1);
      expect(restored.stats['averageRating'], 8.5);
    });

    test('fromJson handles missing fields gracefully', () {
      final json = <String, dynamic>{};
      final profile = TasteProfile.fromJson(json);
      expect(profile.schemaVersion, 1);
      expect(profile.exportedAt, '');
      expect(profile.entries, isEmpty);
      expect(profile.stats, isEmpty);
    });
  });

  group('TasteProfileService', () {
    group('export', () {
      test('exports empty history', () async {
        final jsonStr = await service.export();
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        expect(data['version'], TasteProfile.version);
        expect(data['entries'], isEmpty);
        expect(data['stats']['totalWatched'], 0);
        expect(data['stats']['totalRated'], 0);
      });

      test('exports history with entries', () async {
        await repo.addToHistory(entry1);
        await repo.addToHistory(entry2);

        final jsonStr = await service.export();
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;

        expect(data['entries'].length, 2);
        expect(data['stats']['totalWatched'], 2);
        expect(data['stats']['totalRated'], 2);
        expect(data['stats']['averageRating'], 8.5);
      });

      test('exports stats with top genres', () async {
        await repo.addToHistory(entry1); // genres: [18, 53]
        await repo.addToHistory(entry2); // genres: [18, 10765]
        await repo.addToHistory(entry3); // genres: [18, 80]

        final jsonStr = await service.export();
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;

        final topGenres = data['stats']['topGenreIds'] as List;
        // Genre 18 (Drama) appears in all 3 entries, should be first
        expect(topGenres.first, 18);
      });
    });

    group('import', () {
      test('imports new entries', () async {
        // First export from a populated repo
        await repo.addToHistory(entry1);
        final exported = await service.export();

        // Clear and re-init
        await repo.clearAll();
        expect((await repo.getAllEntries()).length, 0);

        // Import
        final result = await service.import(exported);
        expect(result.imported, 1);
        expect(result.skipped, 0);
        expect((await repo.getAllEntries()).length, 1);
      });

      test('skips duplicate entries', () async {
        await repo.addToHistory(entry1);
        final exported = await service.export();

        // Import again (entry1 already exists)
        final result = await service.import(exported);
        expect(result.imported, 0);
        expect(result.skipped, 1);
      });

      test('handles mixed new and existing entries', () async {
        await repo.addToHistory(entry1);
        await repo.addToHistory(entry2);
        final exported = await service.export();

        // Clear and add only entry1 back
        await repo.clearAll();
        await repo.addToHistory(entry1);

        // Import: entry1 exists (skipped), entry2 is new (imported)
        final result = await service.import(exported);
        expect(result.imported, 1);
        expect(result.skipped, 1);
      });
    });

    group('preview', () {
      test('returns profile from valid JSON', () async {
        await repo.addToHistory(entry1);
        final exported = await service.export();

        final profile = service.preview(exported);
        expect(profile, isNotNull);
        expect(profile!.entries.length, 1);
      });

      test('returns null for invalid JSON', () {
        expect(service.preview('not json'), isNull);
      });

      test('returns null for empty string', () {
        expect(service.preview(''), isNull);
      });
    });

    group('computeOverlap', () {
      test('returns 0.0 when my history is empty', () async {
        final other = TasteProfile(
          exportedAt: '',
          schemaVersion: 1,
          entries: [
            {'mediaType': 'movie', 'mediaId': 550},
          ],
          stats: {},
        );
        expect(await service.computeOverlap(other), 0.0);
      });

      test('returns 0.0 when other profile is empty', () async {
        await repo.addToHistory(entry1);

        final other = TasteProfile(
          exportedAt: '',
          schemaVersion: 1,
          entries: [],
          stats: {},
        );
        expect(await service.computeOverlap(other), 0.0);
      });

      test('returns 1.0 for identical histories', () async {
        await repo.addToHistory(entry1);

        final other = TasteProfile(
          exportedAt: '',
          schemaVersion: 1,
          entries: [
            {'mediaType': 'movie', 'mediaId': 550},
          ],
          stats: {},
        );
        expect(await service.computeOverlap(other), 1.0);
      });

      test('returns 0.0 for completely different histories', () async {
        await repo.addToHistory(entry1); // movie_550

        final other = TasteProfile(
          exportedAt: '',
          schemaVersion: 1,
          entries: [
            {'mediaType': 'tv', 'mediaId': 999},
          ],
          stats: {},
        );
        expect(await service.computeOverlap(other), 0.0);
      });

      test('returns partial overlap correctly', () async {
        await repo.addToHistory(entry1); // movie_550
        await repo.addToHistory(entry2); // tv_1399

        final other = TasteProfile(
          exportedAt: '',
          schemaVersion: 1,
          entries: [
            {'mediaType': 'movie', 'mediaId': 550}, // overlap
            {'mediaType': 'tv', 'mediaId': 999}, // no overlap
          ],
          stats: {},
        );
        // intersection = 1 (movie_550), union = 3 (movie_550, tv_1399, tv_999)
        expect(await service.computeOverlap(other), closeTo(1 / 3, 0.01));
      });
    });
  });
}
