// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppProfileImpl _$$AppProfileImplFromJson(Map<String, dynamic> json) =>
    _$AppProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarEmoji: json['avatarEmoji'] as String? ?? '🎬',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AppProfileImplToJson(_$AppProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarEmoji': instance.avatarEmoji,
      'createdAt': instance.createdAt.toIso8601String(),
    };
