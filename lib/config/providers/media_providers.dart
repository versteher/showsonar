import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
import '../../data/models/person.dart';
import '../../domain/recommendation_engine.dart';

import '../../utils/media_filter.dart';
import '../providers.dart';

/// Provider for trending content - filtered by user's streaming services
/// Uses discover sorted by popularity since /trending doesn't support provider filter
final trendingProvider = FutureProvider<List<Media>>((ref) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  final movies = await tmdb.discoverMovies(
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    sortBy: 'popularity.desc',
    maxAgeRating: prefs.maxAgeRating,
    minRating: prefs.minimumRating,
  );

  final tvSeries = await tmdb.discoverTvSeries(
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    sortBy: 'popularity.desc',
    maxAgeRating: prefs.maxAgeRating,
    minRating: prefs.minimumRating,
  );

  final combined = [...movies, ...tvSeries];
  final filtered = MediaFilter.applyPreferences(combined, prefs);
  filtered.sort((a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0));

  // Take top items
  final topItems = filtered.take(20).toList();

  // Enrich top 5 items with provider info for the carousel
  if (topItems.isNotEmpty) {
    // We only need to enrich the first 5 for the carousel
    final countToEnrich = min(5, topItems.length);
    final enrichedItems = await Future.wait(
      topItems.take(countToEnrich).map((media) async {
        try {
          final providers = await tmdb.getWatchProviders(
            media.id,
            media.type,
            region: prefs.countryCode,
          );

          // Combine flatrate options
          // If user has specific filters, only show those. Otherwise show all flatrate.
          final providersList = <({int id, String logoUrl, String name})>[];
          final userIds = prefs.tmdbProviderIds;

          for (final p in providers.flatrate) {
            if (userIds.isEmpty || userIds.contains(p.providerId)) {
              if (p.logoPath != null) {
                providersList.add((
                  id: p.providerId,
                  logoUrl: 'https://image.tmdb.org/t/p/original${p.logoPath}',
                  name: p.name,
                ));
              }
            }
          }

          return media.copyWith(providerData: providersList.take(3).toList());
        } catch (e) {
          // If enrichment fails, return original media
          return media;
        }
      }),
    );

    // Replace the first few items with enriched ones
    for (int i = 0; i < enrichedItems.length; i++) {
      topItems[i] = enrichedItems[i];
    }
  }

  return topItems;
});

/// Provider for popular movies - filtered by user's streaming services
final popularMoviesProvider = FutureProvider<List<Media>>((ref) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  final results = await tmdb.discoverMovies(
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    sortBy: 'popularity.desc',
    maxAgeRating: prefs.maxAgeRating,
    minRating: prefs.minimumRating,
  );

  return MediaFilter.applyPreferences(results, prefs);
});

/// Provider for popular TV series - filtered by user's streaming services
final popularTvSeriesProvider = FutureProvider<List<Media>>((ref) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  final results = await tmdb.discoverTvSeries(
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    sortBy: 'popularity.desc',
    maxAgeRating: prefs.maxAgeRating,
    minRating: prefs.minimumRating,
  );

  return MediaFilter.applyPreferences(results, prefs);
});

/// Provider for top rated movies - filtered by user's streaming services
final topRatedMoviesProvider = FutureProvider<List<Media>>((ref) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  final results = await tmdb.discoverMovies(
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    sortBy: 'vote_average.desc',
    minRating: max(7.0, prefs.minimumRating),
    maxAgeRating: prefs.maxAgeRating,
  );

  return MediaFilter.applyPreferences(results, prefs);
});

/// Provider for top rated TV series - filtered by user's streaming services
final topRatedTvSeriesProvider = FutureProvider<List<Media>>((ref) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  final results = await tmdb.discoverTvSeries(
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    sortBy: 'vote_average.desc',
    minRating: max(7.0, prefs.minimumRating),
    maxAgeRating: prefs.maxAgeRating,
  );

  return MediaFilter.applyPreferences(results, prefs);
});

/// Provider for upcoming movies - filtered by user's streaming services
final upcomingMoviesProvider = FutureProvider<List<Media>>((ref) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  final results = await tmdb.getUpcomingMovies(
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    maxAgeRating: prefs.maxAgeRating,
    minRating: prefs.minimumRating,
  );

  return MediaFilter.applyPreferences(results, prefs);
});

