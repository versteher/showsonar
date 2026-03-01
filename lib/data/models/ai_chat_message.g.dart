// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiChatMessageImpl _$$AiChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$AiChatMessageImpl(
      id: json['id'] as String,
      role: $enumDecode(_$AiChatRoleEnumMap, json['role']),
      content: json['content'] as String,
      recommendedMediaIds:
          (json['recommendedMediaIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$AiChatMessageImplToJson(_$AiChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$AiChatRoleEnumMap[instance.role]!,
      'content': instance.content,
      'recommendedMediaIds': instance.recommendedMediaIds,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$AiChatRoleEnumMap = {AiChatRole.user: 'user', AiChatRole.ai: 'ai'};
