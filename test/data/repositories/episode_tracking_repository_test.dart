import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:neon_voyager/data/repositories/episode_tracking_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late EpisodeTrackingRepository repo;
  const userId = 'testuser';
  const tvId = 1399; // Game of Thrones

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = EpisodeTrackingRepository(userId, firestore: fakeFirestore);
  });

  group('EpisodeTrackingRepository', () {
    group('episodeKey', () {
      test('builds the correct key format', () {
        expect(EpisodeTrackingRepository.episodeKey(1, 3), 's1_e3');
        expect(EpisodeTrackingRepository.episodeKey(2, 10), 's2_e10');
        expect(EpisodeTrackingRepository.episodeKey(5, 1), 's5_e1');
      });
    });

    group('markEpisodeWatched', () {
      test('stores the episode key in Firestore', () async {
        await repo.markEpisodeWatched(tvId, 1, 3);

        final watched = await repo.getWatchedEpisodes(tvId);
        expect(watched, contains('s1_e3'));
      });

      test('can mark multiple episodes from different seasons', () async {
        await repo.markEpisodeWatched(tvId, 1, 1);
        await repo.markEpisodeWatched(tvId, 1, 2);
        await repo.markEpisodeWatched(tvId, 2, 1);

        final watched = await repo.getWatchedEpisodes(tvId);
        expect(watched, containsAll(['s1_e1', 's1_e2', 's2_e1']));
        expect(watched.length, 3);
      });

      test('is idempotent — marking twice keeps only one entry', () async {
        await repo.markEpisodeWatched(tvId, 1, 1);
        await repo.markEpisodeWatched(tvId, 1, 1);

        final watched = await repo.getWatchedEpisodes(tvId);
        expect(watched.length, 1);
      });
    });

    group('unmarkEpisodeWatched', () {
      test('removes an existing episode key', () async {
        await repo.markEpisodeWatched(tvId, 1, 3);
        expect(await repo.isEpisodeWatched(tvId, 1, 3), isTrue);

        await repo.unmarkEpisodeWatched(tvId, 1, 3);

        expect(await repo.isEpisodeWatched(tvId, 1, 3), isFalse);
      });

      test('does not affect other episodes in same document', () async {
        await repo.markEpisodeWatched(tvId, 1, 1);
        await repo.markEpisodeWatched(tvId, 1, 2);
        await repo.markEpisodeWatched(tvId, 1, 3);

        await repo.unmarkEpisodeWatched(tvId, 1, 2);

        final watched = await repo.getWatchedEpisodes(tvId);
        expect(watched, containsAll(['s1_e1', 's1_e3']));
        expect(watched, isNot(contains('s1_e2')));
      });
    });

    group('getWatchedEpisodes', () {
      test('returns empty set when no episodes tracked', () async {
        final watched = await repo.getWatchedEpisodes(tvId);
        expect(watched, isEmpty);
      });

      test('returns correct set of watched keys', () async {
        await repo.markEpisodeWatched(tvId, 1, 1);
        await repo.markEpisodeWatched(tvId, 2, 5);

        final watched = await repo.getWatchedEpisodes(tvId);
        expect(watched, {'s1_e1', 's2_e5'});
      });

      test('isolates data by tvId', () async {
        const otherTvId = 9999;
        await repo.markEpisodeWatched(tvId, 1, 1);
        await repo.markEpisodeWatched(otherTvId, 1, 1);

        final got1399 = await repo.getWatchedEpisodes(tvId);
        final got9999 = await repo.getWatchedEpisodes(otherTvId);

        expect(got1399, {'s1_e1'});
        expect(got9999, {'s1_e1'});
        // Each is its own document so they are independent
        expect(got1399.length, 1);
        expect(got9999.length, 1);
      });
    });

    group('isEpisodeWatched', () {
      test('returns true when episode is watched', () async {
        await repo.markEpisodeWatched(tvId, 3, 9);
        expect(await repo.isEpisodeWatched(tvId, 3, 9), isTrue);
      });

      test('returns false when episode is not watched', () async {
        expect(await repo.isEpisodeWatched(tvId, 1, 1), isFalse);
      });

      test('distinguishes season+episode pairs correctly', () async {
        await repo.markEpisodeWatched(tvId, 1, 1);
        expect(await repo.isEpisodeWatched(tvId, 1, 1), isTrue);
        expect(await repo.isEpisodeWatched(tvId, 1, 2), isFalse);
        expect(await repo.isEpisodeWatched(tvId, 2, 1), isFalse);
      });
    });

    group('getWatchedCount', () {
      test('returns 0 when nothing tracked', () async {
        expect(await repo.getWatchedCount(tvId), 0);
      });

      test('returns correct count', () async {
        await repo.markEpisodeWatched(tvId, 1, 1);
        await repo.markEpisodeWatched(tvId, 1, 2);
        await repo.markEpisodeWatched(tvId, 2, 1);

        expect(await repo.getWatchedCount(tvId), 3);
      });
    });

    group('clearEpisodeTracking', () {
      test('removes all tracking data for a tv series', () async {
        await repo.markEpisodeWatched(tvId, 1, 1);
        await repo.markEpisodeWatched(tvId, 1, 2);
        await repo.markEpisodeWatched(tvId, 2, 1);

        await repo.clearEpisodeTracking(tvId);

        final watched = await repo.getWatchedEpisodes(tvId);
        expect(watched, isEmpty);
      });

      test('does not affect other tv series', () async {
        const otherTvId = 8888;
        await repo.markEpisodeWatched(tvId, 1, 1);
        await repo.markEpisodeWatched(otherTvId, 1, 1);

        await repo.clearEpisodeTracking(tvId);

        expect(await repo.getWatchedEpisodes(tvId), isEmpty);
        expect(await repo.getWatchedEpisodes(otherTvId), {'s1_e1'});
      });
    });
  });
}
