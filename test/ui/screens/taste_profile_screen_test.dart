import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:neon_voyager/ui/screens/taste_profile_screen.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/watch_history_entry.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/repositories/watch_history_repository.dart';

import '../../utils/test_app_wrapper.dart';

class MockWatchHistoryRepository extends Mock
    implements WatchHistoryRepository {}

void main() {
  setUpAll(() {
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = Duration.zero; // Disable animations
  });

  final mockEntries = [
    WatchHistoryEntry(
      mediaId: 1,
      mediaType: MediaType.movie,
      title: 'Movie 1',
      watchedAt: DateTime(2023, 1, 1),
      userRating: 8.0,
      genreIds: [28],
    ),
    WatchHistoryEntry(
      mediaId: 2,
      mediaType: MediaType.tv,
      title: 'Show 1',
      watchedAt: DateTime(2023, 1, 2),
      userRating: 9.0,
      genreIds: [12],
    ),
  ];

  group('TasteProfileScreen Widget Tests', () {
    testWidgets('renders stats and buttons correctly', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const TasteProfileScreen(),
          overrides: [
            watchHistoryEntriesProvider.overrideWith(
              (ref) => Future.value(mockEntries),
            ),
          ],
        ),
      );

      // Wait for animations
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check stats: 2 Gesehen, 2 Bewertet, 8.5 Ø Bewertung
      expect(find.text('Gesehen'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // Gesehen/Bewertet
      expect(find.text('Ø Bewertung'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget);

      // Check buttons
      expect(find.text('Profil exportieren'), findsOneWidget);
      expect(find.text('Profil importieren & vergleichen'), findsOneWidget);
    });

    testWidgets('shows error when importing empty JSON', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const TasteProfileScreen(),
          overrides: [
            watchHistoryEntriesProvider.overrideWith(
              (ref) => Future.value(mockEntries),
            ),
          ],
        ),
      );

      // Wait for animations
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final importBtn = find.text('Profil importieren & vergleichen');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(importBtn);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Bitte JSON einfügen'), findsOneWidget);
    });
  });
}
