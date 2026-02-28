import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/config/providers/pagination_providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/repositories/tmdb_repository.dart';
import 'package:stream_scout/ui/widgets/media_section.dart';
import '../../utils/test_app_wrapper.dart';

class MockTmdbRepository extends Mock implements ITmdbRepository {}

void main() {
  late MockTmdbRepository mockTmdb;

  setUp(() {
    mockTmdb = MockTmdbRepository();
  });

  testWidgets(
    'Pagination integration: Scrolling loads next page and appends to UI',
    (tester) async {
      // Create initial page of 20 items
      final page1 = List.generate(
        20,
        (index) => Media(
          id: index,
          title: 'Movie $index',
          overview: 'Overview',
          voteAverage: 8.0,
          type: MediaType.movie,
          releaseDate: DateTime(2023),
          voteCount: 100,
          genreIds: const [],
        ),
      );

      // Create second page of 20 items
      final page2 = List.generate(
        20,
        (index) => Media(
          id: 20 + index,
          title: 'Movie ${20 + index}',
          overview: 'Overview',
          voteAverage: 8.0,
          type: MediaType.movie,
          releaseDate: DateTime(2023),
          voteCount: 100,
          genreIds: const [],
        ),
      );

      when(
        () => mockTmdb.getPopularMovies(page: 1),
      ).thenAnswer((_) async => page1);

      when(() => mockTmdb.getPopularMovies(page: 2)).thenAnswer((_) async {
        // Add a small delay to simulate network latency
        await Future.delayed(const Duration(milliseconds: 100));
        return page2;
      });

      // A simple widget that connects the given provider to MediaSection
      final testWidget = Consumer(
        builder: (context, ref, child) {
          final stateAsync = ref.watch(popularMoviesPaginationProvider);

          return Scaffold(
            body: stateAsync.when(
              data: (state) => SizedBox(
                height: 400,
                child: MediaSection(
                  title: 'Popular Movies',
                  items: state.items,
                  onLoadMore: () => ref
                      .read(popularMoviesPaginationProvider.notifier)
                      .loadMore(),
                  isLoadingMore: state.isLoadingMore,
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: \$e'),
            ),
          );
        },
      );

      await tester.pumpWidget(
        pumpAppScreen(
          child: testWidget,
          overrides: [tmdbRepositoryProvider.overrideWithValue(mockTmdb)],
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify page 1 items are shown (e.g., Movie 0)
      expect(find.text('Movie 0'), findsWidgets);

      // Verify page 2 item is NOT yet shown
      expect(find.text('Movie 25'), findsNothing);

      // Find the ListView
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Scroll to the end of the ListView to trigger pagination
      // We drag a large negative offset to scroll all the way right
      await tester.drag(listView, const Offset(-3000, 0));
      await tester.pump();

      // Verification: isLoadingMore should be true and trigger a loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the async mock to resolve and the UI to settle with the new items
      await tester.pumpAndSettle();

      // Scroll a bit more to see the new items
      await tester.drag(listView, const Offset(-1000, 0));
      await tester.pumpAndSettle();

      // Verify page 2 items are now present
      expect(find.text('Movie 25'), findsWidgets);

      // Verify mock was actually called for page 2
      verify(() => mockTmdb.getPopularMovies(page: 2)).called(1);
    },
  );
}
