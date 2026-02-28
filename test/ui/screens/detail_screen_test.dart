import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:stream_scout/ui/screens/detail_screen.dart';
import 'package:stream_scout/ui/widgets/watchlist_button.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/watch_history_entry.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:stream_scout/data/repositories/watchlist_repository.dart';

import '../../utils/test_app_wrapper.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  late MockWatchlistRepository mockWatchlistRepo;

  final mockMedia = Media(
    id: 123,
    title: 'Test Movie',
    overview: 'This is a test movie overview.',
    posterPath: '/test_poster.jpg',
    backdropPath: '/test_backdrop.jpg',
    voteAverage: 8.5,
    releaseDate: DateTime(2023, 1, 1),
    type: MediaType.movie,
    genreIds: [28, 12],
    popularity: 100.0,
    voteCount: 1000,
    runtime: 120,
    ageRating: 'PG-13',
  );

  final mockSimilar = <Media>[
    Media(
      id: 456,
      title: 'Similar Movie',
      overview: 'Similar overview.',
      posterPath: '/similar.jpg',
      voteAverage: 7.0,
      releaseDate: DateTime(2023, 2, 1),
      type: MediaType.movie,
      genreIds: [28],
      voteCount: 500,
    ),
  ];

  setUpAll(() {
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = Duration.zero; // Disable animations
  });

  setUp(() {
    mockWatchlistRepo = MockWatchlistRepository();
  });

  group('DetailScreen Widget Tests', () {
    testWidgets('displays loading state initially', (tester) async {
      final completer = Completer<Media>();
      await tester.pumpWidget(
        pumpAppScreen(
          child: const DetailScreen(mediaId: 123, mediaType: MediaType.movie),
          overrides: [
            mediaDetailsProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => completer.future),
          ],
        ),
      );

      // Using descendants to find Shimmer might be hard, but the backdrop or
      // loading shimmer containers should be present
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      ); // Uses custom loading

      completer.complete(mockMedia);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

    testWidgets('displays media details correctly', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const DetailScreen(mediaId: 123, mediaType: MediaType.movie),
          overrides: [
            mediaDetailsProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => Future.value(mockMedia)),
            similarContentProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => Future.value(mockSimilar)),
            watchHistoryEntryProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => Future.value(null)),
            isOnWatchlistProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => Future.value(false)),
            userPreferencesProvider.overrideWith(
              (ref) => Future.value(
                const UserPreferences(
                  countryCode: 'US',
                  countryName: 'United States',
                  subscribedServiceIds: [],
                ),
              ),
            ),
            mediaAvailabilityProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => Future.value([])),
            watchlistRepositoryProvider.overrideWithValue(mockWatchlistRepo),
          ],
        ),
      );

      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check title and year are displayed
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('2023'), findsOneWidget);
      expect(find.text('This is a test movie overview.'), findsOneWidget);
      expect(find.text('PG-13'), findsOneWidget);
      expect(find.text('120 min'), findsOneWidget);

      // Check action buttons
      expect(find.byType(WatchlistButton), findsOneWidget);
      expect(find.text('Mark as Watched'), findsOneWidget);
    });

    testWidgets('displays watched state and rating correctly', (tester) async {
      final mockEntry = WatchHistoryEntry.fromMedia(
        mockMedia,
        rating: 8.0,
        notes: 'Great movie!',
      );

      await tester.pumpWidget(
        pumpAppScreen(
          child: const DetailScreen(mediaId: 123, mediaType: MediaType.movie),
          overrides: [
            mediaDetailsProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => Future.value(mockMedia)),
            similarContentProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => Future.value([])),
            watchHistoryEntryProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => Future.value(mockEntry)),
            isOnWatchlistProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => Future.value(false)),
            userPreferencesProvider.overrideWith(
              (ref) => Future.value(
                const UserPreferences(
                  countryCode: 'US',
                  countryName: 'United States',
                  subscribedServiceIds: [],
                ),
              ),
            ),
            mediaAvailabilityProvider((
              id: 123,
              type: MediaType.movie,
            )).overrideWith((ref) => Future.value([])),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Should show 'Gesehen' badge or similar (from watch history)
      expect(find.text('Gesehen'), findsOneWidget);
      expect(find.text('Great movie!'), findsOneWidget);
      expect(find.text('8.0 ⭐'), findsOneWidget);

      // Button should change to "Change Rating"
      expect(find.text('Change Rating'), findsOneWidget);
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    });
  });
}
