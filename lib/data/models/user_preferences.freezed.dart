// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  String get countryCode => throw _privateConstructorUsedError;
  String get countryName => throw _privateConstructorUsedError;
  List<String> get subscribedServiceIds => throw _privateConstructorUsedError;
  List<int> get favoriteGenreIds => throw _privateConstructorUsedError;
  double get minimumRating => throw _privateConstructorUsedError;
  int get maxAgeRating =>
      throw _privateConstructorUsedError; // FSK Limit (e.g. 12)
  bool get includeAdult => throw _privateConstructorUsedError;
  String get themeMode =>
      throw _privateConstructorUsedError; // 'system', 'light', 'dark'
  bool get showExtendedRatings => throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
    UserPreferences value,
    $Res Function(UserPreferences) then,
  ) = _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call({
    String countryCode,
    String countryName,
    List<String> subscribedServiceIds,
    List<int> favoriteGenreIds,
    double minimumRating,
    int maxAgeRating,
    bool includeAdult,
    String themeMode,
    bool showExtendedRatings,
  });
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? countryCode = null,
    Object? countryName = null,
    Object? subscribedServiceIds = null,
    Object? favoriteGenreIds = null,
    Object? minimumRating = null,
    Object? maxAgeRating = null,
    Object? includeAdult = null,
    Object? themeMode = null,
    Object? showExtendedRatings = null,
  }) {
    return _then(
      _value.copyWith(
            countryCode: null == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String,
            countryName: null == countryName
                ? _value.countryName
                : countryName // ignore: cast_nullable_to_non_nullable
                      as String,
            subscribedServiceIds: null == subscribedServiceIds
                ? _value.subscribedServiceIds
                : subscribedServiceIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            favoriteGenreIds: null == favoriteGenreIds
                ? _value.favoriteGenreIds
                : favoriteGenreIds // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            minimumRating: null == minimumRating
                ? _value.minimumRating
                : minimumRating // ignore: cast_nullable_to_non_nullable
                      as double,
            maxAgeRating: null == maxAgeRating
                ? _value.maxAgeRating
                : maxAgeRating // ignore: cast_nullable_to_non_nullable
                      as int,
            includeAdult: null == includeAdult
                ? _value.includeAdult
                : includeAdult // ignore: cast_nullable_to_non_nullable
                      as bool,
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as String,
            showExtendedRatings: null == showExtendedRatings
                ? _value.showExtendedRatings
                : showExtendedRatings // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(
    _$UserPreferencesImpl value,
    $Res Function(_$UserPreferencesImpl) then,
  ) = __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String countryCode,
    String countryName,
    List<String> subscribedServiceIds,
    List<int> favoriteGenreIds,
    double minimumRating,
    int maxAgeRating,
    bool includeAdult,
    String themeMode,
    bool showExtendedRatings,
  });
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
    _$UserPreferencesImpl _value,
    $Res Function(_$UserPreferencesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? countryCode = null,
    Object? countryName = null,
    Object? subscribedServiceIds = null,
    Object? favoriteGenreIds = null,
    Object? minimumRating = null,
    Object? maxAgeRating = null,
    Object? includeAdult = null,
    Object? themeMode = null,
    Object? showExtendedRatings = null,
  }) {
    return _then(
      _$UserPreferencesImpl(
        countryCode: null == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String,
        countryName: null == countryName
            ? _value.countryName
            : countryName // ignore: cast_nullable_to_non_nullable
                  as String,
        subscribedServiceIds: null == subscribedServiceIds
            ? _value._subscribedServiceIds
            : subscribedServiceIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        favoriteGenreIds: null == favoriteGenreIds
            ? _value._favoriteGenreIds
            : favoriteGenreIds // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        minimumRating: null == minimumRating
            ? _value.minimumRating
            : minimumRating // ignore: cast_nullable_to_non_nullable
                  as double,
        maxAgeRating: null == maxAgeRating
            ? _value.maxAgeRating
            : maxAgeRating // ignore: cast_nullable_to_non_nullable
                  as int,
        includeAdult: null == includeAdult
            ? _value.includeAdult
            : includeAdult // ignore: cast_nullable_to_non_nullable
                  as bool,
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as String,
        showExtendedRatings: null == showExtendedRatings
            ? _value.showExtendedRatings
            : showExtendedRatings // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl extends _UserPreferences {
  const _$UserPreferencesImpl({
    required this.countryCode,
    required this.countryName,
    required final List<String> subscribedServiceIds,
    final List<int> favoriteGenreIds = const [],
    this.minimumRating = 6.0,
    this.maxAgeRating = 18,
    this.includeAdult = false,
    this.themeMode = 'system',
    this.showExtendedRatings = false,
  }) : _subscribedServiceIds = subscribedServiceIds,
       _favoriteGenreIds = favoriteGenreIds,
       super._();

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  final String countryCode;
  @override
  final String countryName;
  final List<String> _subscribedServiceIds;
  @override
  List<String> get subscribedServiceIds {
    if (_subscribedServiceIds is EqualUnmodifiableListView)
      return _subscribedServiceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subscribedServiceIds);
  }

  final List<int> _favoriteGenreIds;
  @override
  @JsonKey()
  List<int> get favoriteGenreIds {
    if (_favoriteGenreIds is EqualUnmodifiableListView)
      return _favoriteGenreIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteGenreIds);
  }

  @override
  @JsonKey()
  final double minimumRating;
  @override
  @JsonKey()
  final int maxAgeRating;
  // FSK Limit (e.g. 12)
  @override
  @JsonKey()
  final bool includeAdult;
  @override
  @JsonKey()
  final String themeMode;
  // 'system', 'light', 'dark'
  @override
  @JsonKey()
  final bool showExtendedRatings;

  @override
  String toString() {
    return 'UserPreferences(countryCode: $countryCode, countryName: $countryName, subscribedServiceIds: $subscribedServiceIds, favoriteGenreIds: $favoriteGenreIds, minimumRating: $minimumRating, maxAgeRating: $maxAgeRating, includeAdult: $includeAdult, themeMode: $themeMode, showExtendedRatings: $showExtendedRatings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.countryName, countryName) ||
                other.countryName == countryName) &&
            const DeepCollectionEquality().equals(
              other._subscribedServiceIds,
              _subscribedServiceIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._favoriteGenreIds,
              _favoriteGenreIds,
            ) &&
            (identical(other.minimumRating, minimumRating) ||
                other.minimumRating == minimumRating) &&
            (identical(other.maxAgeRating, maxAgeRating) ||
                other.maxAgeRating == maxAgeRating) &&
            (identical(other.includeAdult, includeAdult) ||
                other.includeAdult == includeAdult) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.showExtendedRatings, showExtendedRatings) ||
                other.showExtendedRatings == showExtendedRatings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    countryCode,
    countryName,
    const DeepCollectionEquality().hash(_subscribedServiceIds),
    const DeepCollectionEquality().hash(_favoriteGenreIds),
    minimumRating,
    maxAgeRating,
    includeAdult,
    themeMode,
    showExtendedRatings,
  );

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(this);
  }
}

abstract class _UserPreferences extends UserPreferences {
  const factory _UserPreferences({
    required final String countryCode,
    required final String countryName,
    required final List<String> subscribedServiceIds,
    final List<int> favoriteGenreIds,
    final double minimumRating,
    final int maxAgeRating,
    final bool includeAdult,
    final String themeMode,
    final bool showExtendedRatings,
  }) = _$UserPreferencesImpl;
  const _UserPreferences._() : super._();

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  String get countryCode;
  @override
  String get countryName;
  @override
  List<String> get subscribedServiceIds;
  @override
  List<int> get favoriteGenreIds;
  @override
  double get minimumRating;
  @override
  int get maxAgeRating; // FSK Limit (e.g. 12)
  @override
  bool get includeAdult;
  @override
  String get themeMode; // 'system', 'light', 'dark'
  @override
  bool get showExtendedRatings;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
