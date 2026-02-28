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
  testWidgets('OnboardingScreen displays 5 pages and allows navigation', (
    WidgetTester tester,
  ) async {
    await mockNetworkImagesFor(() async {
      // Build the app with ProviderScope
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

      // Page 1: Location Page
      expect(find.text('Welcome to StreamScout'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Back'), findsNothing);

      // Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 2: Streaming Providers
      expect(find.text('Your Services'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Need to select at least one provider to continue
      // It should have selected defaults

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 3: Genres
      expect(find.text('Favorite Genres'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 4: Theme
      expect(find.text('Choose a Theme'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 5: Taste Profile Import & Get Started
      expect(find.text('You\'re All Set!'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Can navigate back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a Theme'), findsOneWidget);
    });
  });
}
