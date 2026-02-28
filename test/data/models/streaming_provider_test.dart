import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/streaming_provider.dart';

void main() {
  group('StreamingProvider', () {
    test('should have correct predefined providers', () {
      expect(StreamingProvider.netflix.id, 'netflix');
      expect(StreamingProvider.netflix.name, 'Netflix');
      expect(StreamingProvider.netflix.tmdbId, 8);

      expect(StreamingProvider.disneyPlus.id, 'disney_plus');
      expect(StreamingProvider.disneyPlus.name, 'Disney+');
      expect(StreamingProvider.disneyPlus.tmdbId, 337);

      expect(StreamingProvider.amazonPrime.id, 'amazon_prime');
      expect(StreamingProvider.amazonPrime.name, 'Amazon Prime');
      expect(StreamingProvider.amazonPrime.tmdbId, 9);

      expect(StreamingProvider.hboMax.id, 'hbo_max');
      expect(StreamingProvider.hboMax.name, 'Max');
      expect(StreamingProvider.hboMax.tmdbId, 1899);

      expect(StreamingProvider.appleTv.id, 'apple_tv');
      expect(StreamingProvider.appleTv.name, 'Apple TV+');
      expect(StreamingProvider.appleTv.tmdbId, 350);
    });

    test('public broadcasters should have correct TMDB IDs', () {
      expect(StreamingProvider.ardMediathek.tmdbId, 219);
      expect(StreamingProvider.zdfMediathek.tmdbId, 537);
      expect(StreamingProvider.arte.tmdbId, 234);
      expect(StreamingProvider.srfPlay.tmdbId, 222);
      expect(StreamingProvider.drTv.tmdbId, 620);
    });

    test('ARD and ZDF must have DIFFERENT TMDB IDs', () {
      // This was a bug: both had 219
      expect(
        StreamingProvider.ardMediathek.tmdbId,
        isNot(equals(StreamingProvider.zdfMediathek.tmdbId)),
        reason:
            'ARD and ZDF are different providers and must have unique TMDB IDs',
      );
    });

    test('all providers should have unique internal IDs', () {
      final ids = StreamingProvider.allProviders.map((p) => p.id).toSet();
      expect(ids.length, StreamingProvider.allProviders.length);
    });

    test('all providers with TMDB IDs should have unique TMDB IDs', () {
      final tmdbIds = StreamingProvider.allProviders
          .where((p) => p.tmdbId != null)
          .map((p) => p.tmdbId!)
          .toList();
      final uniqueTmdbIds = tmdbIds.toSet();
      expect(
        uniqueTmdbIds.length,
        tmdbIds.length,
        reason: 'Every provider must have a unique TMDB ID: $tmdbIds',
      );
    });

    test('allProviders should contain all 42 providers', () {
      expect(StreamingProvider.allProviders.length, 42);
      // Spot-check key providers from different regions
      expect(
        StreamingProvider.allProviders,
        containsAll([
          StreamingProvider.netflix,
          StreamingProvider.disneyPlus,
          StreamingProvider.amazonPrime,
          StreamingProvider.hboMax,
          StreamingProvider.appleTv,
          StreamingProvider.ardMediathek,
          StreamingProvider.zdfMediathek,
          StreamingProvider.arte,
          StreamingProvider.srfPlay,
          StreamingProvider.drTv,
        ]),
      );
    });

    test('commercial providers should have 5 entries', () {
      expect(StreamingProvider.commercialProviders.length, 5);
      for (final p in StreamingProvider.commercialProviders) {
        expect(p.isPublicBroadcaster, isFalse);
      }
    });

    test('public broadcasters should have 5 entries and be flagged', () {
      expect(StreamingProvider.publicBroadcasters.length, 5);
      for (final p in StreamingProvider.publicBroadcasters) {
        expect(p.isPublicBroadcaster, isTrue);
      }
    });

    test('fromId should return correct provider', () {
      expect(StreamingProvider.fromId('netflix'), StreamingProvider.netflix);
      expect(
        StreamingProvider.fromId('disney_plus'),
        StreamingProvider.disneyPlus,
      );
      expect(
        StreamingProvider.fromId('amazon_prime'),
        StreamingProvider.amazonPrime,
      );
      expect(StreamingProvider.fromId('hbo_max'), StreamingProvider.hboMax);
      expect(
        StreamingProvider.fromId('ard_mediathek'),
        StreamingProvider.ardMediathek,
      );
      expect(
        StreamingProvider.fromId('zdf_mediathek'),
        StreamingProvider.zdfMediathek,
      );
    });

    test('fromId should return null for unknown id', () {
      expect(StreamingProvider.fromId('unknown'), isNull);
      expect(StreamingProvider.fromId(''), isNull);
    });

    test('fromTmdbId should return correct provider', () {
      expect(StreamingProvider.fromTmdbId(8), StreamingProvider.netflix);
      expect(StreamingProvider.fromTmdbId(337), StreamingProvider.disneyPlus);
      expect(StreamingProvider.fromTmdbId(219), StreamingProvider.ardMediathek);
      expect(StreamingProvider.fromTmdbId(537), StreamingProvider.zdfMediathek);
    });

    test('fromTmdbId should return null for unknown TMDB id', () {
      expect(StreamingProvider.fromTmdbId(99999), isNull);
      expect(StreamingProvider.fromTmdbId(-1), isNull);
    });

    test('getTmdbIds should resolve provider IDs to TMDB IDs', () {
      final tmdbIds = StreamingProvider.getTmdbIds([
        'netflix',
        'ard_mediathek',
        'zdf_mediathek',
      ]);
      expect(tmdbIds, [8, 219, 537]);
    });

    test('getTmdbIds should skip unknown provider IDs', () {
      final tmdbIds = StreamingProvider.getTmdbIds([
        'netflix',
        'unknown_service',
        'ard_mediathek',
      ]);
      expect(tmdbIds, [8, 219]);
    });

    test('getTmdbIds with empty list returns empty', () {
      expect(StreamingProvider.getTmdbIds([]), isEmpty);
    });

    test('equality should be based on id', () {
      const provider1 = StreamingProvider(
        id: 'test',
        name: 'Test Provider',
        logoPath: 'path1',
      );
      const provider2 = StreamingProvider(
        id: 'test',
        name: 'Different Name',
        logoPath: 'path2',
      );
      const provider3 = StreamingProvider(
        id: 'other',
        name: 'Test Provider',
        logoPath: 'path1',
      );

      expect(provider1, equals(provider2));
      expect(provider1, isNot(equals(provider3)));
    });

    test('toString should return readable format', () {
      expect(
        StreamingProvider.netflix.toString(),
        'StreamingProvider(id: netflix, name: Netflix, tmdbId: 8)',
      );
    });
  });
}
