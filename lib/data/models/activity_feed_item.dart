import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_feed_item.freezed.dart';
part 'activity_feed_item.g.dart';

@freezed
class ActivityFeedItem with _$ActivityFeedItem {
  const factory ActivityFeedItem({
    required String id,
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required String actionType, // 'rated', 'watched', 'added_to_watchlist'
    required String mediaId,
    required String mediaTitle,
    String? mediaPosterPath,
    required String mediaType, // 'movie' or 'tv'
    double? rating,
    required DateTime timestamp,
  }) = _ActivityFeedItem;

  factory ActivityFeedItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityFeedItemFromJson(json);
}
