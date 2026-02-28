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

  testWidgets('renders tabs and switches pages', (tester) async {
    final screens = [
      const Text('Home Screen Tab'),
      const Text('Search Screen Tab'),
      const Text('AI Chat Screen Tab'),
      const Text('My List Screen Tab'),
      const Text('Settings Screen Tab'),
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

    final settingsIcon = find.byWidgetPredicate(
      (widget) =>
          widget is Icon &&
          (widget.icon == Icons.settings_rounded ||
              widget.icon == Icons.settings_outlined),
    );
    await tester.tap(settingsIcon.last);
    await tester.pumpAndSettle();

    expect(find.text('Settings Screen Tab'), findsOneWidget);
  });
}
