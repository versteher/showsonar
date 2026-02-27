// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_feed_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActivityFeedItem _$ActivityFeedItemFromJson(Map<String, dynamic> json) {
  return _ActivityFeedItem.fromJson(json);
}

/// @nodoc
mixin _$ActivityFeedItem {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userDisplayName => throw _privateConstructorUsedError;
  String? get userPhotoUrl => throw _privateConstructorUsedError;
  String get actionType =>
      throw _privateConstructorUsedError; // 'rated', 'watched', 'added_to_watchlist'
  String get mediaId => throw _privateConstructorUsedError;
  String get mediaTitle => throw _privateConstructorUsedError;
  String? get mediaPosterPath => throw _privateConstructorUsedError;
  String get mediaType => throw _privateConstructorUsedError; // 'movie' or 'tv'
  double? get rating => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this ActivityFeedItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityFeedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityFeedItemCopyWith<ActivityFeedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityFeedItemCopyWith<$Res> {
  factory $ActivityFeedItemCopyWith(
    ActivityFeedItem value,
    $Res Function(ActivityFeedItem) then,
  ) = _$ActivityFeedItemCopyWithImpl<$Res, ActivityFeedItem>;
  @useResult
  $Res call({
    String id,
    String userId,
    String userDisplayName,
    String? userPhotoUrl,
    String actionType,
    String mediaId,
    String mediaTitle,
    String? mediaPosterPath,
    String mediaType,
    double? rating,
    DateTime timestamp,
  });
}

/// @nodoc
class _$ActivityFeedItemCopyWithImpl<$Res, $Val extends ActivityFeedItem>
    implements $ActivityFeedItemCopyWith<$Res> {
  _$ActivityFeedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityFeedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userDisplayName = null,
    Object? userPhotoUrl = freezed,
    Object? actionType = null,
    Object? mediaId = null,
    Object? mediaTitle = null,
    Object? mediaPosterPath = freezed,
    Object? mediaType = null,
    Object? rating = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userDisplayName: null == userDisplayName
                ? _value.userDisplayName
                : userDisplayName // ignore: cast_nullable_to_non_nullable
                      as String,
            userPhotoUrl: freezed == userPhotoUrl
                ? _value.userPhotoUrl
                : userPhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            actionType: null == actionType
                ? _value.actionType
                : actionType // ignore: cast_nullable_to_non_nullable
                      as String,
            mediaId: null == mediaId
                ? _value.mediaId
                : mediaId // ignore: cast_nullable_to_non_nullable
                      as String,
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
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivityFeedItemImplCopyWith<$Res>
    implements $ActivityFeedItemCopyWith<$Res> {
  factory _$$ActivityFeedItemImplCopyWith(
    _$ActivityFeedItemImpl value,
    $Res Function(_$ActivityFeedItemImpl) then,
  ) = __$$ActivityFeedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String userDisplayName,
    String? userPhotoUrl,
    String actionType,
    String mediaId,
    String mediaTitle,
    String? mediaPosterPath,
    String mediaType,
    double? rating,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$ActivityFeedItemImplCopyWithImpl<$Res>
    extends _$ActivityFeedItemCopyWithImpl<$Res, _$ActivityFeedItemImpl>
    implements _$$ActivityFeedItemImplCopyWith<$Res> {
  __$$ActivityFeedItemImplCopyWithImpl(
    _$ActivityFeedItemImpl _value,
    $Res Function(_$ActivityFeedItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivityFeedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userDisplayName = null,
    Object? userPhotoUrl = freezed,
    Object? actionType = null,
    Object? mediaId = null,
    Object? mediaTitle = null,
    Object? mediaPosterPath = freezed,
    Object? mediaType = null,
    Object? rating = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$ActivityFeedItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userDisplayName: null == userDisplayName
            ? _value.userDisplayName
            : userDisplayName // ignore: cast_nullable_to_non_nullable
                  as String,
        userPhotoUrl: freezed == userPhotoUrl
            ? _value.userPhotoUrl
            : userPhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        actionType: null == actionType
            ? _value.actionType
            : actionType // ignore: cast_nullable_to_non_nullable
                  as String,
        mediaId: null == mediaId
            ? _value.mediaId
            : mediaId // ignore: cast_nullable_to_non_nullable
                  as String,
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
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityFeedItemImpl implements _ActivityFeedItem {
  const _$ActivityFeedItemImpl({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.actionType,
    required this.mediaId,
    required this.mediaTitle,
    this.mediaPosterPath,
    required this.mediaType,
    this.rating,
    required this.timestamp,
  });

  factory _$ActivityFeedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityFeedItemImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String userDisplayName;
  @override
  final String? userPhotoUrl;
  @override
  final String actionType;
  // 'rated', 'watched', 'added_to_watchlist'
  @override
  final String mediaId;
  @override
  final String mediaTitle;
  @override
  final String? mediaPosterPath;
  @override
  final String mediaType;
  // 'movie' or 'tv'
  @override
  final double? rating;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'ActivityFeedItem(id: $id, userId: $userId, userDisplayName: $userDisplayName, userPhotoUrl: $userPhotoUrl, actionType: $actionType, mediaId: $mediaId, mediaTitle: $mediaTitle, mediaPosterPath: $mediaPosterPath, mediaType: $mediaType, rating: $rating, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityFeedItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userDisplayName, userDisplayName) ||
                other.userDisplayName == userDisplayName) &&
            (identical(other.userPhotoUrl, userPhotoUrl) ||
                other.userPhotoUrl == userPhotoUrl) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.mediaId, mediaId) || other.mediaId == mediaId) &&
            (identical(other.mediaTitle, mediaTitle) ||
                other.mediaTitle == mediaTitle) &&
            (identical(other.mediaPosterPath, mediaPosterPath) ||
                other.mediaPosterPath == mediaPosterPath) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    userDisplayName,
    userPhotoUrl,
    actionType,
    mediaId,
    mediaTitle,
    mediaPosterPath,
    mediaType,
    rating,
    timestamp,
  );

  /// Create a copy of ActivityFeedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityFeedItemImplCopyWith<_$ActivityFeedItemImpl> get copyWith =>
      __$$ActivityFeedItemImplCopyWithImpl<_$ActivityFeedItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityFeedItemImplToJson(this);
  }
}

abstract class _ActivityFeedItem implements ActivityFeedItem {
  const factory _ActivityFeedItem({
    required final String id,
    required final String userId,
    required final String userDisplayName,
    final String? userPhotoUrl,
    required final String actionType,
    required final String mediaId,
    required final String mediaTitle,
    final String? mediaPosterPath,
    required final String mediaType,
    final double? rating,
    required final DateTime timestamp,
  }) = _$ActivityFeedItemImpl;

  factory _ActivityFeedItem.fromJson(Map<String, dynamic> json) =
      _$ActivityFeedItemImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get userDisplayName;
  @override
  String? get userPhotoUrl;
  @override
  String get actionType; // 'rated', 'watched', 'added_to_watchlist'
  @override
  String get mediaId;
  @override
  String get mediaTitle;
  @override
  String? get mediaPosterPath;
  @override
  String get mediaType; // 'movie' or 'tv'
  @override
  double? get rating;
  @override
  DateTime get timestamp;

  /// Create a copy of ActivityFeedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityFeedItemImplCopyWith<_$ActivityFeedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
