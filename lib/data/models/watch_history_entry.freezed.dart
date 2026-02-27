// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watch_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WatchHistoryEntry _$WatchHistoryEntryFromJson(Map<String, dynamic> json) {
  return _WatchHistoryEntry.fromJson(json);
}

/// @nodoc
mixin _$WatchHistoryEntry {
  int get mediaId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MediaType.movie)
  MediaType get mediaType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get posterPath => throw _privateConstructorUsedError;
  String? get backdropPath => throw _privateConstructorUsedError;
  DateTime get watchedAt => throw _privateConstructorUsedError;
  double? get userRating => throw _privateConstructorUsedError; // 1-10 scale
  double? get voteAverage =>
      throw _privateConstructorUsedError; // IMDB/TMDB rating at time of watching
  String? get notes => throw _privateConstructorUsedError; // Personal notes
  bool get completed => throw _privateConstructorUsedError;
  int? get currentEpisode => throw _privateConstructorUsedError;
  int? get currentSeason => throw _privateConstructorUsedError;
  int get rewatchCount => throw _privateConstructorUsedError;
  int? get runtime => throw _privateConstructorUsedError; // in minutes
  List<int> get genreIds => throw _privateConstructorUsedError;

  /// Serializes this WatchHistoryEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WatchHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WatchHistoryEntryCopyWith<WatchHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchHistoryEntryCopyWith<$Res> {
  factory $WatchHistoryEntryCopyWith(
    WatchHistoryEntry value,
    $Res Function(WatchHistoryEntry) then,
  ) = _$WatchHistoryEntryCopyWithImpl<$Res, WatchHistoryEntry>;
  @useResult
  $Res call({
    int mediaId,
    @JsonKey(unknownEnumValue: MediaType.movie) MediaType mediaType,
    String title,
    String? posterPath,
    String? backdropPath,
    DateTime watchedAt,
    double? userRating,
    double? voteAverage,
    String? notes,
    bool completed,
    int? currentEpisode,
    int? currentSeason,
    int rewatchCount,
    int? runtime,
    List<int> genreIds,
  });
}

/// @nodoc
class _$WatchHistoryEntryCopyWithImpl<$Res, $Val extends WatchHistoryEntry>
    implements $WatchHistoryEntryCopyWith<$Res> {
  _$WatchHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WatchHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaId = null,
    Object? mediaType = null,
    Object? title = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? watchedAt = null,
    Object? userRating = freezed,
    Object? voteAverage = freezed,
    Object? notes = freezed,
    Object? completed = null,
    Object? currentEpisode = freezed,
    Object? currentSeason = freezed,
    Object? rewatchCount = null,
    Object? runtime = freezed,
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
            watchedAt: null == watchedAt
                ? _value.watchedAt
                : watchedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userRating: freezed == userRating
                ? _value.userRating
                : userRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            voteAverage: freezed == voteAverage
                ? _value.voteAverage
                : voteAverage // ignore: cast_nullable_to_non_nullable
                      as double?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentEpisode: freezed == currentEpisode
                ? _value.currentEpisode
                : currentEpisode // ignore: cast_nullable_to_non_nullable
                      as int?,
            currentSeason: freezed == currentSeason
                ? _value.currentSeason
                : currentSeason // ignore: cast_nullable_to_non_nullable
                      as int?,
            rewatchCount: null == rewatchCount
                ? _value.rewatchCount
                : rewatchCount // ignore: cast_nullable_to_non_nullable
                      as int,
            runtime: freezed == runtime
                ? _value.runtime
                : runtime // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$WatchHistoryEntryImplCopyWith<$Res>
    implements $WatchHistoryEntryCopyWith<$Res> {
  factory _$$WatchHistoryEntryImplCopyWith(
    _$WatchHistoryEntryImpl value,
    $Res Function(_$WatchHistoryEntryImpl) then,
  ) = __$$WatchHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int mediaId,
    @JsonKey(unknownEnumValue: MediaType.movie) MediaType mediaType,
    String title,
    String? posterPath,
    String? backdropPath,
    DateTime watchedAt,
    double? userRating,
    double? voteAverage,
    String? notes,
    bool completed,
    int? currentEpisode,
    int? currentSeason,
    int rewatchCount,
    int? runtime,
    List<int> genreIds,
  });
}

