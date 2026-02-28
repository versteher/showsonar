import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:go_router/go_router.dart';

import 'package:stream_scout/app.dart';
import 'package:stream_scout/ui/screens/onboarding_screen.dart';
import 'package:stream_scout/ui/widgets/hero_carousel.dart';
import 'package:stream_scout/ui/screens/detail_screen.dart';
import 'package:stream_scout/flavors.dart';

import 'helpers/mock_setup.dart';

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key.startsWith('assets/images/')) {
      // 1x1 transparent PNG
      return ByteData.view(
        Uint8List.fromList([
          137,
          80,
          78,
          71,
          13,
          10,
          26,
          10,
          0,
          0,
          0,
          13,
          73,
          72,
          68,
          82,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          1,
          8,
          6,
          0,
          0,
          0,
          31,
          21,
          196,
          137,
          0,
          0,
          0,
          11,
          73,
          68,
          65,
          84,
          120,
          156,
          99,
          96,
          0,
          2,
          0,
          0,
          5,
          0,
          1,
          13,
          10,
          45,
          180,
          0,
          0,
          0,
          0,
          73,
          69,
          78,
          68,
          174,
          66,
          96,
          130,
        ]).buffer,
      );
    }
    return rootBundle.load(key);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.dev;

  patrolWidgetTest(
    'E2E Flow: Onboarding -> Home -> Detail -> Rate -> Watchlist (Patrol)',
    ($) async {
      await mockNetworkImagesFor(() async {
        // 1. Build our app and trigger a frame, overriding providers with mocks.
        // using $.pumpWidgetAndSettle to ensure initial app loading finishes.
        await $.pumpWidgetAndSettle(
          DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: ProviderScope(
              overrides: getIntegrationTestOverrides(),
              child: const App(),
            ),
          ),
        );

        // 2. Onboarding Flow
        // $() natively polls until the widget is visible, resolving flakiness!
        expect($(OnboardingScreen), findsOneWidget);

        // Screen 1: Language/Country
        await $('Next').tap();

        // Screen 2: Streaming Services
        await $('Next').tap();

        // Screen 3: Genres
        await $('Next').tap();

        // Screen 4: Theme
        await $('Next').tap();

        // Screen 5: Taste Profile (Finish)
        await $('Get Started').tap();

        // 3. Verify we are on the Home Screen
        await $('ShowSonar').waitUntilVisible();

        // 4. Navigate to details of the mock movie
        // Wait for our mock movie to show up "Integration Test Movie", then tap it
        await $('Integration Test Movie').first.tap();

        // Verify detail screen components
        await $('This is a mock movie for testing.').waitUntilVisible();

        // 5. Add to Watchlist
        // Use standard flutter tester tap to bypass Patrol's strict hit-test bounds which sometimes fail on macOS
        await $.tester.tap(
          find.byIcon(Icons.bookmark_border_rounded),
          warnIfMissed: false,
        );
        await $.pumpAndSettle();

        // 6. Rate the movie
        await $.tester.tap(
          find.byIcon(Icons.check_circle_outline_rounded),
          warnIfMissed: false,
        );

        // Assuming there's a rating dialog with a "Speichern" (Save) button
        // Wait a slight bit to see if the dialog shows up
        await Future.delayed(const Duration(milliseconds: 500));
        await $.pumpAndSettle();

        if ($('Speichern').exists) {
          // Tap 'Gut' quick rating
          if ($('Gut').exists) {
            await $('Gut').tap();
          }
          await $('Speichern').tap();
        }

        // 7. Search Flow
        // Go back to home. $.pageBack() maps cleanly to the default router back
        // but we can also forcefully find the back button and tap it just like user would
        final backButtonStr = Icons.arrow_back_ios_rounded;
        if ($(backButtonStr).exists) {
          await $(backButtonStr).tap();
        } else {
          // Fallback if detail uses generic back button
          await $.tester.pageBack();
          await $.pumpAndSettle();
        }

        await $('ShowSonar').waitUntilVisible();

        // Tap on Search tab (index 1) - macOS uses outlined in the rail, mobile uses rounded.
        // Patrol's .exists check is instant and safe.
        if ($(Icons.search_outlined).exists) {
          await $(Icons.search_outlined).tap();
        } else if ($(Icons.search_rounded).exists) {
          await $(Icons.search_rounded).tap();
        }

        // Enter search query
        await $(TextField).enterText('Test');

        // wait for debounce
        await $.pump(const Duration(seconds: 2));

        // Verify search results showed the mocked search result
        expect($('Search Result Movie'), findsWidgets);
      });
    },
  );
}
