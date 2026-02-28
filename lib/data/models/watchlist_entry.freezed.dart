// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watchlist_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WatchlistEntry _$WatchlistEntryFromJson(Map<String, dynamic> json) {
  return _WatchlistEntry.fromJson(json);
}

/// @nodoc
mixin _$WatchlistEntry {
  int get mediaId =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(unknownEnumValue: MediaType.movie)
  MediaType get mediaType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get posterPath => throw _privateConstructorUsedError;
  String? get backdropPath => throw _privateConstructorUsedError;
  DateTime get addedAt => throw _privateConstructorUsedError;
  double? get voteAverage =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(unknownEnumValue: WatchlistPriority.normal)
  WatchlistPriority get priority => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<int> get genreIds => throw _privateConstructorUsedError;

  /// Serializes this WatchlistEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WatchlistEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WatchlistEntryCopyWith<WatchlistEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchlistEntryCopyWith<$Res> {
  factory $WatchlistEntryCopyWith(
    WatchlistEntry value,
    $Res Function(WatchlistEntry) then,
  ) = _$WatchlistEntryCopyWithImpl<$Res, WatchlistEntry>;
  @useResult
  $Res call({
    int mediaId,
    @JsonKey(unknownEnumValue: MediaType.movie) MediaType mediaType,
    String title,
    String? posterPath,
    String? backdropPath,
    DateTime addedAt,
    double? voteAverage,
    @JsonKey(unknownEnumValue: WatchlistPriority.normal)
    WatchlistPriority priority,
    String? notes,
    List<int> genreIds,
  });
}

