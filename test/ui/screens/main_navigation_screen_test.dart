import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stream_scout/ui/screens/main_navigation_screen.dart';
import 'package:stream_scout/utils/analytics_service.dart';
import 'package:stream_scout/config/providers.dart';

import '../../utils/test_app_wrapper.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late MockAnalyticsService mockAnalytics;
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });
  setUp(() {
    mockAnalytics = MockAnalyticsService();
    when(() => mockAnalytics.logScreenView(any())).thenAnswer((_) async {});
  });

  testWidgets('renders 5 tabs and switches pages', (tester) async {
    // 5 screens: Home, Search, Library, Social, Profile
    final screens = [
      const Text('Home Screen Tab'),
      const Text('Search Screen Tab'),
      const Text('Library Screen Tab'),
      const Text('Social Screen Tab'),
      const Text('Profile Screen Tab'),
    ];

    await tester.pumpWidget(
      pumpAppScreen(
        child: MainNavigationScreen(
          analyticsService: mockAnalytics,
          testScreens: screens,
        ),
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value([ConnectivityResult.wifi]),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Home Screen Tab'), findsOneWidget);

    // Tap the Profile tab (person icon — index 3)
    final profileIcon = find.byWidgetPredicate(
      (widget) =>
          widget is Icon &&
          (widget.icon == Icons.person_rounded ||
              widget.icon == Icons.person_outline_rounded),
    );
    await tester.tap(profileIcon.last);
    await tester.pumpAndSettle();

    expect(find.text('Profile Screen Tab'), findsOneWidget);
  });
}
