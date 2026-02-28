import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/ui/widgets/error_retry_widget.dart';
import 'package:stream_scout/l10n/app_localizations.dart';

void main() {
  group('ErrorRetryWidget (full)', () {
    testWidgets('shows default error message when message is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(body: ErrorRetryWidget()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Etwas ist schiefgelaufen 😕'), findsOneWidget);
    });

    testWidgets('shows custom error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(
            body: ErrorRetryWidget(message: 'Netzwerk fehlgeschlagen'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Netzwerk fehlgeschlagen'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(body: ErrorRetryWidget(onRetry: () {})),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erneut versuchen'), findsOneWidget);
    });

    testWidgets('does not show retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(body: ErrorRetryWidget()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erneut versuchen'), findsNothing);
    });

    testWidgets('fires onRetry callback when retry button tapped', (
      tester,
    ) async {
      var retryCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetryWidget(onRetry: () => retryCalled = true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Erneut versuchen'));
      expect(retryCalled, isTrue);
    });

    testWidgets('shows error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(body: ErrorRetryWidget()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });
  });

  group('ErrorRetryWidget (compact)', () {
    testWidgets('shows default compact message when message is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(body: ErrorRetryWidget(compact: true)),
        ),
      );
      await tester.pump();

      expect(find.text('Laden fehlgeschlagen'), findsOneWidget);
    });

    testWidgets('shows custom compact message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(
            body: ErrorRetryWidget(compact: true, message: 'Custom error'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Custom error'), findsOneWidget);
    });

    testWidgets('shows compact retry button when onRetry is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(body: ErrorRetryWidget(compact: true, onRetry: () {})),
        ),
      );
      await tester.pump();

      expect(find.text('Erneut'), findsOneWidget);
    });

    testWidgets('does not show compact retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(body: ErrorRetryWidget(compact: true)),
        ),
      );
      await tester.pump();

      expect(find.text('Erneut'), findsNothing);
    });

    testWidgets('fires onRetry in compact mode', (tester) async {
      var retryCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: ErrorRetryWidget(
              compact: true,
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Erneut'));
      expect(retryCalled, isTrue);
    });
  });
}
