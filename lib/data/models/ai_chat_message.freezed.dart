// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AiChatMessage _$AiChatMessageFromJson(Map<String, dynamic> json) {
  return _AiChatMessage.fromJson(json);
}

/// @nodoc
mixin _$AiChatMessage {
  String get id => throw _privateConstructorUsedError;
  AiChatRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<int> get recommendedMediaIds => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this AiChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiChatMessageCopyWith<AiChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiChatMessageCopyWith<$Res> {
  factory $AiChatMessageCopyWith(
    AiChatMessage value,
    $Res Function(AiChatMessage) then,
  ) = _$AiChatMessageCopyWithImpl<$Res, AiChatMessage>;
  @useResult
  $Res call({
    String id,
    AiChatRole role,
    String content,
    List<int> recommendedMediaIds,
    DateTime timestamp,
  });
}

/// @nodoc
class _$AiChatMessageCopyWithImpl<$Res, $Val extends AiChatMessage>
    implements $AiChatMessageCopyWith<$Res> {
  _$AiChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? recommendedMediaIds = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as AiChatRole,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            recommendedMediaIds: null == recommendedMediaIds
                ? _value.recommendedMediaIds
                : recommendedMediaIds // ignore: cast_nullable_to_non_nullable
                      as List<int>,
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
abstract class _$$AiChatMessageImplCopyWith<$Res>
    implements $AiChatMessageCopyWith<$Res> {
  factory _$$AiChatMessageImplCopyWith(
    _$AiChatMessageImpl value,
    $Res Function(_$AiChatMessageImpl) then,
  ) = __$$AiChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    AiChatRole role,
    String content,
    List<int> recommendedMediaIds,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$AiChatMessageImplCopyWithImpl<$Res>
    extends _$AiChatMessageCopyWithImpl<$Res, _$AiChatMessageImpl>
    implements _$$AiChatMessageImplCopyWith<$Res> {
  __$$AiChatMessageImplCopyWithImpl(
    _$AiChatMessageImpl _value,
    $Res Function(_$AiChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? recommendedMediaIds = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$AiChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as AiChatRole,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        recommendedMediaIds: null == recommendedMediaIds
            ? _value._recommendedMediaIds
            : recommendedMediaIds // ignore: cast_nullable_to_non_nullable
                  as List<int>,
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
class _$AiChatMessageImpl implements _AiChatMessage {
  const _$AiChatMessageImpl({
    required this.id,
    required this.role,
    required this.content,
    final List<int> recommendedMediaIds = const [],
    required this.timestamp,
  }) : _recommendedMediaIds = recommendedMediaIds;

  factory _$AiChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final AiChatRole role;
  @override
  final String content;
  final List<int> _recommendedMediaIds;
  @override
  @JsonKey()
  List<int> get recommendedMediaIds {
    if (_recommendedMediaIds is EqualUnmodifiableListView)
      return _recommendedMediaIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedMediaIds);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'AiChatMessage(id: $id, role: $role, content: $content, recommendedMediaIds: $recommendedMediaIds, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(
              other._recommendedMediaIds,
              _recommendedMediaIds,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    role,
    content,
    const DeepCollectionEquality().hash(_recommendedMediaIds),
    timestamp,
  );

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiChatMessageImplCopyWith<_$AiChatMessageImpl> get copyWith =>
      __$$AiChatMessageImplCopyWithImpl<_$AiChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiChatMessageImplToJson(this);
  }
}

abstract class _AiChatMessage implements AiChatMessage {
  const factory _AiChatMessage({
    required final String id,
    required final AiChatRole role,
    required final String content,
    final List<int> recommendedMediaIds,
    required final DateTime timestamp,
  }) = _$AiChatMessageImpl;

  factory _AiChatMessage.fromJson(Map<String, dynamic> json) =
      _$AiChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  AiChatRole get role;
  @override
  String get content;
  @override
  List<int> get recommendedMediaIds;
  @override
  DateTime get timestamp;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiChatMessageImplCopyWith<_$AiChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
