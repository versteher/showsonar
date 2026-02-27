import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_profile.freezed.dart';
part 'app_profile.g.dart';

/// A sub-profile within a family account (separate from the social UserProfile).
/// Each profile has isolated watchlist, watch history and preferences.
@freezed
class AppProfile with _$AppProfile {
  const factory AppProfile({
    required String id,
    required String name,
    @Default('🎬') String avatarEmoji,
    required DateTime createdAt,
  }) = _AppProfile;

  factory AppProfile.fromJson(Map<String, dynamic> json) =>
      _$AppProfileFromJson(json);
}
