import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/config/providers/mood_providers.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';

import '../../utils/test_provider_container.dart';

void main() {
  late MockDependencies mocks;
  late ProviderContainer container;

  final testMovie = Media(
    id: 1,
    title: 'Good Movie',
    overview: 'High rating',
    genreIds: [35, 10751], // Feel-Good genres
    type: MediaType.movie,
    voteAverage: 8.5,
    voteCount: 5000,
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

  group('Mood Providers', () {
    test('selectedMoodProvider defaults to null and can be updated', () {
      final initial = container.read(selectedMoodProvider);
      expect(initial, isNull);

      container.read(selectedMoodProvider.notifier).state =
          DiscoveryMood.feelGood;
      final updated = container.read(selectedMoodProvider);
      expect(updated, DiscoveryMood.feelGood);
    });

    test('moodDiscoverProvider returns empty if no mood selected', () async {
      final results = await container.read(moodDiscoverProvider.future);
      expect(results, isEmpty);
      verifyNever(
        () => mocks.tmdbRepository.discoverMovies(
          genreIds: any(named: 'genreIds'),
          withProviders: any(named: 'withProviders'),
        ),
      );
    });

    test(
      'moodDiscoverProvider triggers TMDB search for selected mood genres',
      () async {
        container.read(selectedMoodProvider.notifier).state =
            DiscoveryMood.feelGood;

        when(
          () => mocks.tmdbRepository.discoverMovies(
            genreIds: DiscoveryMood.feelGood.genreIds,
            withProviders: [8],
            watchRegion: 'US',
            sortBy: 'vote_average.desc',
            minRating: 6.5,
            maxAgeRating: 18,
          ),
        ).thenAnswer((_) async => [testMovie]);

        when(
          () => mocks.tmdbRepository.discoverTvSeries(
            genreIds: DiscoveryMood.feelGood.genreIds,
            withProviders: [8],
            watchRegion: 'US',
            sortBy: 'vote_average.desc',
            minRating: 6.5,
            maxAgeRating: 18,
          ),
        ).thenAnswer((_) async => []);

        final results = await container.read(moodDiscoverProvider.future);
        expect((results).length, 1);
        expect((results).first.title, 'Good Movie');
      },
    );
  });
}
