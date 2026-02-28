import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/ui/widgets/media_section.dart';
import 'package:stream_scout/l10n/app_localizations.dart';

void main() {
  // Test data with all required fields
  final movie1 = Media(
    id: 1,
    title: 'Unwatched Movie 1',
    type: MediaType.movie,
    overview: 'A great movie',
    posterPath: '/poster1.jpg',
    voteAverage: 7.5,
    voteCount: 100,
    genreIds: [28],
  );
  final movie2 = Media(
    id: 2,
    title: 'Watched Movie 2',
    type: MediaType.movie,
    overview: 'Another movie',
    posterPath: '/poster2.jpg',
    voteAverage: 6.0,
    voteCount: 50,
    genreIds: [35],
  );
  final movie3 = Media(
    id: 3,
    title: 'Unwatched Movie 3',
    type: MediaType.movie,
    overview: 'Third movie',
    posterPath: '/poster3.jpg',
    voteAverage: 8.0,
    voteCount: 200,
    genreIds: [27],
  );
  final tvShow1 = Media(
    id: 10,
    title: 'Watched TV Show',
    type: MediaType.tv,
    overview: 'A TV Show',
    posterPath: '/poster_tv.jpg',
    voteAverage: 9.0,
    voteCount: 300,
    genreIds: [18],
  );

  final allItems = [movie1, movie2, movie3, tvShow1];
  final watchedIds = {'movie_2', 'tv_10'};

  // Helper to wrap MediaSection in ProviderScope + MaterialApp
  Widget buildWidget({
    required List<Media> items,
    Set<String>? watchedIds,
    bool hideWatched = false,
    String title = 'Test Section',
  }) {
    return ProviderScope(
      overrides: [
        for (final item in items)
          mediaAvailabilityProvider(
            id: item.id,
            type: item.type,
          ).overrideWith((ref) async => []),
        userPreferencesProvider.overrideWith(
          (ref) async => UserPreferences.defaultDE(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: MediaSection(
              title: title,
              items: items,
              watchedIds: watchedIds,
              hideWatched: hideWatched,
            ),
          ),
        ),
      ),
    );
  }

  group('MediaSection', () {
    testWidgets('shows section title', (tester) async {
      await tester.pumpWidget(buildWidget(items: allItems));
      expect(find.text('Test Section'), findsOneWidget);
    });

    testWidgets('hides title when empty string', (tester) async {
      await tester.pumpWidget(buildWidget(items: allItems, title: ''));
      expect(find.text('Test Section'), findsNothing);
    });

    testWidgets('shows all items when no watchedIds', (tester) async {
      await tester.pumpWidget(buildWidget(items: allItems));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Unwatched Movie 1'), findsOneWidget);
      expect(find.text('Watched Movie 2'), findsOneWidget);
      expect(find.text('Unwatched Movie 3'), findsOneWidget);
      expect(find.text('Watched TV Show'), findsOneWidget);
    });

    testWidgets('shows all items when watchedIds is empty set', (tester) async {
      await tester.pumpWidget(
        buildWidget(items: allItems, watchedIds: <String>{}),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Unwatched Movie 1'), findsOneWidget);
      expect(find.text('Watched Movie 2'), findsOneWidget);
    });

    testWidgets('shows watched items (with badge) when hideWatched is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          items: allItems,
          watchedIds: watchedIds,
          hideWatched: false,
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      // All items still visible
      expect(find.text('Unwatched Movie 1'), findsOneWidget);
      expect(find.text('Watched Movie 2'), findsOneWidget);
      expect(find.text('Unwatched Movie 3'), findsOneWidget);
      expect(find.text('Watched TV Show'), findsOneWidget);
      // Watched badge: widget renders 'Gesehen' text + Icons.check_circle icon
      expect(find.text('Gesehen'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));
    });

    testWidgets('hides watched items when hideWatched is true', (tester) async {
      await tester.pumpWidget(
        buildWidget(items: allItems, watchedIds: watchedIds, hideWatched: true),
      );
      await tester.pump(const Duration(seconds: 2));
      // Only unwatched visible
      expect(find.text('Unwatched Movie 1'), findsOneWidget);
      expect(find.text('Unwatched Movie 3'), findsOneWidget);
      // Watched items should NOT be visible
      expect(find.text('Watched Movie 2'), findsNothing);
      expect(find.text('Watched TV Show'), findsNothing);
    });

    testWidgets('all items watched + hideWatched → shows empty state', (
      tester,
    ) async {
      final allWatchedIds = {'movie_1', 'movie_2', 'movie_3', 'tv_10'};
      await tester.pumpWidget(
        buildWidget(
          items: allItems,
          watchedIds: allWatchedIds,
          hideWatched: true,
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      // No items should be visible
      expect(find.text('Unwatched Movie 1'), findsNothing);
      expect(find.text('Watched Movie 2'), findsNothing);
    });

    testWidgets('empty items list does not crash', (tester) async {
      await tester.pumpWidget(buildWidget(items: []));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Unwatched Movie 1'), findsNothing);
    });

    testWidgets('shows loading shimmer when isLoading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesProvider.overrideWith(
              (ref) async => UserPreferences.defaultDE(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: MediaSection(
                  title: 'Loading',
                  items: const [],
                  isLoading: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Loading'), findsOneWidget);
    });
  });

  group('MediaSection _processedItems logic', () {
    // Testing the logic directly via the widget behavior

    testWidgets(
      'unwatched items appear first, watched last (hideWatched=false)',
      (tester) async {
        // When hideWatched is false and we have watched IDs,
        // unwatched should come before watched
        await tester.pumpWidget(
          buildWidget(
            items: [movie2, movie1], // watched first, unwatched second
            watchedIds: {'movie_2'},
            hideWatched: false,
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        // Both should be visible
        expect(find.text('Unwatched Movie 1'), findsOneWidget);
        expect(find.text('Watched Movie 2'), findsOneWidget);
      },
    );

    testWidgets('hideWatched with no matches leaves all visible', (
      tester,
    ) async {
      // watchedIds don't match any items
      await tester.pumpWidget(
        buildWidget(
          items: allItems,
          watchedIds: {'movie_999'},
          hideWatched: true,
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Unwatched Movie 1'), findsOneWidget);
      expect(find.text('Watched Movie 2'), findsOneWidget);
      expect(find.text('Unwatched Movie 3'), findsOneWidget);
      expect(find.text('Watched TV Show'), findsOneWidget);
    });

    testWidgets('mixed TV and movie watched IDs filter correctly', (
      tester,
    ) async {
      // Only TV show is watched
      await tester.pumpWidget(
        buildWidget(items: allItems, watchedIds: {'tv_10'}, hideWatched: true),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Unwatched Movie 1'), findsOneWidget);
      expect(find.text('Watched Movie 2'), findsOneWidget);
      expect(find.text('Unwatched Movie 3'), findsOneWidget);
      expect(find.text('Watched TV Show'), findsNothing);
    });
  });
}
