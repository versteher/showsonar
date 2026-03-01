import 'package:freezed_annotation/freezed_annotation.dart';
import 'streaming_provider.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

/// User preferences including country, subscribed services, and genre preferences
@freezed
class UserPreferences with _$UserPreferences {
  const UserPreferences._();

  const factory UserPreferences({
    required String countryCode,
    required String countryName,
    required List<String> subscribedServiceIds,
    @Default([]) List<int> favoriteGenreIds,
    @Default(6.0) double minimumRating,
    @Default(18) int maxAgeRating, // FSK Limit (e.g. 12)
    @Default(false) bool includeAdult,
    @Default('system') String themeMode, // 'system', 'light', 'dark'
    @Default(false) bool showExtendedRatings,
  }) = _UserPreferences;

  /// Default preferences for Germany
  factory UserPreferences.defaultDE() {
    return UserPreferences(
      countryCode: 'DE',
      countryName: 'Deutschland',
      subscribedServiceIds: StreamingProvider.getDefaultServiceIds('DE'),
      maxAgeRating: 18,
      includeAdult: false,
    );
  }

  List<StreamingProvider> get subscribedServices {
    return subscribedServiceIds
        .map((id) => StreamingProvider.fromId(id))
        .whereType<StreamingProvider>()
        .toList();
  }

  /// TMDB provider IDs for the user's subscribed services.
  /// Eliminates the 5-line extraction pattern repeated across providers.
  List<int> get tmdbProviderIds => subscribedServices
      .where((p) => p.tmdbId != null)
      .map((p) => p.tmdbId!)
      .toList();

  bool isSubscribedTo(StreamingProvider provider) {
    return subscribedServiceIds.contains(provider.id);
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
