import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
import '../../utils/media_filter.dart';
import '../providers.dart';

// ============================================================================
// Seasonal/Contextual Recommendations Provider
// ============================================================================

/// Genre IDs mapped to seasonal themes
class _SeasonalTheme {
  final String titleDe;
  final String titleEn;
  final String emoji;
  final List<int> genreIds;

  const _SeasonalTheme({
    required this.titleDe,
    required this.titleEn,
    required this.emoji,
    required this.genreIds,
  });
}

/// Get the seasonal theme for the current date
_SeasonalTheme _getCurrentTheme() {
  final now = DateTime.now();
  final month = now.month;
  final weekday = now.weekday; // 1=Mon, 7=Sun
  final hour = now.hour;

  // October = Horror season
  if (month == 10) {
    return const _SeasonalTheme(
      titleDe: '🎃 Halloween-Stimmung',
      titleEn: '🎃 Halloween Season',
      emoji: '🎃',
      genreIds: [27, 53, 9648], // Horror, Thriller, Mystery
    );
  }

  // December = Holiday movies
  if (month == 12) {
    return const _SeasonalTheme(
      titleDe: '🎄 Weihnachtsklassiker',
      titleEn: '🎄 Holiday Favorites',
      emoji: '🎄',
      genreIds: [10751, 35, 14], // Family, Comedy, Fantasy
    );
  }

  // February = Romance
  if (month == 2) {
    return const _SeasonalTheme(
      titleDe: '💕 Valentinstag',
      titleEn: '💕 Romance Season',
      emoji: '💕',
      genreIds: [10749, 18, 35], // Romance, Drama, Comedy
    );
  }

  // Summer (June-August) = Action & Adventure
  if (month >= 6 && month <= 8) {
    return const _SeasonalTheme(
      titleDe: '☀️ Sommer-Blockbuster',
      titleEn: '☀️ Summer Blockbusters',
      emoji: '☀️',
      genreIds: [28, 12, 878], // Action, Adventure, Sci-Fi
    );
  }

  // Weekend evening = Longer content
  if ((weekday == 6 || weekday == 7) && hour >= 18) {
    return const _SeasonalTheme(
      titleDe: '🍿 Wochenend-Kino',
      titleEn: '🍿 Weekend Cinema',
      emoji: '🍿',
      genreIds: [18, 878, 12], // Drama, Sci-Fi, Adventure
    );
  }

  // Weeknight = Short comfort viewing
  if (hour >= 20 && weekday >= 1 && weekday <= 5) {
    return const _SeasonalTheme(
      titleDe: '😌 Feierabend-Entspannung',
      titleEn: '😌 After-Work Unwind',
      emoji: '😌',
      genreIds: [35, 10751, 16], // Comedy, Family, Animation
    );
  }

  // Default: Autumn vibes / Discovery
  return const _SeasonalTheme(
    titleDe: '🍂 Entdeckungsreise',
    titleEn: '🍂 Discovery Time',
    emoji: '🍂',
    genreIds: [18, 9648, 36], // Drama, Mystery, History
  );
}

/// Seasonal section title
final seasonalTitleProvider = Provider<String>((ref) {
  final theme = _getCurrentTheme();
  return theme.titleDe;
});

/// Seasonal content provider
final seasonalProvider = FutureProvider<List<Media>>((ref) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;
  final theme = _getCurrentTheme();

  if (providerIds.isEmpty) return [];

  final results = await Future.wait([
    tmdb.discoverMovies(
      genreIds: theme.genreIds,
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      sortBy: 'vote_average.desc',
      minRating: max(7.0, prefs.minimumRating),
      maxAgeRating: prefs.maxAgeRating,
    ),
    tmdb.discoverTvSeries(
      genreIds: theme.genreIds,
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      sortBy: 'vote_average.desc',
      minRating: max(7.0, prefs.minimumRating),
      maxAgeRating: prefs.maxAgeRating,
    ),
  ]);

  final combined = [...results[0], ...results[1]];
  final filtered = MediaFilter.applyPreferences(combined, prefs);
  // Ensure decent vote count
  final quality = filtered.where((m) => m.voteCount >= 500).toList();
  quality.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
  return quality.take(20).toList();
});

class SeasonalPaginationNotifier extends PaginationNotifier {
  final Ref ref;
  SeasonalPaginationNotifier(this.ref);

  @override
  Future<List<Media>> fetchPage(int page) async {
    final tmdb = ref.read(tmdbRepositoryProvider);
    final prefs = await ref.read(userPreferencesProvider.future);
    final providerIds = prefs.tmdbProviderIds;
    final theme = _getCurrentTheme();

    if (providerIds.isEmpty) return [];

    final results = await Future.wait([
      tmdb.discoverMovies(
        genreIds: theme.genreIds,
        withProviders: providerIds,
        watchRegion: prefs.countryCode,
        sortBy: 'vote_average.desc',
        minRating: max(7.0, prefs.minimumRating),
        maxAgeRating: prefs.maxAgeRating,
        page: page,
      ),
      tmdb.discoverTvSeries(
        genreIds: theme.genreIds,
        withProviders: providerIds,
        watchRegion: prefs.countryCode,
        sortBy: 'vote_average.desc',
        minRating: max(7.0, prefs.minimumRating),
        maxAgeRating: prefs.maxAgeRating,
        page: page,
      ),
    ]);

    final combined = [...results[0], ...results[1]];
    final filtered = MediaFilter.applyPreferences(combined, prefs);
    // Ensure decent vote count
    final quality = filtered.where((m) => m.voteCount >= 500).toList();
    quality.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
    return quality
        .take(20)
        .toList(); // Currently still returning just the top 20 of that page
  }
}

final seasonalPaginationProvider =
    StateNotifierProvider<
      SeasonalPaginationNotifier,
      AsyncValue<PaginationState<Media>>
    >((ref) => SeasonalPaginationNotifier(ref));
