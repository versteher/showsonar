// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DirectRecommendationImpl _$$DirectRecommendationImplFromJson(
  Map<String, dynamic> json,
) => _$DirectRecommendationImpl(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  receiverId: json['receiverId'] as String,
  mediaId: (json['mediaId'] as num).toInt(),
  mediaTitle: json['mediaTitle'] as String,
  mediaPosterPath: json['mediaPosterPath'] as String?,
  mediaType: json['mediaType'] as String,
  timestamp: const TimestampConverter().fromJson(json['timestamp'] as Object),
  senderProfile: json['senderProfile'] == null
      ? null
      : UserProfile.fromJson(json['senderProfile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$DirectRecommendationImplToJson(
  _$DirectRecommendationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'senderId': instance.senderId,
  'receiverId': instance.receiverId,
  'mediaId': instance.mediaId,
  'mediaTitle': instance.mediaTitle,
  'mediaPosterPath': instance.mediaPosterPath,
  'mediaType': instance.mediaType,
  'timestamp': const TimestampConverter().toJson(instance.timestamp),
  'senderProfile': instance.senderProfile,
};
