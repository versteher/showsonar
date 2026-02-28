import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/ui/widgets/media_section.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createWidgetUnderTest({
    required List<Media> items,
    VoidCallback? onLoadMore,
    bool isLoadingMore = false,
  }) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('de', '')],
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: MediaSection(
              title: 'Test Section',
              items: items,
              onLoadMore: onLoadMore,
              isLoadingMore: isLoadingMore,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('MediaSection calls onLoadMore when scrolled near end', (
    WidgetTester tester,
  ) async {
    bool loadMoreCalled = false;

    // Create enough items to allow scrolling
    final items = List.generate(
      10,
      (index) => Media(
        id: index,
        title: 'Movie $index',
        overview: 'Overview',
        voteAverage: 8.0,
        type: MediaType.movie,
        voteCount: 100,
        genreIds: [],
        releaseDate: null,
      ),
    );

    await tester.pumpWidget(
      createWidgetUnderTest(
        items: items,
        onLoadMore: () {
          loadMoreCalled = true;
        },
      ),
    );

    // Initially, loadMore should not have been called
    expect(loadMoreCalled, isFalse);

    // Find the ListView
    final listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Scroll by an amount that triggers the threshold (-200 pixels from max extent)
    // We scroll far to the right since it's a horizontal list
    await tester.drag(listViewFinder, const Offset(-2000, 0));
    await tester.pumpAndSettle();

    // Verify onLoadMore was called
    expect(loadMoreCalled, isTrue);
  });

  testWidgets(
    'MediaSection displays loading indicator when isLoadingMore is true',
    (WidgetTester tester) async {
      final items = [
        const Media(
          id: 1,
          title: 'Movie 1',
          overview: 'Overview',
          voteAverage: 8.0,
          type: MediaType.movie,
          voteCount: 100,
          genreIds: [],
          releaseDate: null,
        ),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(items: items, isLoadingMore: true),
      );

      // Wait for animation to settle if any, but CircularProgressIndicator animates continuously,
      // so we just pump one frame.
      await tester.pump();

      // Verify CircularProgressIndicator is present at the end of the list
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );
}
