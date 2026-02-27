import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/constants/countries.dart';

void main() {
  group('netflixCountries', () {
    test('list is not empty', () {
      expect(netflixCountries, isNotEmpty);
    });

    test('has reasonable number of countries', () {
      // Netflix is available in 190+ countries
      expect(netflixCountries.length, greaterThan(100));
    });

    test('all entries have required fields', () {
      for (final country in netflixCountries) {
        expect(country['code'], isNotNull, reason: 'Missing code for $country');
        expect(country['name'], isNotNull, reason: 'Missing name for $country');
        expect(country['flag'], isNotNull, reason: 'Missing flag for $country');
        expect(
          country['code']!.length,
          2,
          reason: 'Code should be 2 letters: ${country['code']}',
        );
        expect(
          country['name']!.isNotEmpty,
          isTrue,
          reason: 'Name should not be empty',
        );
      }
    });

    test('no duplicate country codes', () {
      final codes = netflixCountries.map((c) => c['code']).toList();
      expect(
        codes.toSet().length,
        codes.length,
        reason: 'Duplicate codes found',
      );
    });

    test('contains key countries', () {
      final codes = netflixCountries.map((c) => c['code']).toSet();
      expect(codes, contains('DE'), reason: 'Missing Germany');
      expect(codes, contains('US'), reason: 'Missing USA');
      expect(codes, contains('GB'), reason: 'Missing UK');
      expect(codes, contains('FR'), reason: 'Missing France');
      expect(codes, contains('JP'), reason: 'Missing Japan');
      expect(codes, contains('BR'), reason: 'Missing Brazil');
      expect(codes, contains('IN'), reason: 'Missing India');
      expect(codes, contains('AU'), reason: 'Missing Australia');
    });

    test('Germany entry has correct German name', () {
      final de = netflixCountries.firstWhere((c) => c['code'] == 'DE');
      expect(de['name'], 'Deutschland');
      expect(de['flag'], '🇩🇪');
    });

    test('USA entry has correct name', () {
      final us = netflixCountries.firstWhere((c) => c['code'] == 'US');
      expect(us['name'], 'USA');
      expect(us['flag'], '🇺🇸');
    });

    test('all country codes are uppercase', () {
      for (final country in netflixCountries) {
        expect(
          country['code'],
          equals(country['code']!.toUpperCase()),
          reason: 'Code should be uppercase: ${country['code']}',
        );
      }
    });

    test('all flags are non-empty emoji strings', () {
      for (final country in netflixCountries) {
        expect(
          country['flag']!.isNotEmpty,
          isTrue,
          reason: 'Flag should not be empty for ${country['code']}',
        );
      }
    });
  });
}
