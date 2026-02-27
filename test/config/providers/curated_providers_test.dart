import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/config/providers/curated_providers.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';

import '../../utils/test_provider_container.dart';

void main() {
  late MockDependencies mocks;
  late ProviderContainer container;

  final testMovieHighRating = Media(
    id: 1,
    title: 'Good Movie',
    overview: 'High rating',
    genreIds: [28],
    type: MediaType.movie,
    voteAverage: 8.5,
    voteCount: 5000,
    runtime: 100, // < 120min
    releaseDate: DateTime.now().subtract(
      const Duration(days: 365),
    ), // 1 year ago
  );

  final testSeriesBingeable = Media(
    id: 2,
    title: 'Short Series',
    overview: 'A test overview',
    genreIds: [18],
    type: MediaType.tv,
    voteAverage: 8.1,
    voteCount: 3500,
    numberOfSeasons: 2, // 1-3 seasons
    releaseDate: DateTime.now().subtract(const Duration(days: 730)),
  );

  setUp(() {
    mocks = MockDependencies();
    container = mocks.createContainer();

    // Inject preferences showing the user has "Netflix" (id: 8)
    const subbedPrefs = UserPreferences(
      countryCode: 'US',
      countryName: 'United States',
      subscribedServiceIds: ['netflix'],
      favoriteGenreIds: [],
      minimumRating: 0.0,
      maxAgeRating: 18,
      includeAdult: false,
    );

    when(
      () => mocks.userPreferencesRepository.getPreferences(),
    ).thenAnswer((_) async => subbedPrefs);
  });

  tearDown(() {
    container.dispose();
  });

  group('Curated Providers', () {
    test('criticallyAcclaimed loads top quality movies and shows', () async {
      container.read(selectedCollectionProvider.notifier).state =
          CuratedCollection.criticallyAcclaimed;

      when(
        () => mocks.tmdbRepository.discoverMovies(
          withProviders: [8],
          watchRegion: 'US',
          sortBy: 'vote_average.desc',
          minRating: 8.0,
          maxAgeRating: 18,
        ),
      ).thenAnswer((_) async => [testMovieHighRating]);

      when(
        () => mocks.tmdbRepository.discoverTvSeries(
          withProviders: [8],
          watchRegion: 'US',
          sortBy: 'vote_average.desc',
          minRating: 8.0,
          maxAgeRating: 18,
        ),
      ).thenAnswer((_) async => [testSeriesBingeable]);

      final results = await container.read(curatedCollectionProvider.future);
      expect(results, containsAll([testMovieHighRating, testSeriesBingeable]));
    });

    test('perfectForTonight filters for short runtimes', () async {
      container.read(selectedCollectionProvider.notifier).state =
          CuratedCollection.perfectForTonight;

      when(
        () => mocks.tmdbRepository.discoverMovies(
          withProviders: [8],
          watchRegion: 'US',
          sortBy: 'vote_average.desc',
          minRating: 7.0,
          maxAgeRating: 18,
        ),
      ).thenAnswer((_) async => [testMovieHighRating]);

      final results = await container.read(curatedCollectionProvider.future);
      expect((results).length, 1);
      expect((results).first.title, 'Good Movie');
    });

    test('bingeWorthy filters tv series by season count', () async {
      container.read(selectedCollectionProvider.notifier).state =
          CuratedCollection.bingeWorthy;

      when(
        () => mocks.tmdbRepository.discoverTvSeries(
          withProviders: [8],
          watchRegion: 'US',
          sortBy: 'vote_average.desc',
          minRating: 7.5,
          maxAgeRating: 18,
        ),
      ).thenAnswer((_) async => [testSeriesBingeable]);

      final results = await container.read(curatedCollectionProvider.future);
      expect((results).length, 1);
      expect((results).first.title, 'Short Series');
    });

    test('modernClassics loads recent high-quality titles', () async {
      container.read(selectedCollectionProvider.notifier).state =
          CuratedCollection.modernClassics;

      when(
        () => mocks.tmdbRepository.discoverMovies(
          withProviders: [8],
          watchRegion: 'US',
          sortBy: 'vote_average.desc',
          minRating: 8.0,
          maxAgeRating: 18,
        ),
      ).thenAnswer((_) async => [testMovieHighRating]); // voteCount = 5000

      when(
        () => mocks.tmdbRepository.discoverTvSeries(
          withProviders: [8],
          watchRegion: 'US',
          sortBy: 'vote_average.desc',
          minRating: 8.0,
          maxAgeRating: 18,
        ),
      ).thenAnswer((_) async => []);

      final results = await container.read(curatedCollectionProvider.future);
      expect(
        (results).length,
        1,
      ); // Because it has 5000 votes, which is exactly >= 5000 limit
    });
  });
}
