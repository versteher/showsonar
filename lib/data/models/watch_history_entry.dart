import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import 'media.dart';

part 'watch_history_entry.freezed.dart';
part 'watch_history_entry.g.dart';

/// Represents a watched media item in the user's history
@freezed
class WatchHistoryEntry with _$WatchHistoryEntry {
  const WatchHistoryEntry._();

  const factory WatchHistoryEntry({
    required int mediaId,
    @JsonKey(unknownEnumValue: MediaType.movie) required MediaType mediaType,
    required String title,
    String? posterPath,
    String? backdropPath,
    required DateTime watchedAt,
    double? userRating, // 1-10 scale
    double? voteAverage, // IMDB/TMDB rating at time of watching
    String? notes, // Personal notes
    @Default(false) bool completed,
    int? currentEpisode,
    int? currentSeason,
    @Default(0) int rewatchCount,
    int? runtime, // in minutes
    @Default([]) List<int> genreIds,
  }) = _WatchHistoryEntry;

  String get uniqueKey => '${mediaType.name}_$mediaId';

  bool get isRated => userRating != null;

  /// Human-readable time since watched — English fallback (no context needed).
  String get watchedAgo => watchedAgoLocalized(null);

  /// Fully localized time since watched. Pass [l10n] from the nearest
  /// [AppLocalizations.of(context)] call in your widget tree.
  String watchedAgoLocalized(AppLocalizations? l10n) {
    final diff = DateTime.now().difference(watchedAt);
    if (diff.inDays > 365) {
      final years = (diff.inDays / 365).floor();
      return l10n?.timeAgoYears(years) ??
          '$years year${years == 1 ? '' : 's'} ago';
    } else if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return l10n?.timeAgoMonths(months) ??
          '$months month${months == 1 ? '' : 's'} ago';
    } else if (diff.inDays > 0) {
      final days = diff.inDays;
      return l10n?.timeAgoDays(days) ?? '$days day${days == 1 ? '' : 's'} ago';
    } else if (diff.inHours > 0) {
      final hours = diff.inHours;
      return l10n?.timeAgoHours(hours) ??
          '$hours hour${hours == 1 ? '' : 's'} ago';
    } else {
      return l10n?.timeAgoJustNow ?? 'just now';
    }
  }

  /// Create a copy with cleared rating (for re-rating)
  WatchHistoryEntry withClearedRating() {
    return copyWith(userRating: null);
  }

  factory WatchHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$WatchHistoryEntryFromJson(json);

  factory WatchHistoryEntry.fromMedia(
    Media media, {
    double? rating,
    String? notes,
  }) {
    return WatchHistoryEntry(
      mediaId: media.id,
      mediaType: media.type,
      title: media.title,
      posterPath: media.posterPath,
      backdropPath: media.backdropPath,
      watchedAt: DateTime.now(),
      userRating: rating,
      voteAverage: media.voteAverage,
      notes: notes,
      completed: false,
      runtime: media.runtime,
      genreIds: media.genreIds,
    );
  }
}
