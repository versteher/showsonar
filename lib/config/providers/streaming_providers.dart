import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
import '../../data/models/streaming_provider.dart';
import '../providers.dart';

// ============================================================================
// Streaming Availability & Counts Providers
// ============================================================================

/// Provider for the number of matching titles per streaming provider.
/// Uses keepAlive to avoid refetching on every widget rebuild.
final providerCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  ref.keepAlive();

  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);

  final counts = <String, int>{};

  final List<StreamingProvider> allProviders =
      StreamingProvider.getProvidersForCountry(prefs.countryCode);

  await Future.wait(
    allProviders.map((provider) async {
      final tmdbId = provider.tmdbId;
      if (tmdbId == null) return;

      try {
        final movieResults = await tmdb.discoverMoviesWithCount(
          withProviders: [tmdbId],
          watchRegion: prefs.countryCode,
          minRating: prefs.minimumRating,
          maxAgeRating: prefs.maxAgeRating,
        );

        final tvResults = await tmdb.discoverTvSeriesWithCount(
          withProviders: [tmdbId],
          watchRegion: prefs.countryCode,
          minRating: prefs.minimumRating,
          maxAgeRating: prefs.maxAgeRating,
        );

        counts[provider.id] =
            movieResults.totalResults + tvResults.totalResults;
      } catch (e) {
        counts[provider.id] = 0;
      }
    }),
  );

  return counts;
});

/// Provider for streaming availability of a specific media item.
/// Uses keepAlive so logo data is cached and doesn't flicker when cards
/// scroll in and out of view.
final mediaAvailabilityProvider =
    FutureProvider.family<
      List<({StreamingProvider provider, String logoUrl})>,
      ({int id, MediaType type})
    >((ref, params) async {
      ref.keepAlive();
      final tmdb = ref.watch(tmdbRepositoryProvider);
      final prefs = await ref.watch(userPreferencesProvider.future);

      try {
        final results = await tmdb.getWatchProviders(
          params.id,
          params.type,
          region: prefs.countryCode,
        );

        // Deduplicate by internal provider ID — TMDB can return the same
        // provider multiple times in the flatrate list (e.g. via different
        // sub-IDs), which would otherwise show the logo twice.
        final available = <({StreamingProvider provider, String logoUrl})>[];
        final seenIds = <String>{};
        for (final p in results.flatrate) {
          final internal = StreamingProvider.fromTmdbId(p.providerId);
          if (internal != null && seenIds.add(internal.id)) {
            available.add((provider: internal, logoUrl: internal.logoPath));
          }
        }
        return available;
      } catch (e) {
        return [];
      }
    });
