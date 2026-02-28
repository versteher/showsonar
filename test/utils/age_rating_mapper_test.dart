import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/utils/age_rating_mapper.dart';

void main() {
  group('AgeRatingMapper', () {
    group('getCertification', () {
      test('returns null for age >= 18', () {
        expect(AgeRatingMapper.getCertification('DE', 18), null);
        expect(AgeRatingMapper.getCertification('US', 18), null);
      });

      test('returns correct DE certifications', () {
        expect(AgeRatingMapper.getCertification('DE', 0), '0');
        expect(AgeRatingMapper.getCertification('DE', 6), '6');
        expect(AgeRatingMapper.getCertification('DE', 12), '12');
        expect(AgeRatingMapper.getCertification('DE', 16), '16');
      });

      test('returns correct US certifications', () {
        expect(AgeRatingMapper.getCertification('US', 0), 'G');
        expect(AgeRatingMapper.getCertification('US', 6), 'PG');
        expect(AgeRatingMapper.getCertification('US', 12), 'PG-13');
        expect(AgeRatingMapper.getCertification('US', 16), 'R');
      });

      test('returns correct GB certifications', () {
        expect(AgeRatingMapper.getCertification('GB', 0), 'U');
        expect(AgeRatingMapper.getCertification('GB', 6), 'U'); // <8 is U
        expect(AgeRatingMapper.getCertification('GB', 8), 'PG');
        expect(AgeRatingMapper.getCertification('GB', 12), '12');
        expect(AgeRatingMapper.getCertification('GB', 15), '15');
      });
    });

    group('getAgeLevel', () {
      test('parses DE certifications', () {
        expect(AgeRatingMapper.getAgeLevel('DE', '0'), 0);
        expect(AgeRatingMapper.getAgeLevel('DE', 'FSK 6'), 6);
        expect(AgeRatingMapper.getAgeLevel('DE', '12'), 12);
        expect(AgeRatingMapper.getAgeLevel('DE', '16'), 16);
        expect(AgeRatingMapper.getAgeLevel('DE', '18'), 18);
      });

      test('parses US certifications', () {
        expect(AgeRatingMapper.getAgeLevel('US', 'G'), 0);
        expect(AgeRatingMapper.getAgeLevel('US', 'PG'), 6);
        expect(AgeRatingMapper.getAgeLevel('US', 'PG-13'), 12);
        expect(AgeRatingMapper.getAgeLevel('US', 'R'), 16);
        expect(AgeRatingMapper.getAgeLevel('US', 'NC-17'), 18);
        expect(AgeRatingMapper.getAgeLevel('US', 'NR'), 100);
      });

      test('handles unknown certifications', () {
        expect(AgeRatingMapper.getAgeLevel('DE', 'Unknown'), 100);
        expect(AgeRatingMapper.getAgeLevel('US', 'Unknown'), 100);
      });

      test('fallback for cross-region parsing (US cert in DE context)', () {
        // Current implementation defaults to numeric parse for DE
        // If "PG-13" is passed to DE, it might fail or return 100
        expect(AgeRatingMapper.getAgeLevel('DE', 'PG-13'), 13);
      });
    });
  });
}
