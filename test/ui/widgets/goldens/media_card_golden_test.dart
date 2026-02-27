import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/ui/widgets/media_card.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';
import 'package:neon_voyager/data/models/streaming_provider.dart';
import 'package:flutter/services.dart';

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return ByteData.view(Uint8List(0).buffer);
  }
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('MediaCard - Light and Dark Themes', (tester) async {
    final testMedia = Media(
      id: 1,
      title: 'Inception',
      overview: 'A thief who steals corporate secrets...',
      // Providing an empty string bypasses TMDB network cache hanging in test environments
      posterPath: '',
      genreIds: [28, 878],
      type: MediaType.movie,
      voteAverage: 8.8,
      voteCount: 30000,
      popularity: 350.0,
      releaseDate: DateTime(2010, 7, 16),
      runtime: 148,
    );

    // Provide a mocked network image so we don't try to load from TMDB during golden generation
    final widget = ProviderScope(
      overrides: [
        mediaAvailabilityProvider.overrideWith(
          (ref, _) =>
              Future<
                List<({StreamingProvider provider, String logoUrl})>
              >.value([]),
        ),
        userPreferencesProvider.overrideWith(
          (ref) => Future<UserPreferences>.value(
            const UserPreferences(
              countryCode: 'US',
              countryName: 'United States',
              subscribedServiceIds: [],
            ),
          ),
        ),
      ],
      child: Localizations(
        locale: const Locale('en'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Material(
          color: Colors.transparent,
          child: MediaCard(
            media: testMedia,
            width: 140, // standard width
            enableHero: false,
          ),
        ),
      ),
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: widget),
      );
      await screenMatchesGolden(tester, 'media_card_isolated');
    });
  });
}
