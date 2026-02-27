// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WatchHistoryEntryImpl _$$WatchHistoryEntryImplFromJson(
  Map<String, dynamic> json,
) => _$WatchHistoryEntryImpl(
  mediaId: (json['mediaId'] as num).toInt(),
  mediaType: $enumDecode(
    _$MediaTypeEnumMap,
    json['mediaType'],
    unknownValue: MediaType.movie,
  ),
  title: json['title'] as String,
  posterPath: json['posterPath'] as String?,
  backdropPath: json['backdropPath'] as String?,
  watchedAt: DateTime.parse(json['watchedAt'] as String),
  userRating: (json['userRating'] as num?)?.toDouble(),
  voteAverage: (json['voteAverage'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  completed: json['completed'] as bool? ?? false,
  currentEpisode: (json['currentEpisode'] as num?)?.toInt(),
  currentSeason: (json['currentSeason'] as num?)?.toInt(),
  rewatchCount: (json['rewatchCount'] as num?)?.toInt() ?? 0,
  runtime: (json['runtime'] as num?)?.toInt(),
  genreIds:
      (json['genreIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
);

Map<String, dynamic> _$$WatchHistoryEntryImplToJson(
  _$WatchHistoryEntryImpl instance,
) => <String, dynamic>{
  'mediaId': instance.mediaId,
  'mediaType': _$MediaTypeEnumMap[instance.mediaType]!,
  'title': instance.title,
  'posterPath': instance.posterPath,
  'backdropPath': instance.backdropPath,
  'watchedAt': instance.watchedAt.toIso8601String(),
  'userRating': instance.userRating,
  'voteAverage': instance.voteAverage,
  'notes': instance.notes,
  'completed': instance.completed,
  'currentEpisode': instance.currentEpisode,
  'currentSeason': instance.currentSeason,
  'rewatchCount': instance.rewatchCount,
  'runtime': instance.runtime,
  'genreIds': instance.genreIds,
};

const _$MediaTypeEnumMap = {MediaType.movie: 'movie', MediaType.tv: 'tv'};
