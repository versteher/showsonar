// Widget tests require Hive initialization.
// See integration_test/ for full app testing.
// Unit tests for models and services are in test/data/

import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/streaming_provider.dart';
import 'package:neon_voyager/ui/theme/app_theme.dart';

void main() {
  group('App Components', () {
    test('MediaType has correct display names', () {
      expect(MediaType.movie.displayName, 'Movie');
      expect(MediaType.tv.displayName, 'TV Series');
    });

    test('StreamingProvider has all required providers', () {
      expect(StreamingProvider.allProviders.length, 42);
      expect(
        StreamingProvider.allProviders.map((p) => p.id).toList(),
        containsAll(['netflix', 'disney_plus', 'amazon_prime', 'hbo_max']),
      );
    });

    test('AppTheme provides correct rating colors', () {
      expect(AppTheme.getRatingColor(8.0), AppTheme.ratingHigh);
      expect(AppTheme.getRatingColor(6.0), AppTheme.ratingMedium);
      expect(AppTheme.getRatingColor(4.0), AppTheme.ratingLow);
    });

    test('AppTheme has correct brand colors', () {
      expect(AppTheme.primary, isNotNull);
      expect(AppTheme.secondary, isNotNull);
      expect(AppTheme.background, isNotNull);
      expect(AppTheme.surface, isNotNull);
    });

    test('AppTheme spacing constants are defined', () {
      expect(AppTheme.spacingXs, 4.0);
      expect(AppTheme.spacingSm, 8.0);
      expect(AppTheme.spacingMd, 16.0);
      expect(AppTheme.spacingLg, 24.0);
      expect(AppTheme.spacingXl, 32.0);
    });
  });
}
