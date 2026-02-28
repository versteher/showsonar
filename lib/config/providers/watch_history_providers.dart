import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/media.dart';
import '../../data/models/watch_history_entry.dart';
import '../../data/models/genre.dart';
import '../providers.dart';

part 'watch_history_providers.g.dart';

// ============================================================================
// Watch History Providers
// ============================================================================

/// Provider for all watch history entries (reactive)
@riverpod
Future<List<WatchHistoryEntry>> watchHistoryEntries(Ref ref) async {
  final repo = ref.watch(watchHistoryRepositoryProvider);
  await repo.init();
  return repo.getAllEntries();
}

/// Provider for a set of watched media IDs (for fast lookup)
/// Returns a Set of "type_id" strings, e.g. {"movie_123", "tv_456"}
@riverpod
Future<Set<String>> watchedMediaIds(Ref ref) async {
  final entries = await ref.watch(watchHistoryEntriesProvider.future);
  return entries.map((e) => e.uniqueKey).toSet();
}

/// Provider to check if a specific media is watched
@riverpod
Future<bool> isWatched(
  Ref ref, {
  required int id,
  required MediaType type,
}) async {
  final repo = ref.watch(watchHistoryRepositoryProvider);
  await repo.init();
  return repo.hasWatched(id, type);
}

/// Provider to get a specific watch history entry
@riverpod
Future<WatchHistoryEntry?> watchHistoryEntry(
  Ref ref, {
  required int id,
  required MediaType type,
}) async {
  final repo = ref.watch(watchHistoryRepositoryProvider);
  await repo.init();
  return repo.getEntry(id, type);
}

/// Provider for watch history statistics
@riverpod
Future<WatchHistoryStats> watchHistoryStats(Ref ref) async {
  final entries = await ref.watch(watchHistoryEntriesProvider.future);
  return WatchHistoryStats.fromEntries(entries);
}

/// Statistics computed from watch history
class WatchHistoryStats {
  final int totalCount;
  final int movieCount;
  final int seriesCount;
  final int ratedCount;
  final double averageRating;
  final Map<int, int> genreFrequency;

  const WatchHistoryStats({
    required this.totalCount,
    required this.movieCount,
    required this.seriesCount,
    required this.ratedCount,
    required this.averageRating,
    required this.genreFrequency,
  });

  factory WatchHistoryStats.fromEntries(List<WatchHistoryEntry> entries) {
    final movies = entries.where((e) => e.mediaType == MediaType.movie).length;
    final series = entries.where((e) => e.mediaType == MediaType.tv).length;
    final rated = entries.where((e) => e.isRated).toList();
    final avgRating = rated.isNotEmpty
        ? rated.map((e) => e.userRating!).reduce((a, b) => a + b) / rated.length
        : 0.0;

    // Calculate genre frequency
    final genreFreq = <int, int>{};
    for (final entry in entries) {
      for (final genreId in entry.genreIds) {
        genreFreq[genreId] = (genreFreq[genreId] ?? 0) + 1;
      }
    }

    return WatchHistoryStats(
      totalCount: entries.length,
      movieCount: movies,
      seriesCount: series,
      ratedCount: rated.length,
      averageRating: avgRating,
      genreFrequency: genreFreq,
    );
  }

  List<int> get topGenres {
    final sorted = genreFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
  }
}

// ============================================================================
// Weekly Recap Provider
// ============================================================================

/// Weekly recap statistics
class WeeklyRecap {
  final int watchedThisWeek;
  final double estimatedHours;
  final double averageRating;
  final String? topGenreName;
  final int streakDays;

  const WeeklyRecap({
    required this.watchedThisWeek,
    required this.estimatedHours,
    required this.averageRating,
    this.topGenreName,
    required this.streakDays,
  });

  factory WeeklyRecap.fromEntries(List<WatchHistoryEntry> allEntries) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final thisWeek = allEntries
        .where((e) => e.watchedAt.isAfter(weekAgo))
        .toList();

    // Estimated hours (assume ~2h per movie, ~0.75h per episode)
    double hours = 0;
    for (final e in thisWeek) {
      hours += e.mediaType == MediaType.movie ? 2.0 : 0.75;
    }

    // Average rating this week
    final rated = thisWeek.where((e) => e.isRated).toList();
    final avgRating = rated.isNotEmpty
        ? rated.map((e) => e.userRating!).reduce((a, b) => a + b) / rated.length
        : 0.0;

    // Top genre this week
    final genreFreq = <int, int>{};
    for (final e in thisWeek) {
      for (final g in e.genreIds) {
        genreFreq[g] = (genreFreq[g] ?? 0) + 1;
      }
    }
    String? topGenre;
    if (genreFreq.isNotEmpty) {
      final topId = genreFreq.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      topGenre = Genre.getNameById(topId);
    }

    // Streak: consecutive days with at least one watch (counting back from today)
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final hasWatch = allEntries.any(
        (e) => e.watchedAt.isAfter(dayStart) && e.watchedAt.isBefore(dayEnd),
      );
      if (hasWatch) {
        streak++;
      } else {
        break;
      }
    }

    return WeeklyRecap(
      watchedThisWeek: thisWeek.length,
      estimatedHours: hours,
      averageRating: avgRating,
      topGenreName: topGenre,
      streakDays: streak,
    );
  }
}

@riverpod
Future<WeeklyRecap> weeklyRecap(Ref ref) async {
  final entries = await ref.watch(watchHistoryEntriesProvider.future);
  return WeeklyRecap.fromEntries(entries);
}

// ============================================================================
// Continue Watching Provider
// ============================================================================

/// In-progress TV series (completed == false)
@riverpod
Future<List<WatchHistoryEntry>> continueWatching(Ref ref) async {
  final entries = await ref.watch(watchHistoryEntriesProvider.future);
  return entries
      .where((e) => e.mediaType == MediaType.tv && !e.completed)
      .toList();
}