/// @nodoc
class __$$WatchHistoryEntryImplCopyWithImpl<$Res>
    extends _$WatchHistoryEntryCopyWithImpl<$Res, _$WatchHistoryEntryImpl>
    implements _$$WatchHistoryEntryImplCopyWith<$Res> {
  __$$WatchHistoryEntryImplCopyWithImpl(
    _$WatchHistoryEntryImpl _value,
    $Res Function(_$WatchHistoryEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WatchHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaId = null,
    Object? mediaType = null,
    Object? title = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? watchedAt = null,
    Object? userRating = freezed,
    Object? voteAverage = freezed,
    Object? notes = freezed,
    Object? completed = null,
    Object? currentEpisode = freezed,
    Object? currentSeason = freezed,
    Object? rewatchCount = null,
    Object? runtime = freezed,
    Object? genreIds = null,
  }) {
    return _then(
      _$WatchHistoryEntryImpl(
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
        watchedAt: null == watchedAt
            ? _value.watchedAt
            : watchedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userRating: freezed == userRating
            ? _value.userRating
            : userRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        voteAverage: freezed == voteAverage
            ? _value.voteAverage
            : voteAverage // ignore: cast_nullable_to_non_nullable
                  as double?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentEpisode: freezed == currentEpisode
            ? _value.currentEpisode
            : currentEpisode // ignore: cast_nullable_to_non_nullable
                  as int?,
        currentSeason: freezed == currentSeason
            ? _value.currentSeason
            : currentSeason // ignore: cast_nullable_to_non_nullable
                  as int?,
        rewatchCount: null == rewatchCount
            ? _value.rewatchCount
            : rewatchCount // ignore: cast_nullable_to_non_nullable
                  as int,
        runtime: freezed == runtime
            ? _value.runtime
            : runtime // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$WatchHistoryEntryImpl extends _WatchHistoryEntry {
  const _$WatchHistoryEntryImpl({
    required this.mediaId,
    @JsonKey(unknownEnumValue: MediaType.movie) required this.mediaType,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.watchedAt,
    this.userRating,
    this.voteAverage,
    this.notes,
    this.completed = false,
    this.currentEpisode,
    this.currentSeason,
    this.rewatchCount = 0,
    this.runtime,
    final List<int> genreIds = const [],
  }) : _genreIds = genreIds,
       super._();

  factory _$WatchHistoryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WatchHistoryEntryImplFromJson(json);

  @override
  final int mediaId;
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
  final DateTime watchedAt;
  @override
  final double? userRating;
  // 1-10 scale
  @override
  final double? voteAverage;
  // IMDB/TMDB rating at time of watching
  @override
  final String? notes;
  // Personal notes
  @override
  @JsonKey()
  final bool completed;
  @override
  final int? currentEpisode;
  @override
  final int? currentSeason;
  @override
  @JsonKey()
  final int rewatchCount;
  @override
  final int? runtime;
  // in minutes
  final List<int> _genreIds;
  // in minutes
  @override
  @JsonKey()
  List<int> get genreIds {
    if (_genreIds is EqualUnmodifiableListView) return _genreIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genreIds);
  }

  @override
  String toString() {
    return 'WatchHistoryEntry(mediaId: $mediaId, mediaType: $mediaType, title: $title, posterPath: $posterPath, backdropPath: $backdropPath, watchedAt: $watchedAt, userRating: $userRating, voteAverage: $voteAverage, notes: $notes, completed: $completed, currentEpisode: $currentEpisode, currentSeason: $currentSeason, rewatchCount: $rewatchCount, runtime: $runtime, genreIds: $genreIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchHistoryEntryImpl &&
            (identical(other.mediaId, mediaId) || other.mediaId == mediaId) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.posterPath, posterPath) ||
                other.posterPath == posterPath) &&
            (identical(other.backdropPath, backdropPath) ||
                other.backdropPath == backdropPath) &&
            (identical(other.watchedAt, watchedAt) ||
                other.watchedAt == watchedAt) &&
            (identical(other.userRating, userRating) ||
                other.userRating == userRating) &&
            (identical(other.voteAverage, voteAverage) ||
                other.voteAverage == voteAverage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.currentEpisode, currentEpisode) ||
                other.currentEpisode == currentEpisode) &&
            (identical(other.currentSeason, currentSeason) ||
                other.currentSeason == currentSeason) &&
            (identical(other.rewatchCount, rewatchCount) ||
                other.rewatchCount == rewatchCount) &&
            (identical(other.runtime, runtime) || other.runtime == runtime) &&
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
    watchedAt,
    userRating,
    voteAverage,
    notes,
    completed,
    currentEpisode,
    currentSeason,
    rewatchCount,
    runtime,
    const DeepCollectionEquality().hash(_genreIds),
  );

  /// Create a copy of WatchHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchHistoryEntryImplCopyWith<_$WatchHistoryEntryImpl> get copyWith =>
      __$$WatchHistoryEntryImplCopyWithImpl<_$WatchHistoryEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WatchHistoryEntryImplToJson(this);
  }
}

abstract class _WatchHistoryEntry extends WatchHistoryEntry {
  const factory _WatchHistoryEntry({
    required final int mediaId,
    @JsonKey(unknownEnumValue: MediaType.movie)
    required final MediaType mediaType,
    required final String title,
    final String? posterPath,
    final String? backdropPath,
    required final DateTime watchedAt,
    final double? userRating,
    final double? voteAverage,
    final String? notes,
    final bool completed,
    final int? currentEpisode,
    final int? currentSeason,
    final int rewatchCount,
    final int? runtime,
    final List<int> genreIds,
  }) = _$WatchHistoryEntryImpl;
  const _WatchHistoryEntry._() : super._();

  factory _WatchHistoryEntry.fromJson(Map<String, dynamic> json) =
      _$WatchHistoryEntryImpl.fromJson;

  @override
  int get mediaId;
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
  DateTime get watchedAt;
  @override
  double? get userRating; // 1-10 scale
  @override
  double? get voteAverage; // IMDB/TMDB rating at time of watching
  @override
  String? get notes; // Personal notes
  @override
  bool get completed;
  @override
  int? get currentEpisode;
  @override
  int? get currentSeason;
  @override
  int get rewatchCount;
  @override
  int? get runtime; // in minutes
  @override
  List<int> get genreIds;

  /// Create a copy of WatchHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WatchHistoryEntryImplCopyWith<_$WatchHistoryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
