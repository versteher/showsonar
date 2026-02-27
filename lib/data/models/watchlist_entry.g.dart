// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WatchlistEntryImpl _$$WatchlistEntryImplFromJson(Map<String, dynamic> json) =>
    _$WatchlistEntryImpl(
      mediaId: (json['mediaId'] as num).toInt(),
      mediaType: $enumDecode(
        _$MediaTypeEnumMap,
        json['mediaType'],
        unknownValue: MediaType.movie,
      ),
      title: json['title'] as String,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      voteAverage: (json['voteAverage'] as num?)?.toDouble(),
      priority:
          $enumDecodeNullable(
            _$WatchlistPriorityEnumMap,
            json['priority'],
            unknownValue: WatchlistPriority.normal,
          ) ??
          WatchlistPriority.normal,
      notes: json['notes'] as String?,
      genreIds:
          (json['genreIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$WatchlistEntryImplToJson(
  _$WatchlistEntryImpl instance,
) => <String, dynamic>{
  'mediaId': instance.mediaId,
  'mediaType': _$MediaTypeEnumMap[instance.mediaType]!,
  'title': instance.title,
  'posterPath': instance.posterPath,
  'backdropPath': instance.backdropPath,
  'addedAt': instance.addedAt.toIso8601String(),
  'voteAverage': instance.voteAverage,
  'priority': _$WatchlistPriorityEnumMap[instance.priority]!,
  'notes': instance.notes,
  'genreIds': instance.genreIds,
};

const _$MediaTypeEnumMap = {MediaType.movie: 'movie', MediaType.tv: 'tv'};

const _$WatchlistPriorityEnumMap = {
  WatchlistPriority.high: 'high',
  WatchlistPriority.normal: 'normal',
  WatchlistPriority.low: 'low',
};