/// Provider for upcoming TV series - filtered by user's streaming services
final upcomingTvProvider = FutureProvider<List<Media>>((ref) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  final results = await tmdb.getUpcomingTvSeries(
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    maxAgeRating: prefs.maxAgeRating,
    minRating: prefs.minimumRating,
  );

  return MediaFilter.applyPreferences(results, prefs);
});

/// Combined upcoming content (movies + TV)
final upcomingProvider = FutureProvider<List<Media>>((ref) async {
  final movies = await ref.watch(upcomingMoviesProvider.future);
  final tvShows = await ref.watch(upcomingTvProvider.future);

  final combined = [...movies, ...tvShows];
  combined.sort((a, b) {
    final aDate = a.releaseDate ?? DateTime(2099);
    final bDate = b.releaseDate ?? DateTime(2099);
    return aDate.compareTo(bDate);
  });
  return combined.take(20).toList();
});

/// Provider for trailer URL
final trailerUrlProvider =
    FutureProvider.family<String?, ({int id, MediaType type})>((
      ref,
      params,
    ) async {
      final tmdb = ref.watch(tmdbRepositoryProvider);
      return tmdb.getTrailerUrl(params.id, params.type);
    });

/// Provider for search results
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Media>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty || query.length < 2) return [];

  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);

  return tmdb.searchMulti(
    query,
    includeAdult: prefs.includeAdult,
    maxAgeRating: prefs.maxAgeRating,
  );
});

/// Provider for movie/series details
final mediaDetailsProvider =
    FutureProvider.family<Media, ({int id, MediaType type})>((
      ref,
      params,
    ) async {
      final tmdb = ref.watch(tmdbRepositoryProvider);

      if (params.type == MediaType.movie) {
        return tmdb.getMovieDetails(params.id);
      } else {
        return tmdb.getTvDetails(params.id);
      }
    });

/// Provider for similar content
final similarContentProvider =
    FutureProvider.family<List<Media>, ({int id, MediaType type})>((
      ref,
      params,
    ) async {
      final tmdb = ref.watch(tmdbRepositoryProvider);
      return tmdb.getSimilar(params.id, params.type);
    });

/// Provider for recommendations based on specific media
final mediaRecommendationsProvider =
    FutureProvider.family<List<Media>, ({int id, MediaType type})>((
      ref,
      params,
    ) async {
      final tmdb = ref.watch(tmdbRepositoryProvider);
      return tmdb.getRecommendations(params.id, params.type);
    });

/// Sort mode for genre sections: 'popularity.desc' or 'vote_average.desc'
final genreSortByProvider = StateProvider<String>((ref) => 'popularity.desc');

/// Currently selected genre ID for the Entdecken section.
/// Defaults to user's most-watched genre, or Comedy if no history.
final selectedGenreProvider = StateProvider<int>((ref) {
  return 35; // default: Komödie
});

/// Toggle to hide already-watched content from carousels
final hideWatchedProvider = StateProvider<bool>((ref) => false);

/// Provider for genre-based content discovery with pagination (#10)
final genreDiscoverProvider =
    FutureProvider.family<List<Media>, ({int genreId, String sortBy})>((
      ref,
      params,
    ) async {
      final tmdb = ref.watch(tmdbRepositoryProvider);
      final prefs = await ref.watch(userPreferencesProvider.future);
      final providerIds = prefs.tmdbProviderIds;

      if (providerIds.isEmpty) return [];

      // Fetch 2 pages in parallel for richer content
      final results = await Future.wait([
        tmdb.discoverMovies(
          genreIds: [params.genreId],
          sortBy: params.sortBy,
          withProviders: providerIds,
          watchRegion: prefs.countryCode,
          minRating: prefs.minimumRating,
          maxAgeRating: prefs.maxAgeRating,
          page: 1,
        ),
        tmdb.discoverMovies(
          genreIds: [params.genreId],
          sortBy: params.sortBy,
          withProviders: providerIds,
          watchRegion: prefs.countryCode,
          minRating: prefs.minimumRating,
          maxAgeRating: prefs.maxAgeRating,
          page: 2,
        ),
      ]);

      final combined = [...results[0], ...results[1]];
      // Deduplicate by ID
      final seen = <int>{};
      final deduped = combined.where((m) => seen.add(m.id)).toList();
      return MediaFilter.applyPreferences(deduped, prefs);
    });

