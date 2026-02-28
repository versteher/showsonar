import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import 'media.dart';

part 'watchlist_entry.freezed.dart';
part 'watchlist_entry.g.dart';

/// Priority levels for watchlist items
enum WatchlistPriority {
  high,
  normal,
  low;

  /// Fallback English display name (no BuildContext needed).
  String get displayName {
    switch (this) {
      case WatchlistPriority.high:
        return 'High';
      case WatchlistPriority.normal:
        return 'Normal';
      case WatchlistPriority.low:
        return 'Low';
    }
  }

  /// Localized name — call from within a widget with `AppLocalizations.of(context)!`.
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case WatchlistPriority.high:
        return l10n.priorityHigh;
      case WatchlistPriority.normal:
        return l10n.priorityNormal;
      case WatchlistPriority.low:
        return l10n.priorityLow;
    }
  }
}

/// Represents a media item saved to the user's watchlist (want-to-watch)
@freezed
class WatchlistEntry with _$WatchlistEntry {
  const WatchlistEntry._();

  const factory WatchlistEntry({
    required int mediaId,
    // ignore: invalid_annotation_target
    @JsonKey(unknownEnumValue: MediaType.movie) required MediaType mediaType,
    required String title,
    String? posterPath,
    String? backdropPath,
    required DateTime addedAt,
    double? voteAverage,
    // ignore: invalid_annotation_target
    @JsonKey(unknownEnumValue: WatchlistPriority.normal)
    @Default(WatchlistPriority.normal)
    WatchlistPriority priority,
    String? notes,
    @Default([]) List<int> genreIds,
  }) = _WatchlistEntry;

  String get uniqueKey => '${mediaType.name}_$mediaId';

  String get fullPosterPath =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  /// Human-readable time since added — English fallback (no context needed).
  String get addedAgo => addedAgoLocalized(null);

  /// Fully localized time since added.
  String addedAgoLocalized(AppLocalizations? l10n) {
    final diff = DateTime.now().difference(addedAt);
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

  factory WatchlistEntry.fromJson(Map<String, dynamic> json) =>
      _$WatchlistEntryFromJson(json);

  factory WatchlistEntry.fromMedia(Media media) {
    return WatchlistEntry(
      mediaId: media.id,
      mediaType: media.type,
      title: media.title,
      posterPath: media.posterPath,
      backdropPath: media.backdropPath,
      addedAt: DateTime.now(),
      voteAverage: media.voteAverage,
      genreIds: media.genreIds,
    );
  }
}
