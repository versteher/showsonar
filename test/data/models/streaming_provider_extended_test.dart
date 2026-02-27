import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/models/streaming_provider.dart';

void main() {
  group('StreamingProvider — extended', () {
    group('getProvidersForCountry', () {
      test('DE includes global + regional providers', () {
        final providers = StreamingProvider.getProvidersForCountry('DE');
        // Global providers always first
        expect(providers[0], StreamingProvider.netflix);
        expect(providers[1], StreamingProvider.disneyPlus);
        expect(providers[2], StreamingProvider.amazonPrime);
        expect(providers[3], StreamingProvider.appleTv);
        // DE-specific providers
        final ids = providers.map((p) => p.id).toSet();
        expect(ids, contains('rtl_plus'));
        expect(ids, contains('joyn'));
        expect(ids, contains('wow'));
        expect(ids, contains('ard_mediathek'));
        expect(ids, contains('zdf_mediathek'));
        expect(ids, contains('arte'));
      });

      test('US includes Hulu and Peacock', () {
        final providers = StreamingProvider.getProvidersForCountry('US');
        final ids = providers.map((p) => p.id).toSet();
        expect(ids, contains('hulu'));
        expect(ids, contains('peacock'));
        expect(ids, contains('netflix'));
      });

      test('JP includes U-NEXT and Crunchyroll', () {
        final providers = StreamingProvider.getProvidersForCountry('JP');
        final ids = providers.map((p) => p.id).toSet();
        expect(ids, contains('u_next'));
        expect(ids, contains('crunchyroll'));
        expect(ids, contains('netflix')); // Global
      });

      test('unknown country returns fallback with global + popular', () {
        final providers = StreamingProvider.getProvidersForCountry('XX');
        expect(providers.length, greaterThanOrEqualTo(4));
        final ids = providers.map((p) => p.id).toSet();
        // Global providers always present
        expect(ids, contains('netflix'));
        expect(ids, contains('disney_plus'));
        expect(ids, contains('amazon_prime'));
        expect(ids, contains('apple_tv'));
      });

      test('case-insensitive country code', () {
        final upper = StreamingProvider.getProvidersForCountry('DE');
        final lower = StreamingProvider.getProvidersForCountry('de');
        expect(
          upper.map((p) => p.id).toList(),
          lower.map((p) => p.id).toList(),
        );
      });

      test('no duplicate providers in result', () {
        final providers = StreamingProvider.getProvidersForCountry('DE');
        final ids = providers.map((p) => p.id).toList();
        expect(ids.toSet().length, ids.length);
      });

      test('always starts with global providers', () {
        const countries = ['DE', 'US', 'GB', 'JP', 'BR', 'IN', 'AU', 'FR'];
        for (final country in countries) {
          final providers = StreamingProvider.getProvidersForCountry(country);
          final first4Ids = providers.take(4).map((p) => p.id).toList();
          expect(first4Ids, [
            'netflix',
            'disney_plus',
            'amazon_prime',
            'apple_tv',
          ], reason: 'Global providers must be first for $country');
        }
      });
    });

    group('getDefaultServiceIds', () {
      test('returns 4 default services for DE', () {
        final ids = StreamingProvider.getDefaultServiceIds('DE');
        expect(ids.length, 4);
        expect(ids, ['netflix', 'disney_plus', 'amazon_prime', 'apple_tv']);
      });

      test('returns 4 default services for US', () {
        final ids = StreamingProvider.getDefaultServiceIds('US');
        expect(ids.length, 4);
        expect(ids[0], 'netflix');
      });

      test('returns 4 default services for unknown country', () {
        final ids = StreamingProvider.getDefaultServiceIds('XX');
        expect(ids.length, 4);
      });
    });

    group('globalProviders', () {
      test('contains exactly 4 global platforms', () {
        expect(StreamingProvider.globalProviders.length, 4);
        expect(StreamingProvider.globalProviders[0], StreamingProvider.netflix);
        expect(
          StreamingProvider.globalProviders[1],
          StreamingProvider.disneyPlus,
        );
        expect(
          StreamingProvider.globalProviders[2],
          StreamingProvider.amazonPrime,
        );
        expect(StreamingProvider.globalProviders[3], StreamingProvider.appleTv);
      });

      test('none are public broadcasters', () {
        for (final p in StreamingProvider.globalProviders) {
          expect(p.isPublicBroadcaster, isFalse, reason: '${p.name} global');
        }
      });
    });

    group('country coverage', () {
      test('all DACH countries have providers', () {
        for (final code in ['DE', 'AT', 'CH']) {
          final providers = StreamingProvider.getProvidersForCountry(code);
          expect(
            providers.length,
            greaterThan(4),
            reason: '$code should have regional providers',
          );
        }
      });

      test('Nordic countries have providers', () {
        for (final code in ['SE', 'NO', 'DK', 'FI']) {
          final providers = StreamingProvider.getProvidersForCountry(code);
          expect(
            providers.length,
            greaterThan(4),
            reason: '$code should have regional',
          );
        }
      });

      test('Asian countries have providers', () {
        for (final code in ['JP', 'KR', 'IN']) {
          final providers = StreamingProvider.getProvidersForCountry(code);
          expect(
            providers.length,
            greaterThan(4),
            reason: '$code should have regional',
          );
        }
      });
    });

    group('public broadcaster flag', () {
      test('public broadcasters are correctly flagged', () {
        expect(StreamingProvider.ardMediathek.isPublicBroadcaster, isTrue);
        expect(StreamingProvider.zdfMediathek.isPublicBroadcaster, isTrue);
        expect(StreamingProvider.arte.isPublicBroadcaster, isTrue);
        expect(StreamingProvider.srfPlay.isPublicBroadcaster, isTrue);
        expect(StreamingProvider.drTv.isPublicBroadcaster, isTrue);
        expect(StreamingProvider.yleAreena.isPublicBroadcaster, isTrue);
        expect(StreamingProvider.playsuisse.isPublicBroadcaster, isTrue);
      });

      test('commercial providers are not flagged as public', () {
        expect(StreamingProvider.netflix.isPublicBroadcaster, isFalse);
        expect(StreamingProvider.disneyPlus.isPublicBroadcaster, isFalse);
        expect(StreamingProvider.hboMax.isPublicBroadcaster, isFalse);
        expect(StreamingProvider.hulu.isPublicBroadcaster, isFalse);
      });
    });

    group('allProviders integrity', () {
      test('every provider has a non-null tmdbId', () {
        for (final p in StreamingProvider.allProviders) {
          expect(p.tmdbId, isNotNull, reason: '${p.name} missing TMDB ID');
        }
      });

      test('every provider has a non-empty name', () {
        for (final p in StreamingProvider.allProviders) {
          expect(p.name.isNotEmpty, isTrue, reason: '${p.id} missing name');
        }
      });

      test('every provider has a non-empty logoPath', () {
        for (final p in StreamingProvider.allProviders) {
          expect(p.logoPath.isNotEmpty, isTrue, reason: '${p.id} missing logo');
        }
      });
    });
  });
}
