import 'package:freezed_annotation/freezed_annotation.dart';
import 'tv_episode.dart';

part 'tv_season.freezed.dart';
part 'tv_season.g.dart';

/// Represents a TV season with its list of episodes
@freezed
class TvSeason with _$TvSeason {
  const TvSeason._();

  const factory TvSeason({
    required int tvId,
    required int seasonNumber,
    required String name,
    @Default([]) List<TvEpisode> episodes,
    DateTime? airDate,
    String? posterPath,
    @Default('') String overview,
  }) = _TvSeason;

  int get episodeCount => episodes.length;

  int get airedEpisodeCount => episodes.where((e) => e.hasAired).length;

  String get fullPosterPath =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w300$posterPath' : '';

  /// The next episode that hasn't aired yet
  TvEpisode? get nextUnaired {
    final future =
        episodes.where((e) => !e.hasAired && e.airDate != null).toList()
          ..sort((a, b) => a.airDate!.compareTo(b.airDate!));
    return future.isEmpty ? null : future.first;
  }

  factory TvSeason.fromTmdbJson(int tvId, Map<String, dynamic> json) {
    final episodesData = json['episodes'] as List<dynamic>? ?? [];
    final episodes = episodesData
        .map((e) => TvEpisode.fromTmdbJson(e as Map<String, dynamic>))
        .toList();

    return TvSeason(
      tvId: tvId,
      seasonNumber: json['season_number'] as int? ?? 0,
      name: json['name'] as String? ?? 'Season ${json['season_number']}',
      episodes: episodes,
      airDate: _parseDate(json['air_date']),
      posterPath: json['poster_path'] as String?,
      overview: json['overview'] as String? ?? '',
    );
  }

  factory TvSeason.fromJson(Map<String, dynamic> json) =>
      _$TvSeasonFromJson(json);

  static DateTime? _parseDate(dynamic date) {
    if (date == null || date == '') return null;
    try {
      return DateTime.parse(date as String);
    } catch (_) {
      return null;
    }
  }
}
