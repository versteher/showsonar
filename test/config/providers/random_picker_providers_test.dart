import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/config/providers/random_picker_providers.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';

import '../../utils/test_provider_container.dart';

void main() {
  late MockDependencies mocks;
  late ProviderContainer container;

  final testMovie = Media(
    id: 1,
    title: 'Random Movie',
    overview: 'High rating',
    genreIds: [28],
    type: MediaType.movie,
    voteAverage: 8.5,
    voteCount: 5000,
  );

  final testSeries = Media(
    id: 2,
    title: 'Random Series',
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

  group('Random Picker Providers', () {
    test('filters initially set to default both and 6.0 rating', () {
      expect(
        container.read(randomPickerFilterProvider),
        RandomPickerFilter.both,
      );
      expect(container.read(randomPickerMinRatingProvider), 6.0);
    });

    test(
      'randomPickerResultProvider pulls movies only if filter applied',
      () async {
        container.read(randomPickerFilterProvider.notifier).state =
            RandomPickerFilter.movies;

        when(
          () => mocks.tmdbRepository.discoverMovies(
            withProviders: [8],
            watchRegion: 'US',
            sortBy: 'popularity.desc',
            minRating: 6.0, // Should be min rating state provider value
            page: any(named: 'page'), // Tests random int logic via any
            maxAgeRating: 18,
          ),
        ).thenAnswer((_) async => [testMovie]);

        final result = await container.read(randomPickerResultProvider.future);
        expect(result?.title, 'Random Movie');

        // Verification no TV shows called
        verifyNever(
          () => mocks.tmdbRepository.discoverTvSeries(
            withProviders: any(named: 'withProviders'),
            watchRegion: any(named: 'watchRegion'),
          ),
        );
      },
    );

    test(
      'randomPickerResultProvider pulls series only if filter applied',
      () async {
        container.read(randomPickerFilterProvider.notifier).state =
            RandomPickerFilter.series;
        container.read(randomPickerMinRatingProvider.notifier).state = 7.5;

        when(
          () => mocks.tmdbRepository.discoverTvSeries(
            withProviders: [8],
            watchRegion: 'US',
            sortBy: 'popularity.desc',
            minRating: 7.5,
            page: any(named: 'page'),
            maxAgeRating: 18,
          ),
        ).thenAnswer((_) async => [testSeries]);

        final result = await container.read(randomPickerResultProvider.future);
        expect(result?.title, 'Random Series');

        // Verification no movie called
        verifyNever(
          () => mocks.tmdbRepository.discoverMovies(
            withProviders: any(named: 'withProviders'),
            watchRegion: any(named: 'watchRegion'),
          ),
        );
      },
    );
  });
}
