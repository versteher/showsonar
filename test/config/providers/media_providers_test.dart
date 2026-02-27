import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';

import '../../utils/test_provider_container.dart';

void main() {
  late MockDependencies mocks;
  late ProviderContainer container;

  final testMovie = Media(
    id: 1,
    title: 'Test Movie',
    overview: 'A test overview',
    genreIds: [28, 12],
    type: MediaType.movie,
    voteAverage: 8.5,
    posterPath: '/path.jpg',
    voteCount: 1000,
  );

  setUp(() {
    mocks = MockDependencies();
    container = mocks.createContainer();

    // Default mock setup for preferences used across media providers
    const mockPrefs = UserPreferences(
      countryCode: 'US',
      countryName: 'United States',
      subscribedServiceIds: [],
      favoriteGenreIds: [],
      minimumRating: 0.0,
      maxAgeRating: 18,
      includeAdult: false,
    );

    when(
      () => mocks.userPreferencesRepository.getPreferences(),
    ).thenAnswer((_) async => mockPrefs);
  });

  tearDown(() {
    container.dispose();
  });

  group('Media Providers', () {
    test('searchQueryProvider initializes empty and updates', () {
      final initial = container.read(searchQueryProvider);
      expect(initial, '');

      container.read(searchQueryProvider.notifier).state = 'Matrix';
      expect(container.read(searchQueryProvider), 'Matrix');
    });

    test('searchResultsProvider returns empty for short queries', () async {
      container.read(searchQueryProvider.notifier).state = 'A';

      final results = await container.read(searchResultsProvider.future);
      expect(results, isEmpty);
      // Backend shouldn't even be called
      verifyNever(() => mocks.tmdbRepository.searchMulti(any()));
    });

    test('searchResultsProvider fetches results for valid queries', () async {
      container.read(searchQueryProvider.notifier).state = 'Matrix';

      when(
        () => mocks.tmdbRepository.searchMulti(
          'Matrix',
          includeAdult: false,
          maxAgeRating: 18,
        ),
      ).thenAnswer((_) async => [testMovie]);

      final results = await container.read(searchResultsProvider.future);
      expect(results, [testMovie]);
    });

    test('mediaDetailsProvider fetches specific device details', () async {
      when(
        () => mocks.tmdbRepository.getMovieDetails(1),
      ).thenAnswer((_) async => testMovie);

      final result = await container.read(
        mediaDetailsProvider((id: 1, type: MediaType.movie)).future,
      );
      expect(result, testMovie);
    });

    test('similarContentProvider queries backend', () async {
      when(
        () => mocks.tmdbRepository.getSimilar(1, MediaType.movie),
      ).thenAnswer((_) async => [testMovie]);

      final result = await container.read(
        similarContentProvider((id: 1, type: MediaType.movie)).future,
      );
      expect(result, [testMovie]);
    });

    test('trailerUrlProvider grabs video source', () async {
      when(
        () => mocks.tmdbRepository.getTrailerUrl(1, MediaType.movie),
      ).thenAnswer((_) async => 'https://youtube.com/watch?v=123');

      final url = await container.read(
        trailerUrlProvider((id: 1, type: MediaType.movie)).future,
      );
      expect(url, 'https://youtube.com/watch?v=123');
    });

    test('popularMoviesProvider fetches filtered results', () async {
      when(
        () => mocks.tmdbRepository.discoverMovies(
          withProviders: [],
          watchRegion: 'US',
          sortBy: 'popularity.desc',
          maxAgeRating: 18,
          minRating: 0.0,
        ),
      ).thenAnswer((_) async => [testMovie]);

      // Note: providerIds is empty so the stream returns empty normally.
      // We will override the UserPrefs specifically for this isolated test:

      const subbedPrefs = UserPreferences(
        countryCode: 'US',
        countryName: 'United States',
        subscribedServiceIds: ['netflix'],
        favoriteGenreIds: [],
        minimumRating: 0.0,
      );
      when(
        () => mocks.userPreferencesRepository.getPreferences(),
      ).thenAnswer((_) async => subbedPrefs);

      when(
        () => mocks.tmdbRepository.discoverMovies(
          withProviders: [8], // 8 is netflix TMDB mapped ID
          watchRegion: 'US',
          sortBy: 'popularity.desc',
          maxAgeRating: 18,
          minRating: 0.0,
        ),
      ).thenAnswer((_) async => [testMovie]);

      final results = await container.read(popularMoviesProvider.future);
      expect(results, [testMovie]);
    });
  });
}
