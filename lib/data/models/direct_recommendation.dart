import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/user_profile.dart';

part 'direct_recommendation.freezed.dart';
part 'direct_recommendation.g.dart';

@freezed
class DirectRecommendation with _$DirectRecommendation {
  const factory DirectRecommendation({
    required String id,
    required String senderId,
    required String receiverId,
    required int mediaId,
    required String mediaTitle,
    String? mediaPosterPath,
    required String mediaType,
    @TimestampConverter() required DateTime timestamp,
    UserProfile? senderProfile, // Populated client-side
  }) = _DirectRecommendation;

  factory DirectRecommendation.fromJson(Map<String, dynamic> json) =>
      _$DirectRecommendationFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}
