import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/config/api_config.dart';

void main() {
  group('ApiConfig', () {
    // Proxy URL construction
    group('proxy URLs', () {
      test('tmdbBaseUrl routes through proxy', () {
        // In tests no PROXY_URL dart-define is set, so falls back to localhost:8080
        expect(ApiConfig.tmdbBaseUrl, contains('/tmdb'));
        expect(ApiConfig.tmdbBaseUrl, startsWith('http'));
      });

      test('geminiBaseUrl routes through proxy', () {
        expect(ApiConfig.geminiBaseUrl, contains('/gemini'));
      });

      test('omdbBaseUrl routes through proxy', () {
        expect(ApiConfig.omdbBaseUrl, contains('/omdb'));
      });

      test('all proxy URLs share the same base host', () {
        final tmdbBase = Uri.parse(ApiConfig.tmdbBaseUrl).host;
        final geminiBase = Uri.parse(ApiConfig.geminiBaseUrl).host;
        final omdbBase = Uri.parse(ApiConfig.omdbBaseUrl).host;
        expect(geminiBase, tmdbBase);
        expect(omdbBase, tmdbBase);
      });
    });

    // Feature flags
    group('feature flags', () {
      test('isTmdbConfigured is always true (proxy manages keys)', () {
        expect(ApiConfig.isTmdbConfigured, isTrue);
      });

      test('isGeminiConfigured is always true', () {
        expect(ApiConfig.isGeminiConfigured, isTrue);
      });

      test('isOmdbConfigured is always true', () {
        expect(ApiConfig.isOmdbConfigured, isTrue);
      });
    });

    // Image CDN (unchanged — no key required)
    test('tmdbImageBaseUrl is correct', () {
      expect(ApiConfig.tmdbImageBaseUrl, 'https://image.tmdb.org/t/p');
    });

    test('defaultLanguage is de-DE', () {
      expect(ApiConfig.defaultLanguage, 'de-DE');
    });

    test('defaultRegion is DE', () {
      expect(ApiConfig.defaultRegion, 'DE');
    });

    test('image size constants are defined', () {
      expect(ApiConfig.posterSizeSmall, 'w185');
      expect(ApiConfig.posterSizeMedium, 'w342');
      expect(ApiConfig.posterSizeLarge, 'w500');
      expect(ApiConfig.posterSizeOriginal, 'original');
      expect(ApiConfig.backdropSizeMedium, 'w780');
      expect(ApiConfig.backdropSizeOriginal, 'original');
    });

    group('getPosterUrl', () {
      test('returns full URL for valid path', () {
        expect(
          ApiConfig.getPosterUrl('/poster.jpg'),
          'https://image.tmdb.org/t/p/w500/poster.jpg',
        );
      });

      test('returns full URL with custom size', () {
        expect(
          ApiConfig.getPosterUrl('/poster.jpg', size: 'w185'),
          'https://image.tmdb.org/t/p/w185/poster.jpg',
        );
      });

      test('returns empty string for null path', () {
        expect(ApiConfig.getPosterUrl(null), '');
      });

      test('returns empty string for empty path', () {
        expect(ApiConfig.getPosterUrl(''), '');
      });
    });

    group('getBackdropUrl', () {
      test('returns full URL for valid path', () {
        expect(
          ApiConfig.getBackdropUrl('/backdrop.jpg'),
          'https://image.tmdb.org/t/p/original/backdrop.jpg',
        );
      });

      test('returns full URL with custom size', () {
        expect(
          ApiConfig.getBackdropUrl('/backdrop.jpg', size: 'w780'),
          'https://image.tmdb.org/t/p/w780/backdrop.jpg',
        );
      });

      test('returns empty string for null path', () {
        expect(ApiConfig.getBackdropUrl(null), '');
      });

      test('returns empty string for empty path', () {
        expect(ApiConfig.getBackdropUrl(''), '');
      });
    });
  });
}
