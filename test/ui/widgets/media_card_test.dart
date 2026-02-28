import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/ui/widgets/media_card.dart';
import 'package:stream_scout/l10n/app_localizations.dart';

void main() {
  final testMedia = Media(
    id: 550,
    title: 'Fight Club',
    overview: 'A thinly veiled critique of consumerism',
    posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    voteAverage: 8.4,
    voteCount: 26000,
    genreIds: [18, 53],
    type: MediaType.movie,
  );

  /// Wrap MediaCard in ProviderScope + MaterialApp with mocked providers.
  /// MediaCard is a ConsumerWidget that watches:
  ///   - mediaAvailabilityProvider (streaming overlays)
  ///   - userPreferencesProvider (subscribed services)
  Widget buildTestWidget({
    Media? media,
    VoidCallback? onTap,
    void Function(Media)? onLongPress,
    bool showTitle = true,
    bool showRating = true,
    bool isWatched = false,
    bool enableHero = false,
  }) {
    final m = media ?? testMedia;
    return ProviderScope(
      overrides: [
        // Return empty availability list for the specific media item
        mediaAvailabilityProvider(
          id: m.id,
          type: m.type,
        ).overrideWith((ref) async => []),
        // Return default DE preferences
        userPreferencesProvider.overrideWith(
          (ref) async => UserPreferences.defaultDE(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(
          body: MediaCard(
            media: m,
            onTap: onTap,
            onLongPress: onLongPress,
            showTitle: showTitle,
            showRating: showRating,
            isWatched: isWatched,
            enableHero: enableHero,
          ),
        ),
      ),
    );
  }

  group('MediaCard', () {
    testWidgets('renders title when showTitle is true', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      // Use pump() instead of pumpAndSettle() because Shimmer animates forever
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Fight Club'), findsOneWidget);
    });

    testWidgets('does not render title when showTitle is false', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(showTitle: false));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Fight Club'), findsNothing);
    });

    testWidgets('renders rating badge when showRating is true', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('8.4'), findsOneWidget);
    });

    testWidgets('does not render rating when showRating is false', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(showRating: false));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('8.4'), findsNothing);
    });

    testWidgets('fires onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(onTap: () => tapped = true));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });

    testWidgets('fires onLongPress callback when long-pressed', (tester) async {
      Media? longPressedMedia;
      await tester.pumpWidget(
        buildTestWidget(onLongPress: (m) => longPressedMedia = m),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.longPress(find.byType(GestureDetector).first);
      expect(longPressedMedia, equals(testMedia));
    });

    testWidgets('shows watched overlay when isWatched is true', (tester) async {
      await tester.pumpWidget(buildTestWidget(isWatched: true));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Gesehen'), findsOneWidget);
    });

    testWidgets('does not show watched overlay when isWatched is false', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(isWatched: false));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Gesehen'), findsNothing);
    });

    testWidgets('shows media type badge', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      // MediaType.movie.displayName is 'Film'
      expect(find.text('Film'), findsOneWidget);
    });

    testWidgets('shows fallback icon when posterPath is null', (tester) async {
      final noPosters = Media(
        id: 1,
        title: 'No Poster',
        overview: 'Test',
        voteAverage: 5.0,
        voteCount: 100,
        genreIds: [],
        type: MediaType.movie,
      );

      await tester.pumpWidget(buildTestWidget(media: noPosters));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
    });
  });
}
