// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_season.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TvSeasonImpl _$$TvSeasonImplFromJson(Map<String, dynamic> json) =>
    _$TvSeasonImpl(
      tvId: (json['tvId'] as num).toInt(),
      seasonNumber: (json['seasonNumber'] as num).toInt(),
      name: json['name'] as String,
      episodes:
          (json['episodes'] as List<dynamic>?)
              ?.map((e) => TvEpisode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      airDate: json['airDate'] == null
          ? null
          : DateTime.parse(json['airDate'] as String),
      posterPath: json['posterPath'] as String?,
      overview: json['overview'] as String? ?? '',
    );

Map<String, dynamic> _$$TvSeasonImplToJson(_$TvSeasonImpl instance) =>
    <String, dynamic>{
      'tvId': instance.tvId,
      'seasonNumber': instance.seasonNumber,
      'name': instance.name,
      'episodes': instance.episodes,
      'airDate': instance.airDate?.toIso8601String(),
      'posterPath': instance.posterPath,
      'overview': instance.overview,
    };