// ============================================================================
// "Because You Watched" Provider
// ============================================================================

/// Provider for "Because You Watched X" recommendations.
/// Uses the existing RecommendationEngine which returns groups of similar
/// content based on the user's highly-rated watch history items.
final becauseYouWatchedProvider = FutureProvider<List<RecommendationGroup>>((
  ref,
) async {
  final engine = await ref.watch(recommendationEngineProvider.future);
  return engine.getBecauseYouWatched(groupLimit: 3);
});

// ============================================================================
// "Hidden Gems" Provider
// ============================================================================

/// Provider for hidden gem content: high rating + lower popularity.
/// Surfaces quality content that users wouldn't normally find browsing
/// mainstream lists. Filters to popularity < 80 (not viral) and
/// voteCount >= 500 (enough reviews to trust the rating).
final hiddenGemsProvider = FutureProvider<List<Media>>((ref) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  // Fetch both movies and TV, sorted by rating
  final results = await Future.wait([
    tmdb.discoverMovies(
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      sortBy: 'vote_average.desc',
      minRating: max(7.5, prefs.minimumRating),
      maxAgeRating: prefs.maxAgeRating,
    ),
    tmdb.discoverTvSeries(
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      sortBy: 'vote_average.desc',
      minRating: max(7.5, prefs.minimumRating),
      maxAgeRating: prefs.maxAgeRating,
    ),
  ]);

  final combined = [...results[0], ...results[1]];
  final filtered = MediaFilter.applyPreferences(combined, prefs);

  // Hidden gems: high quality but not mainstream
  final gems = filtered.where((m) {
    final pop = m.popularity ?? 0;
    return pop < 80 && m.voteCount >= 500;
  }).toList();

  // Sort by rating descending
  gems.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
  return gems.take(20).toList();
});

class HiddenGemsPaginationNotifier extends PaginationNotifier {
  final Ref ref;
  HiddenGemsPaginationNotifier(this.ref);

  @override
  Future<List<Media>> fetchPage(int page) async {
    final tmdb = ref.read(tmdbRepositoryProvider);
    final prefs = await ref.read(userPreferencesProvider.future);
    final providerIds = prefs.tmdbProviderIds;

    if (providerIds.isEmpty) return [];

    final results = await Future.wait([
      tmdb.discoverMovies(
        withProviders: providerIds,
        watchRegion: prefs.countryCode,
        sortBy: 'vote_average.desc',
        minRating: max(7.5, prefs.minimumRating),
        maxAgeRating: prefs.maxAgeRating,
        page: page,
      ),
      tmdb.discoverTvSeries(
        withProviders: providerIds,
        watchRegion: prefs.countryCode,
        sortBy: 'vote_average.desc',
        minRating: max(7.5, prefs.minimumRating),
        maxAgeRating: prefs.maxAgeRating,
        page: page,
      ),
    ]);

    final combined = [...results[0], ...results[1]];
    final filtered = MediaFilter.applyPreferences(combined, prefs);

    // Hidden gems: high quality but not mainstream
    final gems = filtered.where((m) {
      final pop = m.popularity ?? 0;
      return pop < 80 && m.voteCount >= 500;
    }).toList();

    gems.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
    return gems;
  }
}

final hiddenGemsPaginationProvider =
    StateNotifierProvider<
      HiddenGemsPaginationNotifier,
      AsyncValue<PaginationState<Media>>
    >((ref) => HiddenGemsPaginationNotifier(ref));

/// Provider for actor/director details
final personDetailsProvider = FutureProvider.family<Person, int>((
  ref,
  personId,
) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  return tmdb.getPersonDetails(personId);
});

/// Provider for actor/director filmography credits
final personCreditsProvider = FutureProvider.family<List<PersonCredit>, int>((
  ref,
  personId,
) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  return tmdb.getPersonCredits(personId);
});
