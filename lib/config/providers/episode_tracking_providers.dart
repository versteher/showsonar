import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tv_season.dart';
import '../../data/models/tv_episode.dart';
import '../../data/repositories/episode_tracking_repository.dart';
import '../providers.dart';
import '../firebase_fallback.dart';

// ============================================================================
// Episode Tracking Repository Provider
// ============================================================================

final episodeTrackingRepositoryProvider = Provider<EpisodeTrackingRepository>((
  ref,
) {
  final user = ref.watch(authStateProvider).value;
  return EpisodeTrackingRepository(
    user?.uid ?? 'guest',
    firestore: firestoreInstance,
  );
});

// ============================================================================
// Watched Episodes Provider (per series)
// ============================================================================

/// Returns the set of watched episode keys for a given TV series.
/// Keys are in format "sN_eN" (e.g. "s1_e3").
final watchedEpisodesProvider = FutureProvider.family<Set<String>, int>((
  ref,
  tvId,
) async {
  final repo = ref.watch(episodeTrackingRepositoryProvider);
  return repo.getWatchedEpisodes(tvId);
});

// ============================================================================
// Season Detail Provider (per series + season number)
// ============================================================================

typedef SeasonParams = ({int tvId, int seasonNumber});

/// Fetches season details (with episodes) from TMDB for the given series + season.
final tvSeasonProvider = FutureProvider.family<TvSeason, SeasonParams>((
  ref,
  params,
) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  return tmdb.getTvSeasonDetails(params.tvId, params.seasonNumber);
});

// ============================================================================
// Series Progress Provider
// ============================================================================

/// Holds (watched, total) episode counts for a given TV series across all aired episodes.
/// Uses already-fetched watched episodes; total is computed from [numberOfSeasons].
class SeriesProgress {
  final int watched;
  final int total;

  const SeriesProgress({required this.watched, required this.total});

  double get fraction => total == 0 ? 0 : watched / total;
  bool get isComplete => total > 0 && watched >= total;
}

final seriesProgressProvider = FutureProvider.family<SeriesProgress, int>((
  ref,
  tvId,
) async {
  final watchedKeys = await ref.watch(watchedEpisodesProvider(tvId).future);
  return SeriesProgress(
    watched: watchedKeys.length,
    total: 0,
  ); // total filled per-screen
});

// ============================================================================
// Next Unwatched Episode Provider
// ============================================================================

/// Given a [TvSeason], returns the first unwatched aired episode, if any.
TvEpisode? nextUnwatchedInSeason(TvSeason season, Set<String> watchedKeys) {
  for (final ep in season.episodes) {
    if (!ep.hasAired) continue; // skip future episodes
    final key = EpisodeTrackingRepository.episodeKey(
      ep.seasonNumber,
      ep.episodeNumber,
    );
    if (!watchedKeys.contains(key)) return ep;
  }
  return null;
}
