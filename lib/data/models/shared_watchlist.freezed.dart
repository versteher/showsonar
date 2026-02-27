// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_watchlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SharedWatchlist _$SharedWatchlistFromJson(Map<String, dynamic> json) {
  return _SharedWatchlist.fromJson(json);
}

/// @nodoc
mixin _$SharedWatchlist {
  String get id => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get sharedWithUids => throw _privateConstructorUsedError;
  List<String> get mediaIds => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SharedWatchlist to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SharedWatchlist
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SharedWatchlistCopyWith<SharedWatchlist> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharedWatchlistCopyWith<$Res> {
  factory $SharedWatchlistCopyWith(
    SharedWatchlist value,
    $Res Function(SharedWatchlist) then,
  ) = _$SharedWatchlistCopyWithImpl<$Res, SharedWatchlist>;
  @useResult
  $Res call({
    String id,
    String ownerId,
    String name,
    List<String> sharedWithUids,
    List<String> mediaIds,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SharedWatchlistCopyWithImpl<$Res, $Val extends SharedWatchlist>
    implements $SharedWatchlistCopyWith<$Res> {
  _$SharedWatchlistCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SharedWatchlist
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? sharedWithUids = null,
    Object? mediaIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sharedWithUids: null == sharedWithUids
                ? _value.sharedWithUids
                : sharedWithUids // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            mediaIds: null == mediaIds
                ? _value.mediaIds
                : mediaIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SharedWatchlistImplCopyWith<$Res>
    implements $SharedWatchlistCopyWith<$Res> {
  factory _$$SharedWatchlistImplCopyWith(
    _$SharedWatchlistImpl value,
    $Res Function(_$SharedWatchlistImpl) then,
  ) = __$$SharedWatchlistImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ownerId,
    String name,
    List<String> sharedWithUids,
    List<String> mediaIds,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SharedWatchlistImplCopyWithImpl<$Res>
    extends _$SharedWatchlistCopyWithImpl<$Res, _$SharedWatchlistImpl>
    implements _$$SharedWatchlistImplCopyWith<$Res> {
  __$$SharedWatchlistImplCopyWithImpl(
    _$SharedWatchlistImpl _value,
    $Res Function(_$SharedWatchlistImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SharedWatchlist
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? sharedWithUids = null,
    Object? mediaIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SharedWatchlistImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sharedWithUids: null == sharedWithUids
            ? _value._sharedWithUids
            : sharedWithUids // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        mediaIds: null == mediaIds
            ? _value._mediaIds
            : mediaIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SharedWatchlistImpl implements _SharedWatchlist {
  const _$SharedWatchlistImpl({
    required this.id,
    required this.ownerId,
    required this.name,
    final List<String> sharedWithUids = const [],
    final List<String> mediaIds = const [],
    required this.createdAt,
    required this.updatedAt,
  }) : _sharedWithUids = sharedWithUids,
       _mediaIds = mediaIds;

  factory _$SharedWatchlistImpl.fromJson(Map<String, dynamic> json) =>
      _$$SharedWatchlistImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String name;
  final List<String> _sharedWithUids;
  @override
  @JsonKey()
  List<String> get sharedWithUids {
    if (_sharedWithUids is EqualUnmodifiableListView) return _sharedWithUids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sharedWithUids);
  }

  final List<String> _mediaIds;
  @override
  @JsonKey()
  List<String> get mediaIds {
    if (_mediaIds is EqualUnmodifiableListView) return _mediaIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaIds);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SharedWatchlist(id: $id, ownerId: $ownerId, name: $name, sharedWithUids: $sharedWithUids, mediaIds: $mediaIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharedWatchlistImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._sharedWithUids,
              _sharedWithUids,
            ) &&
            const DeepCollectionEquality().equals(other._mediaIds, _mediaIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ownerId,
    name,
    const DeepCollectionEquality().hash(_sharedWithUids),
    const DeepCollectionEquality().hash(_mediaIds),
    createdAt,
    updatedAt,
  );

  /// Create a copy of SharedWatchlist
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SharedWatchlistImplCopyWith<_$SharedWatchlistImpl> get copyWith =>
      __$$SharedWatchlistImplCopyWithImpl<_$SharedWatchlistImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SharedWatchlistImplToJson(this);
  }
}

abstract class _SharedWatchlist implements SharedWatchlist {
  const factory _SharedWatchlist({
    required final String id,
    required final String ownerId,
    required final String name,
    final List<String> sharedWithUids,
    final List<String> mediaIds,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SharedWatchlistImpl;

  factory _SharedWatchlist.fromJson(Map<String, dynamic> json) =
      _$SharedWatchlistImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerId;
  @override
  String get name;
  @override
  List<String> get sharedWithUids;
  @override
  List<String> get mediaIds;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SharedWatchlist
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SharedWatchlistImplCopyWith<_$SharedWatchlistImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
