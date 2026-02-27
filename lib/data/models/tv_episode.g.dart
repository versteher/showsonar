// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TvEpisodeImpl _$$TvEpisodeImplFromJson(Map<String, dynamic> json) =>
    _$TvEpisodeImpl(
      episodeNumber: (json['episodeNumber'] as num).toInt(),
      seasonNumber: (json['seasonNumber'] as num).toInt(),
      name: json['name'] as String,
      overview: json['overview'] as String? ?? '',
      airDate: json['airDate'] == null
          ? null
          : DateTime.parse(json['airDate'] as String),
      runtime: (json['runtime'] as num?)?.toInt(),
      stillPath: json['stillPath'] as String?,
      voteAverage: (json['voteAverage'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TvEpisodeImplToJson(_$TvEpisodeImpl instance) =>
    <String, dynamic>{
      'episodeNumber': instance.episodeNumber,
      'seasonNumber': instance.seasonNumber,
      'name': instance.name,
      'overview': instance.overview,
      'airDate': instance.airDate?.toIso8601String(),
      'runtime': instance.runtime,
      'stillPath': instance.stillPath,
      'voteAverage': instance.voteAverage,
      'voteCount': instance.voteCount,
    };
