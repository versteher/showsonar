// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$UserPreferencesImpl(
  countryCode: json['countryCode'] as String,
  countryName: json['countryName'] as String,
  subscribedServiceIds: (json['subscribedServiceIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  favoriteGenreIds:
      (json['favoriteGenreIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  minimumRating: (json['minimumRating'] as num?)?.toDouble() ?? 6.0,
  maxAgeRating: (json['maxAgeRating'] as num?)?.toInt() ?? 18,
  includeAdult: json['includeAdult'] as bool? ?? false,
  themeMode: json['themeMode'] as String? ?? 'system',
  showExtendedRatings: json['showExtendedRatings'] as bool? ?? false,
);

Map<String, dynamic> _$$UserPreferencesImplToJson(
  _$UserPreferencesImpl instance,
) => <String, dynamic>{
  'countryCode': instance.countryCode,
  'countryName': instance.countryName,
  'subscribedServiceIds': instance.subscribedServiceIds,
  'favoriteGenreIds': instance.favoriteGenreIds,
  'minimumRating': instance.minimumRating,
  'maxAgeRating': instance.maxAgeRating,
  'includeAdult': instance.includeAdult,
  'themeMode': instance.themeMode,
  'showExtendedRatings': instance.showExtendedRatings,
};
