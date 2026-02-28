import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
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
