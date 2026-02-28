import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/media.dart';
import '../../domain/recommendation_engine.dart';
import '../../utils/media_filter.dart';
import '../providers.dart';

part 'media_discover_providers.g.dart';

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
@riverpod
Future<List<Media>> genreDiscover(
  Ref ref, {
  required int genreId,
  required String sortBy,
}) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  // Fetch 2 pages in parallel for richer content
  final results = await Future.wait([
    tmdb.discoverMovies(
      genreIds: [genreId],
      sortBy: sortBy,
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      minRating: prefs.minimumRating,
      maxAgeRating: prefs.maxAgeRating,
      page: 1,
    ),
    tmdb.discoverMovies(
      genreIds: [genreId],
      sortBy: sortBy,
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
}

// ============================================================================
// "Because You Watched" Provider
// ============================================================================

/// Provider for "Because You Watched X" recommendations.
/// Uses the existing RecommendationEngine which returns groups of similar
/// content based on the user's highly-rated watch history items.
@riverpod
Future<List<RecommendationGroup>> becauseYouWatched(Ref ref) async {
  final engine = await ref.watch(recommendationEngineProvider.future);
  return engine.getBecauseYouWatched(groupLimit: 3);
}

// ============================================================================
// "Hidden Gems" Provider
// ============================================================================

/// Provider for hidden gem content: high rating + lower popularity.
/// Surfaces quality content that users wouldn't normally find browsing
/// mainstream lists. Filters to popularity < 80 (not viral) and
/// voteCount >= 500 (enough reviews to trust the rating).
@riverpod
Future<List<Media>> hiddenGems(Ref ref) async {
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
}

class HiddenGemsPaginationNotifier extends PaginationNotifier {
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
    AsyncNotifierProvider<HiddenGemsPaginationNotifier, PaginationState<Media>>(
      HiddenGemsPaginationNotifier.new,
    );
