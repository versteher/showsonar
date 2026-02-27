// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tv_episode.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TvEpisode _$TvEpisodeFromJson(Map<String, dynamic> json) {
  return _TvEpisode.fromJson(json);
}

/// @nodoc
mixin _$TvEpisode {
  int get episodeNumber => throw _privateConstructorUsedError;
  int get seasonNumber => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get overview => throw _privateConstructorUsedError;
  DateTime? get airDate => throw _privateConstructorUsedError;
  int? get runtime => throw _privateConstructorUsedError; // in minutes
  String? get stillPath => throw _privateConstructorUsedError;
  double get voteAverage => throw _privateConstructorUsedError;
  int get voteCount => throw _privateConstructorUsedError;

  /// Serializes this TvEpisode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TvEpisode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TvEpisodeCopyWith<TvEpisode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TvEpisodeCopyWith<$Res> {
  factory $TvEpisodeCopyWith(TvEpisode value, $Res Function(TvEpisode) then) =
      _$TvEpisodeCopyWithImpl<$Res, TvEpisode>;
  @useResult
  $Res call({
    int episodeNumber,
    int seasonNumber,
    String name,
    String overview,
    DateTime? airDate,
    int? runtime,
    String? stillPath,
    double voteAverage,
    int voteCount,
  });
}

/// @nodoc
class _$TvEpisodeCopyWithImpl<$Res, $Val extends TvEpisode>
    implements $TvEpisodeCopyWith<$Res> {
  _$TvEpisodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TvEpisode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodeNumber = null,
    Object? seasonNumber = null,
    Object? name = null,
    Object? overview = null,
    Object? airDate = freezed,
    Object? runtime = freezed,
    Object? stillPath = freezed,
    Object? voteAverage = null,
    Object? voteCount = null,
  }) {
    return _then(
      _value.copyWith(
            episodeNumber: null == episodeNumber
                ? _value.episodeNumber
                : episodeNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            seasonNumber: null == seasonNumber
                ? _value.seasonNumber
                : seasonNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            overview: null == overview
                ? _value.overview
                : overview // ignore: cast_nullable_to_non_nullable
                      as String,
            airDate: freezed == airDate
                ? _value.airDate
                : airDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            runtime: freezed == runtime
                ? _value.runtime
                : runtime // ignore: cast_nullable_to_non_nullable
                      as int?,
            stillPath: freezed == stillPath
                ? _value.stillPath
                : stillPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            voteAverage: null == voteAverage
                ? _value.voteAverage
                : voteAverage // ignore: cast_nullable_to_non_nullable
                      as double,
            voteCount: null == voteCount
                ? _value.voteCount
                : voteCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TvEpisodeImplCopyWith<$Res>
    implements $TvEpisodeCopyWith<$Res> {
  factory _$$TvEpisodeImplCopyWith(
    _$TvEpisodeImpl value,
    $Res Function(_$TvEpisodeImpl) then,
  ) = __$$TvEpisodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int episodeNumber,
    int seasonNumber,
    String name,
    String overview,
    DateTime? airDate,
    int? runtime,
    String? stillPath,
    double voteAverage,
    int voteCount,
  });
}

/// @nodoc
class __$$TvEpisodeImplCopyWithImpl<$Res>
    extends _$TvEpisodeCopyWithImpl<$Res, _$TvEpisodeImpl>
    implements _$$TvEpisodeImplCopyWith<$Res> {
  __$$TvEpisodeImplCopyWithImpl(
    _$TvEpisodeImpl _value,
    $Res Function(_$TvEpisodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TvEpisode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodeNumber = null,
    Object? seasonNumber = null,
    Object? name = null,
    Object? overview = null,
    Object? airDate = freezed,
    Object? runtime = freezed,
    Object? stillPath = freezed,
    Object? voteAverage = null,
    Object? voteCount = null,
  }) {
    return _then(
      _$TvEpisodeImpl(
        episodeNumber: null == episodeNumber
            ? _value.episodeNumber
            : episodeNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        seasonNumber: null == seasonNumber
            ? _value.seasonNumber
            : seasonNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        overview: null == overview
            ? _value.overview
            : overview // ignore: cast_nullable_to_non_nullable
                  as String,
        airDate: freezed == airDate
            ? _value.airDate
            : airDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        runtime: freezed == runtime
            ? _value.runtime
            : runtime // ignore: cast_nullable_to_non_nullable
                  as int?,
        stillPath: freezed == stillPath
            ? _value.stillPath
            : stillPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        voteAverage: null == voteAverage
            ? _value.voteAverage
            : voteAverage // ignore: cast_nullable_to_non_nullable
                  as double,
        voteCount: null == voteCount
            ? _value.voteCount
            : voteCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TvEpisodeImpl extends _TvEpisode {
  const _$TvEpisodeImpl({
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    this.overview = '',
    this.airDate,
    this.runtime,
    this.stillPath,
    this.voteAverage = 0.0,
    this.voteCount = 0,
  }) : super._();

  factory _$TvEpisodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TvEpisodeImplFromJson(json);

  @override
  final int episodeNumber;
  @override
  final int seasonNumber;
  @override
  final String name;
  @override
  @JsonKey()
  final String overview;
  @override
  final DateTime? airDate;
  @override
  final int? runtime;
  // in minutes
  @override
  final String? stillPath;
  @override
  @JsonKey()
  final double voteAverage;
  @override
  @JsonKey()
  final int voteCount;

  @override
  String toString() {
    return 'TvEpisode(episodeNumber: $episodeNumber, seasonNumber: $seasonNumber, name: $name, overview: $overview, airDate: $airDate, runtime: $runtime, stillPath: $stillPath, voteAverage: $voteAverage, voteCount: $voteCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TvEpisodeImpl &&
            (identical(other.episodeNumber, episodeNumber) ||
                other.episodeNumber == episodeNumber) &&
            (identical(other.seasonNumber, seasonNumber) ||
                other.seasonNumber == seasonNumber) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.airDate, airDate) || other.airDate == airDate) &&
            (identical(other.runtime, runtime) || other.runtime == runtime) &&
            (identical(other.stillPath, stillPath) ||
                other.stillPath == stillPath) &&
            (identical(other.voteAverage, voteAverage) ||
                other.voteAverage == voteAverage) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    episodeNumber,
    seasonNumber,
    name,
    overview,
    airDate,
    runtime,
    stillPath,
    voteAverage,
    voteCount,
  );

  /// Create a copy of TvEpisode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TvEpisodeImplCopyWith<_$TvEpisodeImpl> get copyWith =>
      __$$TvEpisodeImplCopyWithImpl<_$TvEpisodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TvEpisodeImplToJson(this);
  }
}

abstract class _TvEpisode extends TvEpisode {
  const factory _TvEpisode({
    required final int episodeNumber,
    required final int seasonNumber,
    required final String name,
    final String overview,
    final DateTime? airDate,
    final int? runtime,
    final String? stillPath,
    final double voteAverage,
    final int voteCount,
  }) = _$TvEpisodeImpl;
  const _TvEpisode._() : super._();

  factory _TvEpisode.fromJson(Map<String, dynamic> json) =
      _$TvEpisodeImpl.fromJson;

  @override
  int get episodeNumber;
  @override
  int get seasonNumber;
  @override
  String get name;
  @override
  String get overview;
  @override
  DateTime? get airDate;
  @override
  int? get runtime; // in minutes
  @override
  String? get stillPath;
  @override
  double get voteAverage;
  @override
  int get voteCount;

  /// Create a copy of TvEpisode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TvEpisodeImplCopyWith<_$TvEpisodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
