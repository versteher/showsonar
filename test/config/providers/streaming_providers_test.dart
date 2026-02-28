import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/config/providers/streaming_providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:stream_scout/data/repositories/tmdb_repository.dart';

import '../../utils/test_provider_container.dart';

void main() {
  late MockDependencies mocks;
  late ProviderContainer container;

  setUp(() {
    mocks = MockDependencies();
    container = mocks.createContainer();

    const subbedPrefs = UserPreferences(
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
    ).thenAnswer((_) async => subbedPrefs);
  });

  tearDown(() {
    container.dispose();
  });

  group('Streaming Providers', () {
    test(
      'providerCountsProvider tallies content across available catalog',
      () async {
        when(
          () => mocks.tmdbRepository.discoverMoviesWithCount(
            withProviders: any(named: 'withProviders'),
            watchRegion: 'US',
            minRating: 0.0,
            maxAgeRating: 18,
          ),
        ).thenAnswer((_) async => (results: <Media>[], totalResults: 15));

        when(
          () => mocks.tmdbRepository.discoverTvSeriesWithCount(
            withProviders: any(named: 'withProviders'),
            watchRegion: 'US',
            minRating: 0.0,
            maxAgeRating: 18,
          ),
        ).thenAnswer((_) async => (results: <Media>[], totalResults: 10));

        final counts = await container.read(providerCountsProvider.future);

        // Assumes US country code grabs US providers internally
        expect(counts, isNotEmpty);
        expect(counts.values.first, 25); // 15 movies + 10 tv shows
      },
    );

    test('mediaAvailabilityProvider fetches mapped logo URLs', () async {
      when(
        () => mocks.tmdbRepository.getWatchProviders(
          1,
          MediaType.movie,
          region: 'US',
        ),
      ).thenAnswer(
        (_) async => const WatchProviderResult(
          link: 'http',
          flatrate: [
            WatchProvider(
              providerId: 8,
              name: 'Netflix',
              logoPath: '/netflix.jpg',
            ),
          ],
          buy: [],
          rent: [],
        ),
      );

      final available = await container.read(
        mediaAvailabilityProvider((id: 1, type: MediaType.movie)).future,
      );
      expect(available, isNotEmpty);
      expect(available.first.provider.id, 'netflix');
      expect(available.first.logoUrl, 'assets/images/netflix_logo.png');
    });
  });
}
