// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_feed_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityFeedItemImpl _$$ActivityFeedItemImplFromJson(
  Map<String, dynamic> json,
) => _$ActivityFeedItemImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userDisplayName: json['userDisplayName'] as String,
  userPhotoUrl: json['userPhotoUrl'] as String?,
  actionType: json['actionType'] as String,
  mediaId: json['mediaId'] as String,
  mediaTitle: json['mediaTitle'] as String,
  mediaPosterPath: json['mediaPosterPath'] as String?,
  mediaType: json['mediaType'] as String,
  rating: (json['rating'] as num?)?.toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$ActivityFeedItemImplToJson(
  _$ActivityFeedItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userDisplayName': instance.userDisplayName,
  'userPhotoUrl': instance.userPhotoUrl,
  'actionType': instance.actionType,
  'mediaId': instance.mediaId,
  'mediaTitle': instance.mediaTitle,
  'mediaPosterPath': instance.mediaPosterPath,
  'mediaType': instance.mediaType,
  'rating': instance.rating,
  'timestamp': instance.timestamp.toIso8601String(),
};
