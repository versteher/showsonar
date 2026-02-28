import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/ui/widgets/rating_dialog.dart';
import 'package:stream_scout/l10n/app_localizations.dart';

void main() {
  group('RatingResult', () {
    test('creates with rating and optional notes', () {
      const result = RatingResult(rating: 8.0, notes: 'Great!');
      expect(result.rating, 8.0);
      expect(result.notes, 'Great!');
    });

    test('creates with rating only', () {
      const result = RatingResult(rating: 5.0);
      expect(result.rating, 5.0);
      expect(result.notes, isNull);
    });
  });

  group('RatingDialog', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(
            body: Dialog(child: RatingDialog(title: 'Fight Club')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fight Club'), findsOneWidget);
      expect(find.text('Bewertung'), findsOneWidget);
    });

    testWidgets('shows 10 star icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(
            body: Dialog(child: RatingDialog(title: 'Test')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have 10 star outline icons initially (no rating selected)
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(10));
    });

    testWidgets('shows quick rating buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(
            body: Dialog(child: RatingDialog(title: 'Test')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Schlecht'), findsOneWidget);
      expect(find.text('Okay'), findsOneWidget);
      expect(find.text('Gut'), findsOneWidget);
      expect(find.text('Super'), findsOneWidget);
    });

    testWidgets('Speichern button exists', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(
            body: Dialog(child: RatingDialog(title: 'Test')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Speichern'), findsOneWidget);
    });

    testWidgets('Abbrechen button closes dialog and returns null', (
      tester,
    ) async {
      RatingResult? result;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await RatingDialog.show(
                    context,
                    title: 'Test Movie',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('shows notes toggle button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(
            body: Dialog(child: RatingDialog(title: 'Test')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notizen hinzufügen'), findsOneWidget);
    });

    testWidgets('uses initialRating when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(
            body: Dialog(
              child: RatingDialog(title: 'Test', initialRating: 7.0),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Rating should display — "7.0"
      expect(find.text('7.0'), findsOneWidget);
      // Rating label for 7.0 is "Sehr gut"
      expect(find.text('Sehr gut'), findsOneWidget);
    });

    testWidgets('shows rating label based on rating value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(
            body: Dialog(
              child: RatingDialog(title: 'Test', initialRating: 9.0),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Meisterwerk'), findsOneWidget);
    });
  });
}
