import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:stream_scout/data/models/streaming_provider.dart';

void main() {
  group('UserPreferences', () {
    test('defaultDE should have 4 commercial providers', () {
      final prefs = UserPreferences.defaultDE();
      expect(prefs.subscribedServiceIds.length, 4);
      expect(prefs.subscribedServiceIds, contains('netflix'));
      expect(prefs.subscribedServiceIds, contains('disney_plus'));
      expect(prefs.subscribedServiceIds, contains('amazon_prime'));
      expect(prefs.subscribedServiceIds, contains('apple_tv'));
    });

    test('defaultDE should be country DE', () {
      final prefs = UserPreferences.defaultDE();
      expect(prefs.countryCode, 'DE');
      expect(prefs.countryName, 'Deutschland');
    });

    test(
      'subscribedServices should resolve IDs to StreamingProvider objects',
      () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: ['netflix', 'ard_mediathek'],
        );
        final services = prefs.subscribedServices;
        expect(services.length, 2);
        expect(services[0], StreamingProvider.netflix);
        expect(services[1], StreamingProvider.ardMediathek);
      },
    );

    test('subscribedServices with empty list should return empty', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: [],
      );
      expect(prefs.subscribedServices, isEmpty);
    });

    test('subscribedServices should skip unknown IDs', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['netflix', 'nonexistent', 'ard_mediathek'],
      );
      final services = prefs.subscribedServices;
      expect(services.length, 2);
      expect(services[0], StreamingProvider.netflix);
      expect(services[1], StreamingProvider.ardMediathek);
    });

    test('isSubscribedTo should return correct boolean', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['netflix'],
      );
      expect(prefs.isSubscribedTo(StreamingProvider.netflix), isTrue);
      expect(prefs.isSubscribedTo(StreamingProvider.disneyPlus), isFalse);
      expect(prefs.isSubscribedTo(StreamingProvider.ardMediathek), isFalse);
    });

    test('copyWith should update subscribedServiceIds', () {
      final prefs = UserPreferences.defaultDE();
      final updated = prefs.copyWith(subscribedServiceIds: ['ard_mediathek']);
      expect(updated.subscribedServiceIds, ['ard_mediathek']);
      expect(updated.countryCode, 'DE'); // unchanged
    });

    test('copyWith to empty services should work', () {
      final prefs = UserPreferences.defaultDE();
      final updated = prefs.copyWith(subscribedServiceIds: []);
      expect(updated.subscribedServiceIds, isEmpty);
      expect(updated.subscribedServices, isEmpty);
    });

    test('toJson and fromJson roundtrip', () {
      final original = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['netflix', 'ard_mediathek'],
        favoriteGenreIds: [28, 35],
        minimumRating: 7.5,
      );
      final json = original.toJson();
      final restored = UserPreferences.fromJson(json);

      expect(restored.countryCode, original.countryCode);
      expect(restored.countryName, original.countryName);
      expect(restored.subscribedServiceIds, original.subscribedServiceIds);
      expect(restored.favoriteGenreIds, original.favoriteGenreIds);
      expect(restored.minimumRating, original.minimumRating);
    });

    test('fromJson with empty services should work', () {
      final json = {
        'countryCode': 'DE',
        'countryName': 'Deutschland',
        'subscribedServiceIds': <String>[],
      };
      final prefs = UserPreferences.fromJson(json);
      expect(prefs.subscribedServiceIds, isEmpty);
    });

    group('TMDB provider ID extraction', () {
      test('should extract TMDB IDs from subscribed services', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: ['netflix', 'ard_mediathek', 'zdf_mediathek'],
        );
        final tmdbIds = prefs.subscribedServices
            .where((p) => p.tmdbId != null)
            .map((p) => p.tmdbId!)
            .toList();
        expect(tmdbIds, [8, 219, 537]);
      });

      test('ARD-only should produce ONLY ARD TMDB ID', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: ['ard_mediathek'],
        );
        final tmdbIds = prefs.subscribedServices
            .where((p) => p.tmdbId != null)
            .map((p) => p.tmdbId!)
            .toList();
        expect(tmdbIds, [219]);
        expect(tmdbIds, isNot(contains(537))); // must NOT contain ZDF's ID
      });

      test('ZDF-only should produce ONLY ZDF TMDB ID', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: ['zdf_mediathek'],
        );
        final tmdbIds = prefs.subscribedServices
            .where((p) => p.tmdbId != null)
            .map((p) => p.tmdbId!)
            .toList();
        expect(tmdbIds, [537]);
        expect(tmdbIds, isNot(contains(219))); // must NOT contain ARD's ID
      });

      test('empty services should produce empty TMDB IDs', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
        );
        final tmdbIds = prefs.subscribedServices
            .where((p) => p.tmdbId != null)
            .map((p) => p.tmdbId!)
            .toList();
        expect(tmdbIds, isEmpty);
      });
    });

    test('defaultDE should have includeAdult as false', () {
      final prefs = UserPreferences.defaultDE();
      expect(prefs.includeAdult, isFalse);
    });

    test('copyWith should update includeAdult', () {
      final prefs = UserPreferences.defaultDE();
      final updated = prefs.copyWith(includeAdult: true);
      expect(updated.includeAdult, isTrue);
      expect(updated.countryCode, 'DE'); // unchanged
    });

    test('serialization should handle includeAdult', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: [],
        includeAdult: true,
      );
      final json = prefs.toJson();
      final restored = UserPreferences.fromJson(json);
      expect(restored.includeAdult, isTrue);
    });
  });
}
