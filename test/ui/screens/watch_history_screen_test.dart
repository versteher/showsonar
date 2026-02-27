import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:neon_voyager/ui/screens/watch_history_screen.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/watch_history_entry.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/repositories/watch_history_repository.dart';

import '../../utils/test_app_wrapper.dart';

class MockWatchHistoryRepository extends Mock
    implements WatchHistoryRepository {}

void main() {
  late MockWatchHistoryRepository mockRepo;

  final mockEntries = [
    WatchHistoryEntry(
      mediaId: 1,
      mediaType: MediaType.movie,
      title: 'Movie 1',
      posterPath: '/m1.jpg',
      watchedAt: DateTime(2023, 1, 1),
      userRating: 8.0,
      notes: 'Good movie',
      genreIds: [28],
    ),
    WatchHistoryEntry(
      mediaId: 2,
      mediaType: MediaType.tv,
      title: 'Show 1',
      posterPath: '/s1.jpg',
      watchedAt: DateTime(2023, 1, 2),
      userRating: 9.0,
      notes: 'Great show',
      genreIds: [12],
    ),
  ];

  setUpAll(() {
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = Duration.zero; // Disable animations
  });

  setUp(() {
    mockRepo = MockWatchHistoryRepository();
  });

  group('WatchHistoryScreen Widget Tests', () {
    testWidgets('displays empty state', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const WatchHistoryScreen(),
          overrides: [
            watchHistoryEntriesProvider.overrideWith((ref) => Future.value([])),
          ],
        ),
      );

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(
        find.byIcon(Icons.movie_filter_outlined),
        findsWidgets,
      ); // emptyHistory
    });

    testWidgets('displays history items and handles filter', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const WatchHistoryScreen(),
          overrides: [
            watchHistoryEntriesProvider.overrideWith(
              (ref) => Future.value(mockEntries),
            ),
            watchHistoryRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Movie 1'), findsOneWidget);
      expect(find.text('Show 1'), findsOneWidget);

      // Verify that stats header is visible. Movie count = 1, Show count = 1.
      expect(find.text('Movies'), findsWidgets); // statMovies
      expect(
        find.text('Series'),
        findsWidgets,
      ); // statSeries (matches type pill too)

      // Tap on Movies filter
      await tester.tap(find.text('🎬 Movies'));
      await tester.pumpAndSettle();

      expect(find.text('Movie 1'), findsOneWidget);
      expect(find.text('Show 1'), findsNothing);
    });

    testWidgets('swipe right reveals change rating action', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const WatchHistoryScreen(),
          overrides: [
            watchHistoryEntriesProvider.overrideWith(
              (ref) => Future.value(mockEntries),
            ),
            watchHistoryRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Swipe from left to right
      await tester.drag(find.text('Movie 1'), const Offset(500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    });

    testWidgets('swipe left reveals delete action', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const WatchHistoryScreen(),
          overrides: [
            watchHistoryEntriesProvider.overrideWith(
              (ref) => Future.value(mockEntries),
            ),
            watchHistoryRepositoryProvider.overrideWithValue(mockRepo),
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
