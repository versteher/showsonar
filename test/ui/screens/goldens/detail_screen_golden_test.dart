import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:neon_voyager/ui/screens/detail_screen.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';
import 'package:neon_voyager/data/models/streaming_provider.dart';
import 'package:neon_voyager/data/repositories/watchlist_repository.dart';
import 'package:neon_voyager/ui/theme/app_theme.dart';
import 'package:neon_voyager/ui/widgets/rt_scores_badge.dart';

import '../../../utils/test_app_wrapper.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  setUpAll(() async {
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = Duration.zero;
    await loadAppFonts();
  });

  testGoldens('DetailScreen - Light and Dark Themes', (tester) async {
    final mockWatchlistRepo = MockWatchlistRepository();

    final mockMedia = Media(
      id: 123,
      title: 'Golden Movie',
      overview: 'A breathtaking adventure across the golden dimensions.',
      posterPath: null, // Bypass network
      backdropPath: null, // Bypass network
      voteAverage: 9.3,
      releaseDate: DateTime(2024, 5, 20),
      type: MediaType.movie,
      genreIds: [28, 878], // Action, Sci-Fi
      popularity: 500.0,
      voteCount: 15400,
      runtime: 142,
      ageRating: 'PG-13',
    );

    final mockSimilar = <Media>[
      Media(
        id: 456,
        title: 'Similar Adventure',
        overview: 'Another cool adventure.',
        posterPath: null, // Bypass network
        backdropPath: null,
        voteAverage: 8.1,
        releaseDate: DateTime(2023, 8, 11),
        type: MediaType.movie,
        genreIds: [28],
        voteCount: 3200,
      ),
    ];

    final overrides = [
      mediaDetailsProvider((
        id: 123,
        type: MediaType.movie,
      )).overrideWith((ref) => Future.value(mockMedia)),
      similarContentProvider((
        id: 123,
        type: MediaType.movie,
      )).overrideWith((ref) => Future.value(mockSimilar)),
      watchHistoryEntryProvider((
        id: 123,
        type: MediaType.movie,
      )).overrideWith((ref) => Future.value(null)),
      isOnWatchlistProvider((
        id: 123,
        type: MediaType.movie,
      )).overrideWith((ref) => Future.value(false)),
      userPreferencesProvider.overrideWith(
        (ref) => Future.value(
          const UserPreferences(
            countryCode: 'US',
            countryName: 'United States',
            subscribedServiceIds: [],
          ),
        ),
      ),
      mediaAvailabilityProvider((id: 123, type: MediaType.movie)).overrideWith(
        (ref) =>
            Future<List<({StreamingProvider provider, String logoUrl})>>.value(
              [],
            ),
      ),
      watchlistRepositoryProvider.overrideWithValue(mockWatchlistRepo),
      trailerUrlProvider((
        id: 123,
        type: MediaType.movie,
      )).overrideWith((ref) => Future.value(null)),
      omdbRatingsProvider((
        imdbId: null,
        title: 'Golden Movie',
        year: 2024,
      )).overrideWith((ref) => Future.value(null)),
    ];

    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [Device.phone, Device.iphone11])
      ..addScenario(
        widget: Theme(
          data: AppTheme.lightTheme,
          child: pumpAppScreen(
            child: const DetailScreen(mediaId: 123, mediaType: MediaType.movie),
            overrides: overrides,
          ),
        ),
        name: 'Light Theme',
      )
      ..addScenario(
        widget: Theme(
          data: AppTheme.darkTheme,
          child: pumpAppScreen(
            child: const DetailScreen(mediaId: 123, mediaType: MediaType.movie),
            overrides: overrides,
          ),
        ),
        name: 'Dark Theme',
      );

    await tester.pumpDeviceBuilder(builder);

    // Let the Futures resolve and animations settle
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    await screenMatchesGolden(tester, 'detail_screen');
  });
}
