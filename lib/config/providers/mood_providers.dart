import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/media.dart';
import '../../utils/media_filter.dart';
import '../providers.dart';

part 'mood_providers.g.dart';

// ============================================================================
// Mood-Based Discovery Providers
// ============================================================================

/// Available moods for quick discovery
enum DiscoveryMood {
  feelGood(
    '😊',
    'Feel-Good',
    [35, 10751, 16],
    [9715, 6054],
  ), // feel good, friendship
  thrilling('😰', 'Spannend', [53, 28, 80], [10001, 1969]), // suspense, tension
  mindBending(
    '🤯',
    'Mind-Blowing',
    [878, 9648],
    [4344, 11578],
  ), // mind fuck, plot twist
  romantic('💕', 'Romantisch', [10749, 18], [9840, 3205]), // romance, true love
  documentary('🎓', 'Doku', [99], [250570, 240801]), // real life, true story
  darkGritty('🌑', 'Düster', [27, 10752, 18], [11116, 219503]); // dark, gritty

  final String emoji;
  final String label;
  final List<int> genreIds;
  final List<int> keywordIds;

  const DiscoveryMood(this.emoji, this.label, this.genreIds, this.keywordIds);
}

/// Currently selected mood
final selectedMoodProvider = StateProvider<DiscoveryMood?>((ref) => null);

/// Provider that fetches content matching the selected mood
@riverpod
Future<List<Media>> moodDiscover(Ref ref) async {
  final mood = ref.watch(selectedMoodProvider);
  if (mood == null) return [];

  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return [];

  final movies = await tmdb.discoverMovies(
    genreIds: mood.genreIds,
    withProviders: providerIds,
    withKeywords: mood.keywordIds,
    watchRegion: prefs.countryCode,
    sortBy: 'vote_average.desc',
    minRating: max(6.5, prefs.minimumRating),
    maxAgeRating: prefs.maxAgeRating,
  );

  final tvShows = await tmdb.discoverTvSeries(
    genreIds: mood.genreIds,
    withProviders: providerIds,
    withKeywords: mood.keywordIds,
    watchRegion: prefs.countryCode,
    sortBy: 'vote_average.desc',
    minRating: max(6.5, prefs.minimumRating),
    maxAgeRating: prefs.maxAgeRating,
  );

  final combined = [...movies, ...tvShows];
  final filtered = MediaFilter.applyPreferences(combined, prefs);
  filtered.sort((a, b) => (b.voteAverage).compareTo(a.voteAverage));
  return filtered.take(20).toList();
}
