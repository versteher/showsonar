// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

  /// Builds a MediaCard inside ProviderScope + MaterialApp.
  Widget buildTestWidget({
    Media? media,
    VoidCallback? onTap,
    bool isWatched = false,
    bool showRating = true,
    String locale = 'en',
    bool withOnTap = true,
  }) {
    final m = media ?? testMedia;
    return ProviderScope(
      overrides: [
        mediaAvailabilityProvider(
          id: m.id,
          type: m.type,
        ).overrideWith((ref) async => []),
        userPreferencesProvider.overrideWith(
          (ref) async => UserPreferences.defaultDE(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(locale),
        home: Scaffold(
          body: MediaCard(
            media: m,
            onTap: withOnTap ? (onTap ?? () {}) : null,
            isWatched: isWatched,
            showRating: showRating,
            enableHero: false,
          ),
        ),
      ),
    );
  }

  group('MediaCard accessibility', () {
    testWidgets('has a Semantics node with isButton flag when onTap provided', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      final semantics = tester.getSemantics(find.byType(MediaCard));
      expect(
        semantics.hasFlag(SemanticsFlag.isButton),
        isTrue,
        reason: 'MediaCard with onTap should expose isButton flag',
      );
      handle.dispose();
    });

    testWidgets('semantic label contains the media title (EN)', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget(locale: 'en'));
      await tester.pump(const Duration(milliseconds: 500));

      final semantics = tester.getSemantics(find.byType(MediaCard));
      expect(
        semantics.label,
        contains('Fight Club'),
        reason: 'Semantic label should include the title',
      );
      handle.dispose();
    });

    testWidgets('semantic label contains the media title (DE)', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget(locale: 'de'));
      await tester.pump(const Duration(milliseconds: 500));

      final semantics = tester.getSemantics(find.byType(MediaCard));
      expect(semantics.label, contains('Fight Club'));
      handle.dispose();
    });

    testWidgets('semantic label contains the numeric rating', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget(locale: 'en'));
      await tester.pump(const Duration(milliseconds: 500));

      final semantics = tester.getSemantics(find.byType(MediaCard));
      // Rating 8.4 should appear in the label
      expect(semantics.label, contains('8.4'));
      handle.dispose();
    });

    testWidgets('semantic label contains the media type (EN)', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget(locale: 'en'));
      await tester.pump(const Duration(milliseconds: 500));

      final semantics = tester.getSemantics(find.byType(MediaCard));
      // MediaType.movie.displayName in EN is 'Movie'
      expect(semantics.label, contains('Movie'));
      handle.dispose();
    });

    testWidgets('card without onTap does not have isButton flag', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget(withOnTap: false));
      await tester.pump(const Duration(milliseconds: 500));

      final semantics = tester.getSemantics(find.byType(MediaCard));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isFalse);
      handle.dispose();
    });
  });
}
