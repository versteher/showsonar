import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stream_scout/ui/screens/settings_screen.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/test_app_wrapper.dart';

void main() {
  setUpAll(() {
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = Duration.zero; // Disable animations
  });

  final mockPrefs = UserPreferences(
    subscribedServiceIds: ['8', '9'], // Netflix, Amazon
    themeMode: 'dark',
    countryCode: 'DE',
    countryName: 'Germany',
  );

  group('SettingsScreen Widget Tests', () {
    testWidgets('renders all settings sections', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const SettingsScreen(),
          overrides: [
            userPreferencesProvider.overrideWith(
              (ref) => Future.value(mockPrefs),
            ),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        ),
      );

      // Settle loading state
      await tester.pumpAndSettle();

      // Check for theme toggles
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Use scrolling since settings is a long list
      final listFinder = find.byType(Scrollable);

      // Check for Account section
      await tester.scrollUntilVisible(
        find.text('Not Signed In'),
        500,
        scrollable: listFinder,
      );
      expect(find.text('Not Signed In'), findsOneWidget);

      // Check for Taste Profil
      await tester.scrollUntilVisible(
        find.text('Profil teilen & vergleichen'),
        500,
        scrollable: listFinder,
      );
      expect(find.text('Profil teilen & vergleichen'), findsOneWidget);
    });
  });
}
