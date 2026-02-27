import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';
import 'package:neon_voyager/data/models/streaming_provider.dart';

/// Tests for the provider filtering logic used in providers.dart.
///
/// These tests validate the extraction/filtering pattern used by all content
/// providers (trending, popular, genre discover, etc.) without requiring
/// actual Riverpod or TMDB API calls.
void main() {
  /// Helper that replicates the exact provider filtering logic from providers.dart:
  /// ```dart
  ///   final providerIds = prefs.subscribedServices
  ///       .where((p) => p.tmdbId != null)
  ///       .map((p) => p.tmdbId!)
  ///       .toList();
  /// ```
  List<int> extractTmdbIds(UserPreferences prefs) {
    return prefs.subscribedServices
        .where((p) => p.tmdbId != null)
        .map((p) => p.tmdbId!)
        .toList();
  }

  group('Provider Filtering Logic', () {
    test('no services selected → empty list (should return no content)', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: [],
      );
      final ids = extractTmdbIds(prefs);
      expect(
        ids,
        isEmpty,
        reason:
            'Empty services must produce empty TMDB IDs → providers return []',
      );
    });

    test('single commercial provider → correct single TMDB ID', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['netflix'],
      );
      final ids = extractTmdbIds(prefs);
      expect(ids, [8]);
    });

    test('ARD only → only ARD TMDB ID (219), NOT ZDF (537)', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['ard_mediathek'],
      );
      final ids = extractTmdbIds(prefs);
      expect(ids, [219]);
      expect(ids, isNot(contains(537)));
    });

    test('ZDF only → only ZDF TMDB ID (537), NOT ARD (219)', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['zdf_mediathek'],
      );
      final ids = extractTmdbIds(prefs);
      expect(ids, [537]);
      expect(ids, isNot(contains(219)));
    });

    test('ARD + ZDF → both TMDB IDs, different values', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['ard_mediathek', 'zdf_mediathek'],
      );
      final ids = extractTmdbIds(prefs);
      expect(ids, [219, 537]);
      expect(ids.toSet().length, 2, reason: 'Must be two different IDs');
    });

    test('all 42 services selected → 42 unique TMDB IDs', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: StreamingProvider.allProviders
            .map((p) => p.id)
            .toList(),
      );
      final ids = extractTmdbIds(prefs);
      expect(ids.length, 42);
      expect(ids.toSet().length, 42, reason: 'All TMDB IDs must be unique');
    });

    test('unknown service IDs are silently skipped', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['netflix', 'fake_service', 'ard_mediathek'],
      );
      final ids = extractTmdbIds(prefs);
      expect(ids, [8, 219]);
    });

    test('only public broadcasters → correct broadcaster IDs', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['ard_mediathek', 'zdf_mediathek', 'arte'],
      );
      final ids = extractTmdbIds(prefs);
      expect(ids, [219, 537, 234]);
    });

    test('default DE prefs → 4 commercial TMDB IDs', () {
      final prefs = UserPreferences.defaultDE();
      final ids = extractTmdbIds(prefs);
      expect(ids, [8, 337, 9, 350]); // Netflix, Disney+, Amazon, Apple TV+
    });
  });

  group('Provider filtering decision: isEmpty check', () {
    test('empty providerIds.isEmpty == true → should return empty results', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: [],
      );
      final providerIds = extractTmdbIds(prefs);
      // This simulates the check in each provider
      expect(providerIds.isEmpty, isTrue);
    });

    test('one service selected → providerIds.isEmpty == false', () {
      final prefs = UserPreferences(
        countryCode: 'DE',
        countryName: 'Deutschland',
        subscribedServiceIds: ['ard_mediathek'],
      );
      final providerIds = extractTmdbIds(prefs);
      expect(providerIds.isEmpty, isFalse);
    });
  });
}
