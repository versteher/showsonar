// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'direct_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DirectRecommendation _$DirectRecommendationFromJson(Map<String, dynamic> json) {
  return _DirectRecommendation.fromJson(json);
}

/// @nodoc
mixin _$DirectRecommendation {
  String get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get receiverId => throw _privateConstructorUsedError;
  int get mediaId => throw _privateConstructorUsedError;
  String get mediaTitle => throw _privateConstructorUsedError;
  String? get mediaPosterPath => throw _privateConstructorUsedError;
  String get mediaType => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get timestamp => throw _privateConstructorUsedError;
  UserProfile? get senderProfile => throw _privateConstructorUsedError;

  /// Serializes this DirectRecommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DirectRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DirectRecommendationCopyWith<DirectRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DirectRecommendationCopyWith<$Res> {
  factory $DirectRecommendationCopyWith(
    DirectRecommendation value,
    $Res Function(DirectRecommendation) then,
  ) = _$DirectRecommendationCopyWithImpl<$Res, DirectRecommendation>;
  @useResult
  $Res call({
    String id,
    String senderId,
    String receiverId,
    int mediaId,
    String mediaTitle,
    String? mediaPosterPath,
    String mediaType,
    @TimestampConverter() DateTime timestamp,
    UserProfile? senderProfile,
  });

  $UserProfileCopyWith<$Res>? get senderProfile;
}

/// @nodoc
class _$DirectRecommendationCopyWithImpl<
  $Res,
  $Val extends DirectRecommendation
