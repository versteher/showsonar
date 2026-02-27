// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppProfile _$AppProfileFromJson(Map<String, dynamic> json) {
  return _AppProfile.fromJson(json);
}

/// @nodoc
mixin _$AppProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get avatarEmoji => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AppProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppProfileCopyWith<AppProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppProfileCopyWith<$Res> {
  factory $AppProfileCopyWith(
    AppProfile value,
    $Res Function(AppProfile) then,
  ) = _$AppProfileCopyWithImpl<$Res, AppProfile>;
  @useResult
  $Res call({String id, String name, String avatarEmoji, DateTime createdAt});
}

/// @nodoc
class _$AppProfileCopyWithImpl<$Res, $Val extends AppProfile>
    implements $AppProfileCopyWith<$Res> {
  _$AppProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarEmoji = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarEmoji: null == avatarEmoji
                ? _value.avatarEmoji
                : avatarEmoji // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppProfileImplCopyWith<$Res>
    implements $AppProfileCopyWith<$Res> {
  factory _$$AppProfileImplCopyWith(
    _$AppProfileImpl value,
    $Res Function(_$AppProfileImpl) then,
  ) = __$$AppProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String avatarEmoji, DateTime createdAt});
}

/// @nodoc
class __$$AppProfileImplCopyWithImpl<$Res>
    extends _$AppProfileCopyWithImpl<$Res, _$AppProfileImpl>
    implements _$$AppProfileImplCopyWith<$Res> {
  __$$AppProfileImplCopyWithImpl(
    _$AppProfileImpl _value,
    $Res Function(_$AppProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarEmoji = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AppProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarEmoji: null == avatarEmoji
            ? _value.avatarEmoji
            : avatarEmoji // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppProfileImpl implements _AppProfile {
  const _$AppProfileImpl({
    required this.id,
    required this.name,
    this.avatarEmoji = '🎬',
    required this.createdAt,
  });

  factory _$AppProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String avatarEmoji;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AppProfile(id: $id, name: $name, avatarEmoji: $avatarEmoji, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarEmoji, avatarEmoji) ||
                other.avatarEmoji == avatarEmoji) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, avatarEmoji, createdAt);

  /// Create a copy of AppProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppProfileImplCopyWith<_$AppProfileImpl> get copyWith =>
      __$$AppProfileImplCopyWithImpl<_$AppProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppProfileImplToJson(this);
  }
}

abstract class _AppProfile implements AppProfile {
  const factory _AppProfile({
    required final String id,
    required final String name,
    final String avatarEmoji,
    required final DateTime createdAt,
  }) = _$AppProfileImpl;

  factory _AppProfile.fromJson(Map<String, dynamic> json) =
      _$AppProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get avatarEmoji;
  @override
  DateTime get createdAt;

  /// Create a copy of AppProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppProfileImplCopyWith<_$AppProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
