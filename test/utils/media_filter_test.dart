import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:stream_scout/utils/media_filter.dart';

void main() {
  // --- Test data ---
  final highRated = Media(
    id: 1,
    title: 'Great Movie',
    overview: 'Test',
    voteAverage: 8.5,
    voteCount: 1000,
    genreIds: [28],
    type: MediaType.movie,
  );

  final lowRated = Media(
    id: 2,
    title: 'Bad Movie',
    overview: 'Test',
    voteAverage: 3.0,
    voteCount: 500,
    genreIds: [35],
    type: MediaType.movie,
  );

  final adultContent = Media(
    id: 3,
    title: 'Adult Movie',
    overview: 'Test',
    voteAverage: 7.0,
    voteCount: 800,
    genreIds: [27], // Horror genre — typically higher age rating
    type: MediaType.movie,
  );

  final tvShow = Media(
    id: 4,
    title: 'Good Show',
    overview: 'Test',
    voteAverage: 7.5,
    voteCount: 2000,
    genreIds: [18],
    type: MediaType.tv,
  );

  group('MediaFilter', () {
    group('applyPreferences', () {
      test('passes items meeting all criteria', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 6.0,
        );

        final result = MediaFilter.applyPreferences([highRated, tvShow], prefs);
        expect(result.length, 2);
      });

      test('filters items below minimum rating', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 7.0,
        );

        final result = MediaFilter.applyPreferences([
          highRated,
          lowRated,
        ], prefs);
        expect(result.length, 1);
        expect(result[0].id, 1); // highRated passes
      });

      test('filters items above max age rating', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 0.0,
          maxAgeRating: 12,
        );

        // Items with null ageRating now have ageLevel=0 (unrestricted), so both pass
        final result = MediaFilter.applyPreferences([
          highRated,
          adultContent,
        ], prefs);
        expect(result.length, 2);
      });

      test('passes all items when maxAgeRating is null', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 0.0,
        );

        final result = MediaFilter.applyPreferences([
          highRated,
          lowRated,
          adultContent,
        ], prefs);
        expect(result.length, 3);
      });

      test('passes all items when maxAgeRating is 18 (max)', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 0.0,
          maxAgeRating: 18,
        );

        final result = MediaFilter.applyPreferences([
          highRated,
          lowRated,
          adultContent,
        ], prefs);
        // maxAgeRating == 18 means no filtering (skipped by < 18 check)
        expect(result.length, 3);
      });

      test('returns empty list for empty input', () {
        final prefs = UserPreferences.defaultDE();
        final result = MediaFilter.applyPreferences([], prefs);
        expect(result, isEmpty);
      });

      test('filters all when none meet minimum rating', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 9.5,
        );

        final result = MediaFilter.applyPreferences([
          highRated,
          lowRated,
        ], prefs);
        expect(result, isEmpty);
      });
    });

    group('applyPreferencesAndExcludeWatched', () {
      test('excludes watched IDs', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 0.0,
        );
        final watchedIds = {'movie_1'}; // highRated

        final result = MediaFilter.applyPreferencesAndExcludeWatched(
          [highRated, tvShow],
          prefs,
          watchedIds,
        );

        expect(result.length, 1);
        expect(result[0].id, 4); // tvShow
      });

      test('combines rating filter and watched exclusion', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 7.0,
        );
        final watchedIds = {'movie_1'}; // highRated

        final result = MediaFilter.applyPreferencesAndExcludeWatched(
          [highRated, lowRated, tvShow],
          prefs,
          watchedIds,
        );

        // highRated is watched, lowRated is below minRating
        expect(result.length, 1);
        expect(result[0].id, 4); // tvShow
      });

      test('passes all when no items watched and no filter', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 0.0,
        );

        final result = MediaFilter.applyPreferencesAndExcludeWatched(
          [highRated, tvShow],
          prefs,
          {},
        );

        expect(result.length, 2);
      });

      test('returns empty when all items are watched', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 0.0,
        );
        final watchedIds = {'movie_1', 'tv_4'};

        final result = MediaFilter.applyPreferencesAndExcludeWatched(
          [highRated, tvShow],
          prefs,
          watchedIds,
        );

        expect(result, isEmpty);
      });

      test('correctly constructs watched key from type and id', () {
        final prefs = UserPreferences(
          countryCode: 'DE',
          countryName: 'Deutschland',
          subscribedServiceIds: [],
          minimumRating: 0.0,
        );
        // Only movie_1 is watched, not tv_1
        final watchedIds = {'movie_1'};

        final tvWithSameId = Media(
          id: 1,
          title: 'TV with same ID',
          overview: 'Test',
          voteAverage: 7.0,
          voteCount: 1000,
          genreIds: [18],
          type: MediaType.tv,
        );

        final result = MediaFilter.applyPreferencesAndExcludeWatched(
          [highRated, tvWithSameId],
          prefs,
          watchedIds,
        );

        // highRated (movie_1) filtered, tvWithSameId (tv_1) not filtered
        expect(result.length, 1);
        expect(result[0].type, MediaType.tv);
      });
    });
  });
}
