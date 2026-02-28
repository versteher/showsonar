import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stream_scout/ui/widgets/offline_banner.dart';
import 'package:stream_scout/config/providers.dart';

void main() {
  testWidgets('OfflineBanner shows when connectivity is none', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value([ConnectivityResult.none]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: Column(children: [OfflineBanner()])),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // The text 'No internet connection' should be visible
    expect(find.text('No internet connection'), findsOneWidget);
  });

  testWidgets('OfflineBanner is hidden when connectivity is wifi or mobile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value([ConnectivityResult.wifi]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: Column(children: [OfflineBanner()])),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // The text should not be rendered visibly or container height is 0
    final bannerFinder = find.byType(OfflineBanner);
    expect(bannerFinder, findsOneWidget);

    final containerFinder = find.descendant(
      of: bannerFinder,
      matching: find.byType(AnimatedContainer),
    );
    final animatedContainer = tester.widget<AnimatedContainer>(containerFinder);

    expect(animatedContainer.constraints?.maxHeight, 0);
  });
}
