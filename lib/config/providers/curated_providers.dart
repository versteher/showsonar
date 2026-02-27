import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
import '../../data/models/user_preferences.dart';
import '../../data/repositories/tmdb_repository.dart';
import '../../utils/media_filter.dart';
import '../providers.dart';

// ============================================================================
// Curated Collection Providers
// ============================================================================

/// Available curated collections
enum CuratedCollection {
  criticallyAcclaimed('⭐ Critically Acclaimed', 'Kritiker-Lieblinge'),
  perfectForTonight('🌙 Perfect for Tonight', 'Perfekt für heute Abend'),
  bingeWorthy('📺 Binge-Worthy', 'Serien-Marathon'),
  modernClassics('🏆 Modern Classics', 'Moderne Klassiker');

  final String labelEn;
  final String labelDe;
  const CuratedCollection(this.labelEn, this.labelDe);
}

/// Currently selected collection
final selectedCollectionProvider = StateProvider<CuratedCollection>(
  (ref) => CuratedCollection.criticallyAcclaimed,
);

/// Provider for curated collection content
final curatedCollectionProvider = FutureProvider<List<Media>>((ref) async {
  final collection = ref.watch(selectedCollectionProvider);
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  switch (collection) {
    case CuratedCollection.criticallyAcclaimed:
      return _fetchCriticallyAcclaimed(tmdb, prefs, providerIds);
    case CuratedCollection.perfectForTonight:
      return _fetchPerfectForTonight(tmdb, prefs, providerIds);
    case CuratedCollection.bingeWorthy:
      return _fetchBingeWorthy(tmdb, prefs, providerIds);
    case CuratedCollection.modernClassics:
      return _fetchModernClassics(tmdb, prefs, providerIds);
  }
});

/// Critically Acclaimed: ≥ 8.0 rating + high vote count
Future<List<Media>> _fetchCriticallyAcclaimed(
  ITmdbRepository tmdb,
  UserPreferences prefs,
  List<int> providerIds,
) async {
  final results = await Future.wait([
    tmdb.discoverMovies(
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      sortBy: 'vote_average.desc',
      minRating: 8.0,
      maxAgeRating: prefs.maxAgeRating,
    ),
    tmdb.discoverTvSeries(
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      sortBy: 'vote_average.desc',
      minRating: 8.0,
      maxAgeRating: prefs.maxAgeRating,
    ),
  ]);

  final combined = [...results[0], ...results[1]];
  final filtered = MediaFilter.applyPreferences(combined, prefs);
  // Only show items with significant vote counts
  final quality = filtered.where((m) => m.voteCount >= 3000).toList();
  quality.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
  return quality.take(20).toList();
}

/// Perfect for Tonight: Short movies (< 120 min) with high ratings
Future<List<Media>> _fetchPerfectForTonight(
  ITmdbRepository tmdb,
  UserPreferences prefs,
  List<int> providerIds,
) async {
  final movies = await tmdb.discoverMovies(
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    sortBy: 'vote_average.desc',
    minRating: max(7.0, prefs.minimumRating),
    maxAgeRating: prefs.maxAgeRating,
  );

  final filtered = MediaFilter.applyPreferences(movies, prefs);
  // Only short movies with decent vote counts
  final tonight = filtered.where((m) {
    final runtime = m.runtime ?? 0;
    return runtime > 0 && runtime <= 120 && m.voteCount >= 500;
  }).toList();
  tonight.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
  return tonight.take(20).toList();
}

/// Binge-Worthy: TV series with ≥ 8.0 rating, 1-3 seasons (completable)
Future<List<Media>> _fetchBingeWorthy(
  ITmdbRepository tmdb,
  UserPreferences prefs,
  List<int> providerIds,
) async {
  final tvShows = await tmdb.discoverTvSeries(
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    sortBy: 'vote_average.desc',
    minRating: max(7.5, prefs.minimumRating),
    maxAgeRating: prefs.maxAgeRating,
  );

  final filtered = MediaFilter.applyPreferences(tvShows, prefs);
  // Only shows with 1-3 seasons
  final bingeable = filtered.where((m) {
    final seasons = m.numberOfSeasons ?? 0;
    return seasons >= 1 && seasons <= 3 && m.voteCount >= 500;
  }).toList();
  bingeable.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
  return bingeable.take(20).toList();
}

/// Modern Classics: Last 10 years, ≥ 8.0, ≥ 10k votes
Future<List<Media>> _fetchModernClassics(
  ITmdbRepository tmdb,
  UserPreferences prefs,
  List<int> providerIds,
) async {
  final cutoffYear = DateTime.now().year - 10;

  final results = await Future.wait([
    tmdb.discoverMovies(
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      sortBy: 'vote_average.desc',
      minRating: 8.0,
      maxAgeRating: prefs.maxAgeRating,
    ),
    tmdb.discoverTvSeries(
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      sortBy: 'vote_average.desc',
      minRating: 8.0,
      maxAgeRating: prefs.maxAgeRating,
    ),
  ]);

  final combined = [...results[0], ...results[1]];
  final filtered = MediaFilter.applyPreferences(combined, prefs);
  // Recent + high vote count
  final modern = filtered.where((m) {
    final year = m.releaseDate?.year ?? 0;
    return year >= cutoffYear && m.voteCount >= 5000;
  }).toList();
  modern.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
  return modern.take(20).toList();
}
