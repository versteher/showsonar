import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
import '../../utils/media_filter.dart';
import '../providers.dart';

// ============================================================================
// Mood-Based Discovery Providers
// ============================================================================

/// Available moods for quick discovery
enum DiscoveryMood {
  feelGood('😊', 'Feel-Good', [35, 10751, 16]),
  thrilling('😰', 'Spannend', [53, 28, 80]),
  mindBending('🤯', 'Mind-Blowing', [878, 9648]),
  romantic('💕', 'Romantisch', [10749, 18]),
  documentary('🎓', 'Doku', [99]),
  darkGritty('🌑', 'Düster', [27, 10752, 18]);

  final String emoji;
  final String label;
  final List<int> genreIds;

  const DiscoveryMood(this.emoji, this.label, this.genreIds);
}

/// Currently selected mood
final selectedMoodProvider = StateProvider<DiscoveryMood?>((ref) => null);

/// Provider that fetches content matching the selected mood
final moodDiscoverProvider = FutureProvider<List<Media>>((ref) async {
  final mood = ref.watch(selectedMoodProvider);
  if (mood == null) return [];

  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  final movies = await tmdb.discoverMovies(
    genreIds: mood.genreIds,
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    sortBy: 'vote_average.desc',
    minRating: max(6.5, prefs.minimumRating),
    maxAgeRating: prefs.maxAgeRating,
  );

  final tvShows = await tmdb.discoverTvSeries(
    genreIds: mood.genreIds,
    withProviders: providerIds,
    watchRegion: prefs.countryCode,
    sortBy: 'vote_average.desc',
    minRating: max(6.5, prefs.minimumRating),
    maxAgeRating: prefs.maxAgeRating,
  );

  final combined = [...movies, ...tvShows];
  final filtered = MediaFilter.applyPreferences(combined, prefs);
  filtered.sort((a, b) => (b.voteAverage).compareTo(a.voteAverage));
  return filtered.take(20).toList();
});
