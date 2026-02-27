// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_watchlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SharedWatchlistImpl _$$SharedWatchlistImplFromJson(
  Map<String, dynamic> json,
) => _$SharedWatchlistImpl(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  sharedWithUids:
      (json['sharedWithUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  mediaIds:
      (json['mediaIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$SharedWatchlistImplToJson(
  _$SharedWatchlistImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'name': instance.name,
  'sharedWithUids': instance.sharedWithUids,
  'mediaIds': instance.mediaIds,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
