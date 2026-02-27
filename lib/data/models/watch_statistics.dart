import 'package:freezed_annotation/freezed_annotation.dart';

part 'watch_statistics.freezed.dart';

@freezed
class WatchStatistics with _$WatchStatistics {
  const factory WatchStatistics({
    required int totalMoviesWatched,
    required int totalSeriesWatched,
    required int totalHoursSpent,
    required Map<int, int> genreFrequency,
    required Map<String, int> monthlyActivity,
    required double averageUserRating,
    required double averageCommunityRating,
    required int totalRatedItems,
  }) = _WatchStatistics;
}
