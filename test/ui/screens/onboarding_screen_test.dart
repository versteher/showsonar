import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_scout/ui/screens/onboarding_screen.dart';
import 'package:network_image_mock/network_image_mock.dart';

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
          8,
          215,
          99,
          96,
          0,
          2,
          0,
          0,
          5,
          0,
          1,
          226,
          38,
          5,
          155,
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
  testWidgets('OnboardingScreen has 3 pages and allows navigation', (
    WidgetTester tester,
  ) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: DefaultAssetBundle(
              bundle: TestAssetBundle(),
              child: const OnboardingScreen(),
            ),
          ),
        ),
      );

      // Page 1: Location + Streaming (combined)
      expect(find.text('Welcome to ShowSonar'), findsOneWidget);
      expect(find.text('Your Services'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Back'), findsNothing);

      // Tap Next → Page 2: Genres
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Favorite Genres'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Tap Next → Page 3: Done
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text("You're All Set!"), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      // No Skip on final page
      expect(find.text('Skip'), findsNothing);

      // Can navigate back to Genres
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Favorite Genres'), findsOneWidget);
    });
  });
}
