import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/ui/screens/main_navigation_screen.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import 'package:stream_scout/utils/analytics_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockAnalytics = MockAnalyticsService();
    when(() => mockAnalytics.logScreenView(any())).thenAnswer((_) async {});
  });

  Widget buildTestWidget({String locale = 'en'}) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(locale),
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MainNavigationScreen(
            analyticsService: mockAnalytics,
            testScreens: List.generate(
              5,
              (_) => const Scaffold(body: SizedBox.shrink()),
            ),
          ),
        ),
      ),
    );
  }

  group('MainNavigationScreen accessibility', () {
    testWidgets('all nav items have accessible labels', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // The nav labels in EN
      const navLabels = ['Home', 'Search', 'AI', 'My List', 'More'];
      for (final label in navLabels) {
        // Each label appears in a Text widget — there should be a semantics
        // node for the Semantics wrapper covering it.
        expect(
          find.text(label),
          findsOneWidget,
          reason: '$label nav item should be visible',
        );
      }
      handle.dispose();
    });

    testWidgets('Home nav item has selected semantics on launch (EN)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget(locale: 'en'));
      await tester.pump();

      // The Home item is selected — its Semantics wrapper uses semanticNavSelected
      // which appends ", selected" to the label: "Home, selected"
      final homeSemantics = find.bySemanticsLabel(
        RegExp(r'Home.*selected', caseSensitive: false),
      );
      expect(
        homeSemantics,
        findsOneWidget,
        reason: 'Home tab should be announced as selected',
      );
      handle.dispose();
    });

    testWidgets('Non-home nav items are not labelled as selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget(locale: 'en'));
      await tester.pump();

      // Search, AI, My List, More should NOT have "selected" in label
      for (final label in ['Search', 'AI', 'My List', 'More']) {
        final selectedFinder = find.bySemanticsLabel(
          RegExp('$label.*selected', caseSensitive: false),
        );
        expect(
          selectedFinder,
          findsNothing,
          reason: '$label should not be labelled as selected initially',
        );
      }
      handle.dispose();
    });

    testWidgets('nav items are accessible via semantic labels', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget(locale: 'en'));
      await tester.pump();

      // The Semantics wrapper for the Home item uses semanticNavSelected —
      // "Home, selected". Verify the label is exposed in the semantics tree.
      final homeSelected = find.bySemanticsLabel(
        RegExp(r'Home.*selected', caseSensitive: false),
      );
      expect(
        homeSelected,
        findsOneWidget,
        reason: 'Home label should exist in the semantics tree',
      );
      handle.dispose();
    });
  });
}
