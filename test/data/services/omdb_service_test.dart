import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/services/omdb_service.dart';

/// Tests for OmdbRatings model — parsing and computed properties.
/// HTTP-level integration tests are not included since they require
/// a live OMDb API key. These tests cover the data model thoroughly.
void main() {
  group('OmdbRatings', () {
    group('hasTomatometer', () {
      test('true when tomatometer is set', () {
        const ratings = OmdbRatings(tomatometer: '94%');
        expect(ratings.hasTomatometer, isTrue);
      });

      test('false when tomatometer is null', () {
        const ratings = OmdbRatings();
        expect(ratings.hasTomatometer, isFalse);
      });
    });

    group('hasAudienceScore', () {
      test('true when audienceScore is set', () {
        const ratings = OmdbRatings(audienceScore: '88%');
        expect(ratings.hasAudienceScore, isTrue);
      });

      test('false when audienceScore is null', () {
        const ratings = OmdbRatings();
        expect(ratings.hasAudienceScore, isFalse);
      });
    });

    group('hasAnyRating', () {
      test('true with only tomatometer', () {
        const ratings = OmdbRatings(tomatometer: '94%');
        expect(ratings.hasAnyRating, isTrue);
      });

      test('true with only audienceScore', () {
        const ratings = OmdbRatings(audienceScore: '88%');
        expect(ratings.hasAnyRating, isTrue);
      });

      test('true with only metacritic', () {
        const ratings = OmdbRatings(metacritic: '74/100');
        expect(ratings.hasAnyRating, isTrue);
      });

      test('true with all ratings', () {
        const ratings = OmdbRatings(
          tomatometer: '94%',
          audienceScore: '88%',
          metacritic: '74/100',
        );
        expect(ratings.hasAnyRating, isTrue);
      });

      test('false with no ratings', () {
        const ratings = OmdbRatings();
        expect(ratings.hasAnyRating, isFalse);
      });
    });

    group('tomatometerInt', () {
      test('parses percentage string correctly', () {
        const ratings = OmdbRatings(tomatometer: '94%');
        expect(ratings.tomatometerInt, 94);
      });

      test('parses 100%', () {
        const ratings = OmdbRatings(tomatometer: '100%');
        expect(ratings.tomatometerInt, 100);
      });

      test('parses 0%', () {
        const ratings = OmdbRatings(tomatometer: '0%');
        expect(ratings.tomatometerInt, 0);
      });

      test('returns null when tomatometer is null', () {
        const ratings = OmdbRatings();
        expect(ratings.tomatometerInt, isNull);
      });

      test('handles string with spaces', () {
        const ratings = OmdbRatings(tomatometer: ' 85% ');
        expect(ratings.tomatometerInt, 85);
      });
    });

    group('audienceScoreInt', () {
      test('parses percentage string correctly', () {
        const ratings = OmdbRatings(audienceScore: '88%');
        expect(ratings.audienceScoreInt, 88);
      });

      test('returns null when audienceScore is null', () {
        const ratings = OmdbRatings();
        expect(ratings.audienceScoreInt, isNull);
      });

      test('handles string with spaces', () {
        const ratings = OmdbRatings(audienceScore: ' 72% ');
        expect(ratings.audienceScoreInt, 72);
      });
    });

    group('combined scenarios', () {
      test('typical movie with all ratings', () {
        const ratings = OmdbRatings(
          tomatometer: '87%',
          audienceScore: '78%',
          metacritic: '68/100',
        );
        expect(ratings.hasTomatometer, isTrue);
        expect(ratings.hasAudienceScore, isTrue);
        expect(ratings.hasAnyRating, isTrue);
        expect(ratings.tomatometerInt, 87);
        expect(ratings.audienceScoreInt, 78);
      });

      test('movie with only metacritic', () {
        const ratings = OmdbRatings(metacritic: '74/100');
        expect(ratings.hasTomatometer, isFalse);
        expect(ratings.hasAudienceScore, isFalse);
        expect(ratings.hasAnyRating, isTrue);
        expect(ratings.tomatometerInt, isNull);
        expect(ratings.audienceScoreInt, isNull);
      });
    });
  });
}
