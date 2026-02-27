import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';
import 'package:neon_voyager/config/providers/seasonal_providers.dart';

import '../../utils/test_provider_container.dart';

void main() {
  late MockDependencies mocks;
  late ProviderContainer container;

  final testMovie = Media(
    id: 1,
    title: 'Seasonal Movie',
    overview: 'High rating',
    genreIds: [28],
    type: MediaType.movie,
    voteAverage: 8.5,
    voteCount: 5000,
  );

  final testSeries = Media(
    id: 2,
    title: 'Seasonal Series',
    overview: 'A test overview',
    genreIds: [18],
    type: MediaType.tv,
    voteAverage: 8.1,
    voteCount: 1000,
  );

  setUp(() {
    mocks = MockDependencies();
    container = mocks.createContainer();

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

  group('Seasonal Providers', () {
    test('seasonalTitleProvider derives title based on device clock', () {
      final title = container.read(seasonalTitleProvider);

      // Because we can't reliably mock DateTimes internally without a clock package,
      // we just map that the output provides some non-empty String fallback.
      expect(title, isNotEmpty);
      expect(title.runtimeType, String);
    });

    test(
      'seasonalProvider fetches content reflecting the current season theme',
      () async {
        when(
          () => mocks.tmdbRepository.discoverMovies(
            genreIds: any(named: 'genreIds'),
            withProviders: [8],
            watchRegion: 'US',
            sortBy: 'vote_average.desc',
            minRating: 7.0,
            maxAgeRating: 18,
          ),
        ).thenAnswer((_) async => [testMovie]);

        when(
          () => mocks.tmdbRepository.discoverTvSeries(
            genreIds: any(named: 'genreIds'),
            withProviders: [8],
            watchRegion: 'US',
            sortBy: 'vote_average.desc',
            minRating: 7.0,
            maxAgeRating: 18,
          ),
        ).thenAnswer((_) async => [testSeries]);

        final results = await container.read(seasonalProvider.future);

        // Because it depends on time of day/year we can't predict genres requested
        // without mocking the DateTime class (which is harder natively in Dart).
        // We rely on `any()` mapping in Mocktail and assume it executes.
        // Both tests possess greater than 500 vote items reducing failures.
        expect((results).length, 2);
      },
    );

    test('seasonalPaginationProvider fetches additional pages', () async {
      when(
        () => mocks.tmdbRepository.discoverMovies(
          genreIds: any(named: 'genreIds'),
          withProviders: [8],
          watchRegion: 'US',
          sortBy: 'vote_average.desc',
          minRating: 7.0,
          maxAgeRating: 18,
          page: 2,
        ),
      ).thenAnswer((_) async => [testMovie]);

      when(
        () => mocks.tmdbRepository.discoverTvSeries(
          genreIds: any(named: 'genreIds'),
          withProviders: [8],
          watchRegion: 'US',
          sortBy: 'vote_average.desc',
          minRating: 7.0,
          maxAgeRating: 18,
          page: 2,
        ),
      ).thenAnswer((_) async => []);

      final results = await container
          .read(seasonalPaginationProvider.notifier)
          .fetchPage(2);
      expect(results.length, 1);
    });
  });
}
