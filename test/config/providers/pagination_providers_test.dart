import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/repositories/tmdb_repository.dart';

class MockTmdbRepository extends Mock implements ITmdbRepository {}

void main() {
  late ProviderContainer container;
  late MockTmdbRepository mockRepo;

  setUp(() {
    mockRepo = MockTmdbRepository();
    container = ProviderContainer(
      overrides: [tmdbRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('PopularMoviesPaginationNotifier fetches first page on init', () async {
    final mockMedia = [
      const Media(
        id: 1,
        title: 'Item 1',
        type: MediaType.movie,
        posterPath: '',
        backdropPath: '',
        overview: '',
        releaseDate: null,
        genreIds: [],
        voteAverage: 8.0,
        voteCount: 100,
      ),
    ];

    when(
      () => mockRepo.getPopularMovies(page: 1),
    ).thenAnswer((_) async => mockMedia);

    final sub = container.listen(popularMoviesPaginationProvider, (_, _) {});

    // Wait for initial load
    await Future.delayed(const Duration(milliseconds: 10));

    final state = container.read(popularMoviesPaginationProvider).value;
    expect(state, isNotNull);
    expect(state!.page, 1);
    expect(state.items.length, 1);
    expect(state.hasMore, isTrue);

    sub.close();
  });

  test(
    'PaginationNotifier loadMore appends new items and increments page',
    () async {
      final mockMediaPage1 = [
        const Media(
          id: 1,
          title: 'Item 1',
          type: MediaType.movie,
          posterPath: '',
          backdropPath: '',
          overview: '',
          releaseDate: null,
          genreIds: [],
          voteAverage: 8.0,
          voteCount: 100,
        ),
      ];
      final mockMediaPage2 = [
        const Media(
          id: 2,
          title: 'Item 2',
          type: MediaType.movie,
          posterPath: '',
          backdropPath: '',
          overview: '',
          releaseDate: null,
          genreIds: [],
          voteAverage: 8.0,
          voteCount: 100,
        ),
      ];

      when(
        () => mockRepo.getPopularMovies(page: 1),
      ).thenAnswer((_) async => mockMediaPage1);
      when(
        () => mockRepo.getPopularMovies(page: 2),
      ).thenAnswer((_) async => mockMediaPage2);

      final sub = container.listen(popularMoviesPaginationProvider, (_, _) {});

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 10));

      // Act: trigger loadMore
      await container.read(popularMoviesPaginationProvider.notifier).loadMore();

      final state = container.read(popularMoviesPaginationProvider).value;
      expect(state, isNotNull);
      expect(state!.page, 2);
      expect(state.items.length, 2); // 1 + 1 appended
      expect(state.items[0].id, 1);
      expect(state.items[1].id, 2);
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);

      sub.close();
    },
  );

  test(
    'PaginationNotifier loadMore handles empty result -> hasMore = false',
    () async {
      final mockMediaPage1 = [
        const Media(
          id: 1,
          title: 'Item 1',
          type: MediaType.movie,
          posterPath: '',
          backdropPath: '',
          overview: '',
          releaseDate: null,
          genreIds: [],
          voteAverage: 8.0,
          voteCount: 100,
        ),
      ];

      when(
        () => mockRepo.getPopularMovies(page: 1),
      ).thenAnswer((_) async => mockMediaPage1);
      when(
        () => mockRepo.getPopularMovies(page: 2),
      ).thenAnswer((_) async => <Media>[]);

      final sub = container.listen(popularMoviesPaginationProvider, (_, _) {});

      await Future.delayed(const Duration(milliseconds: 10));
      await container.read(popularMoviesPaginationProvider.notifier).loadMore();

      final state = container.read(popularMoviesPaginationProvider).value;
      expect(state, isNotNull);
      expect(state!.page, 2);
      expect(state.items.length, 1); // No new items appended
      expect(state.hasMore, isFalse);

      sub.close();
    },
  );
}
