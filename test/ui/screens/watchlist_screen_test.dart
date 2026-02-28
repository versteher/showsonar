import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:stream_scout/ui/screens/watchlist_screen.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/models/watchlist_entry.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/repositories/watchlist_repository.dart';

import '../../utils/test_app_wrapper.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  late MockWatchlistRepository mockRepo;

  final mockEntries = [
    WatchlistEntry(
      mediaId: 1,
      mediaType: MediaType.movie,
      title: 'Movie 1',
      posterPath: '/m1.jpg',
      addedAt: DateTime(2023, 1, 1),
      voteAverage: 8.0,
    ),
    WatchlistEntry(
      mediaId: 2,
      mediaType: MediaType.tv,
      title: 'Show 1',
      posterPath: '/s1.jpg',
      addedAt: DateTime(2023, 1, 2),
      voteAverage: 9.0,
    ),
  ];

  setUpAll(() {
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = Duration.zero; // Disable animations
  });

  setUp(() {
    mockRepo = MockWatchlistRepository();
  });

  group('WatchlistScreen Widget Tests', () {
    testWidgets('displays empty state', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const WatchlistScreen(),
          overrides: [
            watchlistEntriesProvider.overrideWith((ref) => Future.value([])),
          ],
        ),
      );

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    });

    testWidgets('displays watchlist items and handles sort', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const WatchlistScreen(),
          overrides: [
            watchlistEntriesProvider.overrideWith(
              (ref) => Future.value(mockEntries),
            ),
            watchlistRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Movie 1'), findsOneWidget);
      expect(find.text('Show 1'), findsOneWidget);

      // Verify that filter chips are visible
      expect(find.text('Neueste zuerst'), findsOneWidget); // recentlyAdded
      expect(find.text('Beste Bewertung'), findsOneWidget); // highestRated
      expect(find.text('A–Z'), findsOneWidget); // alphabetical

      // Test tapping a sort chip
      await tester.tap(find.text('A–Z'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Order should change, but both should still be found
      expect(find.text('Movie 1'), findsOneWidget);
      expect(find.text('Show 1'), findsOneWidget);
    });

    testWidgets('swipe right reveals mark watched action', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const WatchlistScreen(),
          overrides: [
            watchlistEntriesProvider.overrideWith(
              (ref) => Future.value(mockEntries),
            ),
            watchlistRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Swipe from left to right
      await tester.drag(find.text('Movie 1'), const Offset(500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('swipe left reveals delete action', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const WatchlistScreen(),
          overrides: [
            watchlistEntriesProvider.overrideWith(
              (ref) => Future.value(mockEntries),
            ),
            watchlistRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Swipe from right to left
      await tester.drag(find.text('Movie 1'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });
  });
}
