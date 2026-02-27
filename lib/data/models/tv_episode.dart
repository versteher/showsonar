import 'package:freezed_annotation/freezed_annotation.dart';

part 'tv_episode.freezed.dart';
part 'tv_episode.g.dart';

/// Represents a single TV episode from TMDB
@freezed
class TvEpisode with _$TvEpisode {
  const TvEpisode._();

  const factory TvEpisode({
    required int episodeNumber,
    required int seasonNumber,
    required String name,
    @Default('') String overview,
    DateTime? airDate,
    int? runtime, // in minutes
    String? stillPath,
    @Default(0.0) double voteAverage,
    @Default(0) int voteCount,
  }) = _TvEpisode;

  /// Whether this episode has already aired
  bool get hasAired {
    if (airDate == null) return false;
    return airDate!.isBefore(DateTime.now());
  }

  /// Days until this episode airs (negative if already aired)
  int get daysUntilAir {
    if (airDate == null) return -999;
    return airDate!.difference(DateTime.now()).inDays;
  }

  String get fullStillPath =>
      stillPath != null ? 'https://image.tmdb.org/t/p/w300$stillPath' : '';

  factory TvEpisode.fromTmdbJson(Map<String, dynamic> json) {
    return TvEpisode(
      episodeNumber: json['episode_number'] as int? ?? 0,
      seasonNumber: json['season_number'] as int? ?? 0,
      name: json['name'] as String? ?? 'Episode ${json['episode_number']}',
      overview: json['overview'] as String? ?? '',
      airDate: _parseDate(json['air_date']),
      runtime: json['runtime'] as int?,
      stillPath: json['still_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
    );
  }

  factory TvEpisode.fromJson(Map<String, dynamic> json) =>
      _$TvEpisodeFromJson(json);

  static DateTime? _parseDate(dynamic date) {
    if (date == null || date == '') return null;
    try {
      return DateTime.parse(date as String);
    } catch (_) {
      return null;
    }
  }
}
