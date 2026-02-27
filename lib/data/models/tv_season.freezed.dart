// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tv_season.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TvSeason _$TvSeasonFromJson(Map<String, dynamic> json) {
  return _TvSeason.fromJson(json);
}

/// @nodoc
mixin _$TvSeason {
  int get tvId => throw _privateConstructorUsedError;
  int get seasonNumber => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<TvEpisode> get episodes => throw _privateConstructorUsedError;
  DateTime? get airDate => throw _privateConstructorUsedError;
  String? get posterPath => throw _privateConstructorUsedError;
  String get overview => throw _privateConstructorUsedError;

  /// Serializes this TvSeason to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TvSeason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TvSeasonCopyWith<TvSeason> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TvSeasonCopyWith<$Res> {
  factory $TvSeasonCopyWith(TvSeason value, $Res Function(TvSeason) then) =
      _$TvSeasonCopyWithImpl<$Res, TvSeason>;
  @useResult
  $Res call({
    int tvId,
    int seasonNumber,
    String name,
    List<TvEpisode> episodes,
    DateTime? airDate,
    String? posterPath,
    String overview,
  });
}

/// @nodoc
class _$TvSeasonCopyWithImpl<$Res, $Val extends TvSeason>
    implements $TvSeasonCopyWith<$Res> {
  _$TvSeasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TvSeason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tvId = null,
    Object? seasonNumber = null,
    Object? name = null,
    Object? episodes = null,
    Object? airDate = freezed,
    Object? posterPath = freezed,
    Object? overview = null,
  }) {
    return _then(
      _value.copyWith(
            tvId: null == tvId
                ? _value.tvId
                : tvId // ignore: cast_nullable_to_non_nullable
                      as int,
            seasonNumber: null == seasonNumber
                ? _value.seasonNumber
                : seasonNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            episodes: null == episodes
                ? _value.episodes
                : episodes // ignore: cast_nullable_to_non_nullable
                      as List<TvEpisode>,
            airDate: freezed == airDate
                ? _value.airDate
                : airDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            posterPath: freezed == posterPath
                ? _value.posterPath
                : posterPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            overview: null == overview
                ? _value.overview
                : overview // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TvSeasonImplCopyWith<$Res>
    implements $TvSeasonCopyWith<$Res> {
  factory _$$TvSeasonImplCopyWith(
    _$TvSeasonImpl value,
    $Res Function(_$TvSeasonImpl) then,
  ) = __$$TvSeasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int tvId,
    int seasonNumber,
    String name,
    List<TvEpisode> episodes,
    DateTime? airDate,
    String? posterPath,
    String overview,
  });
}

/// @nodoc
class __$$TvSeasonImplCopyWithImpl<$Res>
    extends _$TvSeasonCopyWithImpl<$Res, _$TvSeasonImpl>
    implements _$$TvSeasonImplCopyWith<$Res> {
  __$$TvSeasonImplCopyWithImpl(
    _$TvSeasonImpl _value,
    $Res Function(_$TvSeasonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TvSeason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tvId = null,
    Object? seasonNumber = null,
    Object? name = null,
    Object? episodes = null,
    Object? airDate = freezed,
    Object? posterPath = freezed,
    Object? overview = null,
  }) {
    return _then(
      _$TvSeasonImpl(
        tvId: null == tvId
            ? _value.tvId
            : tvId // ignore: cast_nullable_to_non_nullable
                  as int,
        seasonNumber: null == seasonNumber
            ? _value.seasonNumber
            : seasonNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        episodes: null == episodes
            ? _value._episodes
            : episodes // ignore: cast_nullable_to_non_nullable
                  as List<TvEpisode>,
        airDate: freezed == airDate
            ? _value.airDate
            : airDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        posterPath: freezed == posterPath
            ? _value.posterPath
            : posterPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        overview: null == overview
            ? _value.overview
            : overview // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TvSeasonImpl extends _TvSeason {
  const _$TvSeasonImpl({
    required this.tvId,
    required this.seasonNumber,
    required this.name,
    final List<TvEpisode> episodes = const [],
    this.airDate,
    this.posterPath,
    this.overview = '',
  }) : _episodes = episodes,
       super._();

  factory _$TvSeasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$TvSeasonImplFromJson(json);

  @override
  final int tvId;
  @override
  final int seasonNumber;
  @override
  final String name;
  final List<TvEpisode> _episodes;
  @override
  @JsonKey()
  List<TvEpisode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  @override
  final DateTime? airDate;
  @override
  final String? posterPath;
  @override
  @JsonKey()
  final String overview;

  @override
  String toString() {
    return 'TvSeason(tvId: $tvId, seasonNumber: $seasonNumber, name: $name, episodes: $episodes, airDate: $airDate, posterPath: $posterPath, overview: $overview)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TvSeasonImpl &&
            (identical(other.tvId, tvId) || other.tvId == tvId) &&
            (identical(other.seasonNumber, seasonNumber) ||
                other.seasonNumber == seasonNumber) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            (identical(other.airDate, airDate) || other.airDate == airDate) &&
            (identical(other.posterPath, posterPath) ||
                other.posterPath == posterPath) &&
            (identical(other.overview, overview) ||
                other.overview == overview));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    tvId,
    seasonNumber,
    name,
    const DeepCollectionEquality().hash(_episodes),
    airDate,
    posterPath,
    overview,
  );

  /// Create a copy of TvSeason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TvSeasonImplCopyWith<_$TvSeasonImpl> get copyWith =>
      __$$TvSeasonImplCopyWithImpl<_$TvSeasonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TvSeasonImplToJson(this);
  }
}

abstract class _TvSeason extends TvSeason {
  const factory _TvSeason({
    required final int tvId,
    required final int seasonNumber,
    required final String name,
    final List<TvEpisode> episodes,
    final DateTime? airDate,
    final String? posterPath,
    final String overview,
  }) = _$TvSeasonImpl;
  const _TvSeason._() : super._();

  factory _TvSeason.fromJson(Map<String, dynamic> json) =
      _$TvSeasonImpl.fromJson;

  @override
  int get tvId;
  @override
  int get seasonNumber;
  @override
  String get name;
  @override
  List<TvEpisode> get episodes;
  @override
  DateTime? get airDate;
  @override
  String? get posterPath;
  @override
  String get overview;

  /// Create a copy of TvSeason
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TvSeasonImplCopyWith<_$TvSeasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