>
    implements $DirectRecommendationCopyWith<$Res> {
  _$DirectRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DirectRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? mediaId = null,
    Object? mediaTitle = null,
    Object? mediaPosterPath = freezed,
    Object? mediaType = null,
    Object? timestamp = null,
    Object? senderProfile = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            receiverId: null == receiverId
                ? _value.receiverId
                : receiverId // ignore: cast_nullable_to_non_nullable
                      as String,
            mediaId: null == mediaId
                ? _value.mediaId
                : mediaId // ignore: cast_nullable_to_non_nullable
                      as int,
            mediaTitle: null == mediaTitle
                ? _value.mediaTitle
                : mediaTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            mediaPosterPath: freezed == mediaPosterPath
                ? _value.mediaPosterPath
                : mediaPosterPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            mediaType: null == mediaType
                ? _value.mediaType
                : mediaType // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            senderProfile: freezed == senderProfile
                ? _value.senderProfile
                : senderProfile // ignore: cast_nullable_to_non_nullable
                      as UserProfile?,
          )
          as $Val,
    );
  }

  /// Create a copy of DirectRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<$Res>? get senderProfile {
    if (_value.senderProfile == null) {
      return null;
    }

    return $UserProfileCopyWith<$Res>(_value.senderProfile!, (value) {
      return _then(_value.copyWith(senderProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DirectRecommendationImplCopyWith<$Res>
    implements $DirectRecommendationCopyWith<$Res> {
  factory _$$DirectRecommendationImplCopyWith(
    _$DirectRecommendationImpl value,
    $Res Function(_$DirectRecommendationImpl) then,
  ) = __$$DirectRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String senderId,
    String receiverId,
    int mediaId,
    String mediaTitle,
    String? mediaPosterPath,
    String mediaType,
    @TimestampConverter() DateTime timestamp,
    UserProfile? senderProfile,
  });

  @override
  $UserProfileCopyWith<$Res>? get senderProfile;
}

/// @nodoc
class __$$DirectRecommendationImplCopyWithImpl<$Res>
    extends _$DirectRecommendationCopyWithImpl<$Res, _$DirectRecommendationImpl>
    implements _$$DirectRecommendationImplCopyWith<$Res> {
  __$$DirectRecommendationImplCopyWithImpl(
    _$DirectRecommendationImpl _value,
    $Res Function(_$DirectRecommendationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DirectRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? mediaId = null,
    Object? mediaTitle = null,
    Object? mediaPosterPath = freezed,
    Object? mediaType = null,
    Object? timestamp = null,
    Object? senderProfile = freezed,
  }) {
    return _then(
      _$DirectRecommendationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        receiverId: null == receiverId
            ? _value.receiverId
            : receiverId // ignore: cast_nullable_to_non_nullable
                  as String,
        mediaId: null == mediaId
            ? _value.mediaId
            : mediaId // ignore: cast_nullable_to_non_nullable
                  as int,
        mediaTitle: null == mediaTitle
            ? _value.mediaTitle
            : mediaTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        mediaPosterPath: freezed == mediaPosterPath
            ? _value.mediaPosterPath
            : mediaPosterPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        mediaType: null == mediaType
            ? _value.mediaType
            : mediaType // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        senderProfile: freezed == senderProfile
            ? _value.senderProfile
            : senderProfile // ignore: cast_nullable_to_non_nullable
                  as UserProfile?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DirectRecommendationImpl implements _DirectRecommendation {
  const _$DirectRecommendationImpl({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.mediaId,
    required this.mediaTitle,
    this.mediaPosterPath,
    required this.mediaType,
    @TimestampConverter() required this.timestamp,
    this.senderProfile,
  });

  factory _$DirectRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$DirectRecommendationImplFromJson(json);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String receiverId;
  @override
  final int mediaId;
  @override
  final String mediaTitle;
  @override
  final String? mediaPosterPath;
  @override
  final String mediaType;
  @override
  @TimestampConverter()
  final DateTime timestamp;
  @override
  final UserProfile? senderProfile;

  @override
  String toString() {
    return 'DirectRecommendation(id: $id, senderId: $senderId, receiverId: $receiverId, mediaId: $mediaId, mediaTitle: $mediaTitle, mediaPosterPath: $mediaPosterPath, mediaType: $mediaType, timestamp: $timestamp, senderProfile: $senderProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DirectRecommendationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.mediaId, mediaId) || other.mediaId == mediaId) &&
            (identical(other.mediaTitle, mediaTitle) ||
                other.mediaTitle == mediaTitle) &&
            (identical(other.mediaPosterPath, mediaPosterPath) ||
                other.mediaPosterPath == mediaPosterPath) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.senderProfile, senderProfile) ||
                other.senderProfile == senderProfile));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    senderId,
    receiverId,
    mediaId,
    mediaTitle,
    mediaPosterPath,
    mediaType,
    timestamp,
    senderProfile,
  );

  /// Create a copy of DirectRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DirectRecommendationImplCopyWith<_$DirectRecommendationImpl>
  get copyWith =>
      __$$DirectRecommendationImplCopyWithImpl<_$DirectRecommendationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DirectRecommendationImplToJson(this);
  }
}

abstract class _DirectRecommendation implements DirectRecommendation {
  const factory _DirectRecommendation({
    required final String id,
    required final String senderId,
    required final String receiverId,
    required final int mediaId,
    required final String mediaTitle,
    final String? mediaPosterPath,
    required final String mediaType,
    @TimestampConverter() required final DateTime timestamp,
    final UserProfile? senderProfile,
  }) = _$DirectRecommendationImpl;

  factory _DirectRecommendation.fromJson(Map<String, dynamic> json) =
      _$DirectRecommendationImpl.fromJson;

  @override
  String get id;
  @override
  String get senderId;
  @override
  String get receiverId;
  @override
  int get mediaId;
  @override
  String get mediaTitle;
  @override
  String? get mediaPosterPath;
  @override
  String get mediaType;
  @override
  @TimestampConverter()
  DateTime get timestamp;
  @override
  UserProfile? get senderProfile;

  /// Create a copy of DirectRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DirectRecommendationImplCopyWith<_$DirectRecommendationImpl>
  get copyWith => throw _privateConstructorUsedError;
}