/// @nodoc
class _$WatchlistEntryCopyWithImpl<$Res, $Val extends WatchlistEntry>
    implements $WatchlistEntryCopyWith<$Res> {
  _$WatchlistEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WatchlistEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaId = null,
    Object? mediaType = null,
    Object? title = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? addedAt = null,
    Object? voteAverage = freezed,
    Object? priority = null,
    Object? notes = freezed,
    Object? genreIds = null,
  }) {
    return _then(
      _value.copyWith(
            mediaId: null == mediaId
                ? _value.mediaId
                : mediaId // ignore: cast_nullable_to_non_nullable
                      as int,
            mediaType: null == mediaType
                ? _value.mediaType
                : mediaType // ignore: cast_nullable_to_non_nullable
                      as MediaType,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            posterPath: freezed == posterPath
                ? _value.posterPath
                : posterPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            backdropPath: freezed == backdropPath
                ? _value.backdropPath
                : backdropPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            addedAt: null == addedAt
                ? _value.addedAt
                : addedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            voteAverage: freezed == voteAverage
                ? _value.voteAverage
                : voteAverage // ignore: cast_nullable_to_non_nullable
                      as double?,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as WatchlistPriority,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            genreIds: null == genreIds
                ? _value.genreIds
                : genreIds // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WatchlistEntryImplCopyWith<$Res>
    implements $WatchlistEntryCopyWith<$Res> {
  factory _$$WatchlistEntryImplCopyWith(
    _$WatchlistEntryImpl value,
    $Res Function(_$WatchlistEntryImpl) then,
  ) = __$$WatchlistEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int mediaId,
    @JsonKey(unknownEnumValue: MediaType.movie) MediaType mediaType,
    String title,
    String? posterPath,
    String? backdropPath,
    DateTime addedAt,
    double? voteAverage,
    @JsonKey(unknownEnumValue: WatchlistPriority.normal)
    WatchlistPriority priority,
    String? notes,
    List<int> genreIds,
  });
}

/// @nodoc
class __$$WatchlistEntryImplCopyWithImpl<$Res>
    extends _$WatchlistEntryCopyWithImpl<$Res, _$WatchlistEntryImpl>
    implements _$$WatchlistEntryImplCopyWith<$Res> {
  __$$WatchlistEntryImplCopyWithImpl(
    _$WatchlistEntryImpl _value,
    $Res Function(_$WatchlistEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WatchlistEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaId = null,
    Object? mediaType = null,
    Object? title = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? addedAt = null,
    Object? voteAverage = freezed,
    Object? priority = null,
    Object? notes = freezed,
    Object? genreIds = null,
  }) {
    return _then(
      _$WatchlistEntryImpl(
        mediaId: null == mediaId
            ? _value.mediaId
            : mediaId // ignore: cast_nullable_to_non_nullable
                  as int,
        mediaType: null == mediaType
            ? _value.mediaType
            : mediaType // ignore: cast_nullable_to_non_nullable
                  as MediaType,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        posterPath: freezed == posterPath
            ? _value.posterPath
            : posterPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        backdropPath: freezed == backdropPath
            ? _value.backdropPath
            : backdropPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        addedAt: null == addedAt
            ? _value.addedAt
            : addedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        voteAverage: freezed == voteAverage
            ? _value.voteAverage
            : voteAverage // ignore: cast_nullable_to_non_nullable
                  as double?,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as WatchlistPriority,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        genreIds: null == genreIds
            ? _value._genreIds
            : genreIds // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WatchlistEntryImpl extends _WatchlistEntry {
  const _$WatchlistEntryImpl({
    required this.mediaId,
    @JsonKey(unknownEnumValue: MediaType.movie) required this.mediaType,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.addedAt,
    this.voteAverage,
    @JsonKey(unknownEnumValue: WatchlistPriority.normal)
    this.priority = WatchlistPriority.normal,
    this.notes,
    final List<int> genreIds = const [],
  }) : _genreIds = genreIds,
       super._();

  factory _$WatchlistEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WatchlistEntryImplFromJson(json);

  @override
  final int mediaId;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(unknownEnumValue: MediaType.movie)
  final MediaType mediaType;
  @override
  final String title;
  @override
  final String? posterPath;
  @override
  final String? backdropPath;
  @override
  final DateTime addedAt;
  @override
  final double? voteAverage;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(unknownEnumValue: WatchlistPriority.normal)
  final WatchlistPriority priority;
  @override
  final String? notes;
  final List<int> _genreIds;
  @override
  @JsonKey()
  List<int> get genreIds {
    if (_genreIds is EqualUnmodifiableListView) return _genreIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genreIds);
  }

  @override
  String toString() {
    return 'WatchlistEntry(mediaId: $mediaId, mediaType: $mediaType, title: $title, posterPath: $posterPath, backdropPath: $backdropPath, addedAt: $addedAt, voteAverage: $voteAverage, priority: $priority, notes: $notes, genreIds: $genreIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchlistEntryImpl &&
            (identical(other.mediaId, mediaId) || other.mediaId == mediaId) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.posterPath, posterPath) ||
                other.posterPath == posterPath) &&
            (identical(other.backdropPath, backdropPath) ||
                other.backdropPath == backdropPath) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt) &&
            (identical(other.voteAverage, voteAverage) ||
                other.voteAverage == voteAverage) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._genreIds, _genreIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    mediaId,
    mediaType,
    title,
    posterPath,
    backdropPath,
    addedAt,
    voteAverage,
    priority,
    notes,
    const DeepCollectionEquality().hash(_genreIds),
  );

  /// Create a copy of WatchlistEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchlistEntryImplCopyWith<_$WatchlistEntryImpl> get copyWith =>
      __$$WatchlistEntryImplCopyWithImpl<_$WatchlistEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WatchlistEntryImplToJson(this);
  }
}

abstract class _WatchlistEntry extends WatchlistEntry {
  const factory _WatchlistEntry({
    required final int mediaId,
    @JsonKey(unknownEnumValue: MediaType.movie)
    required final MediaType mediaType,
    required final String title,
    final String? posterPath,
    final String? backdropPath,
    required final DateTime addedAt,
    final double? voteAverage,
    @JsonKey(unknownEnumValue: WatchlistPriority.normal)
    final WatchlistPriority priority,
    final String? notes,
    final List<int> genreIds,
  }) = _$WatchlistEntryImpl;
  const _WatchlistEntry._() : super._();

  factory _WatchlistEntry.fromJson(Map<String, dynamic> json) =
      _$WatchlistEntryImpl.fromJson;

  @override
  int get mediaId; // ignore: invalid_annotation_target
  @override
  @JsonKey(unknownEnumValue: MediaType.movie)
  MediaType get mediaType;
  @override
  String get title;
  @override
  String? get posterPath;
  @override
  String? get backdropPath;
  @override
  DateTime get addedAt;
  @override
  double? get voteAverage; // ignore: invalid_annotation_target
  @override
  @JsonKey(unknownEnumValue: WatchlistPriority.normal)
  WatchlistPriority get priority;
  @override
  String? get notes;
  @override
  List<int> get genreIds;

  /// Create a copy of WatchlistEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WatchlistEntryImplCopyWith<_$WatchlistEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
