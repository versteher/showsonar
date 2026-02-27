import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
import '../../data/models/watch_statistics.dart';
import '../providers.dart';
import 'package:intl/intl.dart';

/// Provider for aggregated user watch statistics
final statisticsProvider = FutureProvider<WatchStatistics>((ref) async {
  final historyAsync = ref.watch(watchHistoryEntriesProvider);

  if (historyAsync.isLoading || historyAsync.hasError) {
    return const WatchStatistics(
      totalMoviesWatched: 0,
      totalSeriesWatched: 0,
      totalHoursSpent: 0,
      genreFrequency: {},
      monthlyActivity: {},
      averageUserRating: 0.0,
      averageCommunityRating: 0.0,
      totalRatedItems: 0,
    );
  }

  final history = historyAsync.valueOrNull ?? [];

  int movies = 0;
  int series = 0;
  int totalMinutes = 0;

  final genreFreq = <int, int>{};
  final monthlyAct = <String, int>{};

  double sumUserRating = 0;
  int countUserRating = 0;
  double sumCommunityRating = 0;
  int countCommunityRating = 0;

  final formatter = DateFormat('yyyy-MM');

  for (final entry in history) {
    // Media type counts
    if (entry.mediaType == MediaType.movie) {
      movies++;
      totalMinutes += entry.runtime ?? 100; // default 100m for movies
    } else {
      series++;
      totalMinutes += entry.runtime ?? 45; // default 45m for tv episodes
    }

    // Genre distribution
    for (final genre in entry.genreIds) {
      genreFreq[genre] = (genreFreq[genre] ?? 0) + 1;
    }

    // Monthly activity
    final monthKey = formatter.format(entry.watchedAt);
    monthlyAct[monthKey] = (monthlyAct[monthKey] ?? 0) + 1;

    // Ratings
    if (entry.userRating != null) {
      sumUserRating += entry.userRating!;
      countUserRating++;
    }

    if (entry.voteAverage != null && entry.voteAverage! > 0) {
      sumCommunityRating += entry.voteAverage!;
      countCommunityRating++;
    }
  }

  return WatchStatistics(
    totalMoviesWatched: movies,
    totalSeriesWatched: series,
    totalHoursSpent: totalMinutes ~/ 60,
    genreFrequency: genreFreq,
    monthlyActivity: _getLast12Months(monthlyAct),
    averageUserRating: countUserRating > 0
        ? sumUserRating / countUserRating
        : 0.0,
    averageCommunityRating: countCommunityRating > 0
        ? sumCommunityRating / countCommunityRating
        : 0.0,
    totalRatedItems: countUserRating,
  );
});

// Helper to ensure we pad 0s for missing months in the last year
Map<String, int> _getLast12Months(Map<String, int> data) {
  final result = <String, int>{};
  final formatter = DateFormat('yyyy-MM');
  final now = DateTime.now();

  for (int i = 11; i >= 0; i--) {
    final d = DateTime(now.year, now.month - i, 1);
    final key = formatter.format(d);
    result[key] = data[key] ?? 0;
  }

  return result;
}
