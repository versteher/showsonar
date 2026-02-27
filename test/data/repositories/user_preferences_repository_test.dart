import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';
import 'package:neon_voyager/data/models/streaming_provider.dart';
import 'package:neon_voyager/data/repositories/user_preferences_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserPreferencesRepository repo;
  const userId = 'guest';

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    repo = UserPreferencesRepository(userId, firestore: fakeFirestore);
    await repo.init();
  });

  group('UserPreferencesRepository', () {
    group('getPreferences', () {
      test('returns defaultDE when no preferences saved', () async {
        final prefs = await repo.getPreferences();

        expect(prefs.countryCode, 'DE');
        expect(prefs.countryName, 'Deutschland');
      });
    });

    group('savePreferences / getPreferences round-trip', () {
      test('saves and retrieves preferences correctly', () async {
        final prefs = UserPreferences(
          countryCode: 'AT',
          countryName: 'Österreich',
          subscribedServiceIds: ['netflix', 'disney'],
          minimumRating: 6.5,
          maxAgeRating: 16,
          favoriteGenreIds: [28, 18],
        );

        await repo.savePreferences(prefs);
        final retrieved = await repo.getPreferences();

        expect(retrieved.countryCode, 'AT');
        expect(retrieved.countryName, 'Österreich');
        expect(retrieved.subscribedServiceIds, ['netflix', 'disney']);
        expect(retrieved.minimumRating, 6.5);
        expect(retrieved.maxAgeRating, 16);
        expect(retrieved.favoriteGenreIds, [28, 18]);
      });
    });

    group('hasPreferences', () {
      test('returns false when no preferences saved', () async {
        expect(await repo.hasPreferences(), isFalse);
      });

      test('returns true after saving preferences', () async {
        await repo.savePreferences(UserPreferences.defaultDE());
        expect(await repo.hasPreferences(), isTrue);
      });
    });

    group('updateCountry', () {
      test('updates country code and name', () async {
        await repo.savePreferences(UserPreferences.defaultDE());

        await repo.updateCountry('AT', 'Österreich');

        final prefs = await repo.getPreferences();
        expect(prefs.countryCode, 'AT');
        expect(prefs.countryName, 'Österreich');
      });

      test(
        'resets services to country defaults when updating country',
        () async {
          final initial = UserPreferences(
            countryCode: 'DE',
            countryName: 'Deutschland',
            subscribedServiceIds: ['netflix'],
            minimumRating: 7.0,
          );
          await repo.savePreferences(initial);

          await repo.updateCountry('CH', 'Schweiz');

          final prefs = await repo.getPreferences();
          expect(prefs.countryCode, 'CH');
          // updateCountry resets services to country defaults
          expect(
            prefs.subscribedServiceIds,
            StreamingProvider.getDefaultServiceIds('CH'),
          );
          expect(prefs.minimumRating, 7.0);
        },
      );
    });

    group('addStreamingService', () {
      test('adds a new streaming service', () async {
        await repo.savePreferences(UserPreferences.defaultDE());

        await repo.addStreamingService('netflix');

        final prefs = await repo.getPreferences();
        expect(prefs.subscribedServiceIds, contains('netflix'));
      });

      test(
        'is idempotent — adding same service twice does not duplicate',
        () async {
          await repo.savePreferences(UserPreferences.defaultDE());

          await repo.addStreamingService('netflix');
          await repo.addStreamingService('netflix');

          final prefs = await repo.getPreferences();
          final count = prefs.subscribedServiceIds
              .where((id) => id == 'netflix')
              .length;
          expect(count, 1);
        },
      );
    });

    group('removeStreamingService', () {
      test('removes an existing streaming service', () async {
        final initial = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: ['netflix', 'disney'],
        );
        await repo.savePreferences(initial);

        await repo.removeStreamingService('netflix');

        final prefs = await repo.getPreferences();
        expect(prefs.subscribedServiceIds, ['disney']);
      });

      test('does nothing when removing non-existent service', () async {
        final initial = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: ['netflix'],
        );
        await repo.savePreferences(initial);

        await repo.removeStreamingService('hulu');

        final prefs = await repo.getPreferences();
        expect(prefs.subscribedServiceIds, ['netflix']);
      });
    });

    group('updateMinimumRating', () {
      test('updates the minimum rating', () async {
        await repo.savePreferences(UserPreferences.defaultDE());

        await repo.updateMinimumRating(7.5);

        final prefs = await repo.getPreferences();
        expect(prefs.minimumRating, 7.5);
      });
    });

    group('updateMaxAgeRating', () {
      test('sets the max age rating', () async {
        await repo.savePreferences(UserPreferences.defaultDE());

        await repo.updateMaxAgeRating(12);

        final prefs = await repo.getPreferences();
        expect(prefs.maxAgeRating, 12);
      });

      test('can change age rating value', () async {
        final initial = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          maxAgeRating: 16,
        );
        await repo.savePreferences(initial);

        await repo.updateMaxAgeRating(12);

        final prefs = await repo.getPreferences();
        expect(prefs.maxAgeRating, 12);
      });

      test('null keeps existing value (copyWith semantics)', () async {
        final initial = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          maxAgeRating: 16,
        );
        await repo.savePreferences(initial);

        // copyWith with null preserves existing value
        await repo.updateMaxAgeRating(null);

        final prefs = await repo.getPreferences();
        expect(prefs.maxAgeRating, 16); // unchanged
      });
    });

    group('addFavoriteGenre', () {
      test('adds a genre to favorites', () async {
        await repo.savePreferences(UserPreferences.defaultDE());

        await repo.addFavoriteGenre(28);

        final prefs = await repo.getPreferences();
        expect(prefs.favoriteGenreIds, contains(28));
      });

      test(
        'is idempotent — adding same genre twice does not duplicate',
        () async {
          await repo.savePreferences(UserPreferences.defaultDE());

          await repo.addFavoriteGenre(28);
          await repo.addFavoriteGenre(28);

          final prefs = await repo.getPreferences();
          final count = prefs.favoriteGenreIds.where((id) => id == 28).length;
          expect(count, 1);
        },
      );
    });

    group('removeFavoriteGenre', () {
      test('removes a genre from favorites', () async {
        final initial = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          favoriteGenreIds: [28, 18],
        );
        await repo.savePreferences(initial);

        await repo.removeFavoriteGenre(28);

        final prefs = await repo.getPreferences();
        expect(prefs.favoriteGenreIds, [18]);
      });
    });

    group('resetToDefaults', () {
      test('resets to default DE preferences', () async {
        final custom = UserPreferences(
          countryCode: 'AT',
          countryName: 'Österreich',
          subscribedServiceIds: ['netflix'],
          minimumRating: 8.0,
        );
        await repo.savePreferences(custom);

        await repo.resetToDefaults();

        final prefs = await repo.getPreferences();
        expect(prefs.countryCode, 'DE');
        expect(prefs.countryName, 'Deutschland');
      });
    });

    group('clear', () {
      test('removes all preferences', () async {
        await repo.savePreferences(UserPreferences.defaultDE());
        expect(await repo.hasPreferences(), isTrue);

        await repo.clear();

        expect(await repo.hasPreferences(), isFalse);
      });
    });
  });
}
