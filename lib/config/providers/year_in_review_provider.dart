import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/media.dart';
import '../../data/models/watch_history_entry.dart';
import '../../data/models/genre.dart';
import 'watch_history_providers.dart';

// ============================================================================
// Year-in-Review Data Model
// ============================================================================

/// Aggregated stats for a single calendar year, computed from watch history.
class YearInReviewData {
  final int year;
  final int totalMovies;
  final int totalSeries;
  final int totalTitlesWatched;
  final int totalHoursWatched;

  /// Genre id → count, sorted descending by count (top 5 entries).
  final List<MapEntry<int, int>> topGenres;

  /// Top-5 entries the user rated highest.
  final List<WatchHistoryEntry> topRated;

  final double averageUserRating;
  final int ratedCount;

  /// Month key (yyyy-MM) → count for the year, sorted chronologically.
  final List<MapEntry<String, int>> monthlyActivity;

  const YearInReviewData({
    required this.year,
    required this.totalMovies,
    required this.totalSeries,
    required this.totalTitlesWatched,
    required this.totalHoursWatched,
    required this.topGenres,
    required this.topRated,
    required this.averageUserRating,
    required this.ratedCount,
    required this.monthlyActivity,
  });

  /// Returns true when there is enough data to show a meaningful recap.
  bool get hasEnoughData => totalTitlesWatched >= 3;

  String get topGenreName =>
      topGenres.isNotEmpty ? Genre.getNameById(topGenres.first.key) : '—';

  factory YearInReviewData.fromEntries(
    List<WatchHistoryEntry> allEntries,
    int year,
  ) {
    final yearEntries = allEntries
        .where((e) => e.watchedAt.year == year)
        .toList();

    int movies = 0;
    int series = 0;
    int totalMinutes = 0;

    final genreFreq = <int, int>{};
    final monthlyAct = <String, int>{};
    double sumRating = 0;
    int countRating = 0;

    final formatter = DateFormat('yyyy-MM');

    for (final entry in yearEntries) {
      if (entry.mediaType == MediaType.movie) {
        movies++;
        totalMinutes += entry.runtime ?? 100;
      } else {
        series++;
        totalMinutes += entry.runtime ?? 45;
      }

      for (final g in entry.genreIds) {
        genreFreq[g] = (genreFreq[g] ?? 0) + 1;
      }

      final monthKey = formatter.format(entry.watchedAt);
      monthlyAct[monthKey] = (monthlyAct[monthKey] ?? 0) + 1;

      if (entry.userRating != null) {
        sumRating += entry.userRating!;
        countRating++;
      }
    }

    // Top 5 genres sorted by frequency
    final sortedGenres = genreFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGenres = sortedGenres.take(5).toList();

    // Top 5 rated entries
    final ratedEntries = yearEntries.where((e) => e.userRating != null).toList()
      ..sort((a, b) => b.userRating!.compareTo(a.userRating!));
    final topRated = ratedEntries.take(5).toList();

    // Monthly activity sorted chronologically, only within the given year
    final sortedMonthly = monthlyAct.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return YearInReviewData(
      year: year,
      totalMovies: movies,
      totalSeries: series,
      totalTitlesWatched: yearEntries.length,
      totalHoursWatched: totalMinutes ~/ 60,
      topGenres: topGenres,
      topRated: topRated,
      averageUserRating: countRating > 0 ? sumRating / countRating : 0.0,
      ratedCount: countRating,
      monthlyActivity: sortedMonthly,
    );
  }
}

// ============================================================================
// Provider
// ============================================================================

/// Provides [YearInReviewData] for the given [year].
/// Uses the existing [watchHistoryEntriesProvider] as data source.
final yearInReviewProvider = FutureProvider.family<YearInReviewData, int>((
  ref,
  year,
) async {
  final entries = await ref.watch(watchHistoryEntriesProvider.future);
  return YearInReviewData.fromEntries(entries, year);
});

/// Convenience provider for the current year's review.
final currentYearReviewProvider = FutureProvider<YearInReviewData>((ref) async {
  final year = DateTime.now().year;
  return ref.watch(yearInReviewProvider(year).future);
});

/// Returns the list of years (descending) that have at least one entry.
final reviewableYearsProvider = FutureProvider<List<int>>((ref) async {
  final entries = await ref.watch(watchHistoryEntriesProvider.future);
  final years = entries.map((e) => e.watchedAt.year).toSet().toList()
    ..sort((a, b) => b.compareTo(a));
  return years;
});
