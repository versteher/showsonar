// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Media {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get originalTitle => throw _privateConstructorUsedError;
  String get overview => throw _privateConstructorUsedError;
  String? get posterPath => throw _privateConstructorUsedError;
  String? get backdropPath => throw _privateConstructorUsedError;
  double get voteAverage => throw _privateConstructorUsedError;
  int get voteCount => throw _privateConstructorUsedError;
  DateTime? get releaseDate => throw _privateConstructorUsedError;
  List<int> get genreIds => throw _privateConstructorUsedError;
  MediaType get type => throw _privateConstructorUsedError;
  List<StreamingProvider> get availableOn => throw _privateConstructorUsedError;
  List<({int id, String logoUrl, String name})> get providerData =>
      throw _privateConstructorUsedError;
  String? get imdbId => throw _privateConstructorUsedError;
  int? get runtime => throw _privateConstructorUsedError; // in minutes
  int? get numberOfSeasons => throw _privateConstructorUsedError;
  int? get numberOfEpisodes => throw _privateConstructorUsedError;
  double? get popularity =>
      throw _privateConstructorUsedError; // TMDB popularity score
  String? get ageRating =>
      throw _privateConstructorUsedError; // FSK rating (e.g. "12", "16", "18")
  List<CastMember> get cast => throw _privateConstructorUsedError;
  List<CrewMember> get crew => throw _privateConstructorUsedError;

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaCopyWith<Media> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaCopyWith<$Res> {
  factory $MediaCopyWith(Media value, $Res Function(Media) then) =
      _$MediaCopyWithImpl<$Res, Media>;
  @useResult
  $Res call({
    int id,
    String title,
    String? originalTitle,
    String overview,
    String? posterPath,
    String? backdropPath,
    double voteAverage,
    int voteCount,
    DateTime? releaseDate,
    List<int> genreIds,
    MediaType type,
    List<StreamingProvider> availableOn,
    List<({int id, String logoUrl, String name})> providerData,
    String? imdbId,
    int? runtime,
    int? numberOfSeasons,
    int? numberOfEpisodes,
    double? popularity,
    String? ageRating,
    List<CastMember> cast,
    List<CrewMember> crew,
  });
}

/// @nodoc
class _$MediaCopyWithImpl<$Res, $Val extends Media>
    implements $MediaCopyWith<$Res> {
  _$MediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? originalTitle = freezed,
    Object? overview = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? voteAverage = null,
    Object? voteCount = null,
    Object? releaseDate = freezed,
    Object? genreIds = null,
    Object? type = null,
    Object? availableOn = null,
    Object? providerData = null,
    Object? imdbId = freezed,
    Object? runtime = freezed,
    Object? numberOfSeasons = freezed,
    Object? numberOfEpisodes = freezed,
    Object? popularity = freezed,
    Object? ageRating = freezed,
    Object? cast = null,
    Object? crew = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            originalTitle: freezed == originalTitle
                ? _value.originalTitle
                : originalTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            overview: null == overview
                ? _value.overview
                : overview // ignore: cast_nullable_to_non_nullable
                      as String,
            posterPath: freezed == posterPath
                ? _value.posterPath
                : posterPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            backdropPath: freezed == backdropPath
                ? _value.backdropPath
                : backdropPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            voteAverage: null == voteAverage
                ? _value.voteAverage
                : voteAverage // ignore: cast_nullable_to_non_nullable
                      as double,
            voteCount: null == voteCount
                ? _value.voteCount
                : voteCount // ignore: cast_nullable_to_non_nullable
                      as int,
            releaseDate: freezed == releaseDate
                ? _value.releaseDate
                : releaseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            genreIds: null == genreIds
                ? _value.genreIds
                : genreIds // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MediaType,
            availableOn: null == availableOn
                ? _value.availableOn
                : availableOn // ignore: cast_nullable_to_non_nullable
                      as List<StreamingProvider>,
            providerData: null == providerData
                ? _value.providerData
                : providerData // ignore: cast_nullable_to_non_nullable
                      as List<({int id, String logoUrl, String name})>,
            imdbId: freezed == imdbId
                ? _value.imdbId
                : imdbId // ignore: cast_nullable_to_non_nullable
                      as String?,
            runtime: freezed == runtime
                ? _value.runtime
                : runtime // ignore: cast_nullable_to_non_nullable
                      as int?,
            numberOfSeasons: freezed == numberOfSeasons
                ? _value.numberOfSeasons
                : numberOfSeasons // ignore: cast_nullable_to_non_nullable
                      as int?,
            numberOfEpisodes: freezed == numberOfEpisodes
                ? _value.numberOfEpisodes
                : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
                      as int?,
            popularity: freezed == popularity
                ? _value.popularity
                : popularity // ignore: cast_nullable_to_non_nullable
                      as double?,
            ageRating: freezed == ageRating
                ? _value.ageRating
                : ageRating // ignore: cast_nullable_to_non_nullable
                      as String?,
            cast: null == cast
                ? _value.cast
                : cast // ignore: cast_nullable_to_non_nullable
                      as List<CastMember>,
            crew: null == crew
                ? _value.crew
                : crew // ignore: cast_nullable_to_non_nullable
                      as List<CrewMember>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MediaImplCopyWith<$Res> implements $MediaCopyWith<$Res> {
  factory _$$MediaImplCopyWith(
    _$MediaImpl value,
    $Res Function(_$MediaImpl) then,
  ) = __$$MediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String? originalTitle,
    String overview,
    String? posterPath,
    String? backdropPath,
    double voteAverage,
    int voteCount,
    DateTime? releaseDate,
    List<int> genreIds,
    MediaType type,
    List<StreamingProvider> availableOn,
    List<({int id, String logoUrl, String name})> providerData,
    String? imdbId,
    int? runtime,
    int? numberOfSeasons,
    int? numberOfEpisodes,
    double? popularity,
    String? ageRating,
    List<CastMember> cast,
    List<CrewMember> crew,
  });
}

/// @nodoc
class __$$MediaImplCopyWithImpl<$Res>
    extends _$MediaCopyWithImpl<$Res, _$MediaImpl>
    implements _$$MediaImplCopyWith<$Res> {
  __$$MediaImplCopyWithImpl(
    _$MediaImpl _value,
    $Res Function(_$MediaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? originalTitle = freezed,
    Object? overview = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? voteAverage = null,
    Object? voteCount = null,
    Object? releaseDate = freezed,
    Object? genreIds = null,
    Object? type = null,
    Object? availableOn = null,
    Object? providerData = null,
    Object? imdbId = freezed,
    Object? runtime = freezed,
    Object? numberOfSeasons = freezed,
    Object? numberOfEpisodes = freezed,
    Object? popularity = freezed,
    Object? ageRating = freezed,
    Object? cast = null,
    Object? crew = null,
  }) {
    return _then(
      _$MediaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        originalTitle: freezed == originalTitle
            ? _value.originalTitle
            : originalTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        overview: null == overview
            ? _value.overview
            : overview // ignore: cast_nullable_to_non_nullable
                  as String,
        posterPath: freezed == posterPath
            ? _value.posterPath
            : posterPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        backdropPath: freezed == backdropPath
            ? _value.backdropPath
            : backdropPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        voteAverage: null == voteAverage
            ? _value.voteAverage
            : voteAverage // ignore: cast_nullable_to_non_nullable
                  as double,
        voteCount: null == voteCount
            ? _value.voteCount
            : voteCount // ignore: cast_nullable_to_non_nullable
                  as int,
        releaseDate: freezed == releaseDate
            ? _value.releaseDate
            : releaseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        genreIds: null == genreIds
            ? _value._genreIds
            : genreIds // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MediaType,
        availableOn: null == availableOn
            ? _value._availableOn
            : availableOn // ignore: cast_nullable_to_non_nullable
                  as List<StreamingProvider>,
        providerData: null == providerData
            ? _value._providerData
            : providerData // ignore: cast_nullable_to_non_nullable
                  as List<({int id, String logoUrl, String name})>,
        imdbId: freezed == imdbId
            ? _value.imdbId
            : imdbId // ignore: cast_nullable_to_non_nullable
                  as String?,
        runtime: freezed == runtime
            ? _value.runtime
            : runtime // ignore: cast_nullable_to_non_nullable
                  as int?,
        numberOfSeasons: freezed == numberOfSeasons
            ? _value.numberOfSeasons
            : numberOfSeasons // ignore: cast_nullable_to_non_nullable
                  as int?,
        numberOfEpisodes: freezed == numberOfEpisodes
            ? _value.numberOfEpisodes
            : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
                  as int?,
        popularity: freezed == popularity
            ? _value.popularity
            : popularity // ignore: cast_nullable_to_non_nullable
                  as double?,
        ageRating: freezed == ageRating
            ? _value.ageRating
            : ageRating // ignore: cast_nullable_to_non_nullable
                  as String?,
        cast: null == cast
            ? _value._cast
            : cast // ignore: cast_nullable_to_non_nullable
                  as List<CastMember>,
        crew: null == crew
            ? _value._crew
            : crew // ignore: cast_nullable_to_non_nullable
                  as List<CrewMember>,
      ),
    );
  }
}

/// @nodoc

class _$MediaImpl extends _Media {
  const _$MediaImpl({
    required this.id,
    required this.title,
    this.originalTitle,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    required final List<int> genreIds,
    required this.type,
    final List<StreamingProvider> availableOn = const [],
    final List<({int id, String logoUrl, String name})> providerData = const [],
    this.imdbId,
    this.runtime,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.popularity,
    this.ageRating,
    final List<CastMember> cast = const [],
    final List<CrewMember> crew = const [],
  }) : _genreIds = genreIds,
       _availableOn = availableOn,
       _providerData = providerData,
       _cast = cast,
       _crew = crew,
       super._();

  @override
  final int id;
  @override
  final String title;
  @override
  final String? originalTitle;
  @override
  final String overview;
  @override
  final String? posterPath;
  @override
  final String? backdropPath;
  @override
  final double voteAverage;
  @override
  final int voteCount;
  @override
  final DateTime? releaseDate;
  final List<int> _genreIds;
  @override
  List<int> get genreIds {
    if (_genreIds is EqualUnmodifiableListView) return _genreIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genreIds);
  }

  @override
  final MediaType type;
  final List<StreamingProvider> _availableOn;
  @override
  @JsonKey()
  List<StreamingProvider> get availableOn {
    if (_availableOn is EqualUnmodifiableListView) return _availableOn;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableOn);
  }

  final List<({int id, String logoUrl, String name})> _providerData;
  @override
  @JsonKey()
  List<({int id, String logoUrl, String name})> get providerData {
    if (_providerData is EqualUnmodifiableListView) return _providerData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_providerData);
  }

  @override
  final String? imdbId;
  @override
  final int? runtime;
  // in minutes
  @override
  final int? numberOfSeasons;
  @override
  final int? numberOfEpisodes;
  @override
  final double? popularity;
  // TMDB popularity score
  @override
  final String? ageRating;
  // FSK rating (e.g. "12", "16", "18")
  final List<CastMember> _cast;
  // FSK rating (e.g. "12", "16", "18")
  @override
  @JsonKey()
  List<CastMember> get cast {
    if (_cast is EqualUnmodifiableListView) return _cast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cast);
  }

  final List<CrewMember> _crew;
  @override
  @JsonKey()
  List<CrewMember> get crew {
    if (_crew is EqualUnmodifiableListView) return _crew;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_crew);
  }

  @override
  String toString() {
    return 'Media(id: $id, title: $title, originalTitle: $originalTitle, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, voteAverage: $voteAverage, voteCount: $voteCount, releaseDate: $releaseDate, genreIds: $genreIds, type: $type, availableOn: $availableOn, providerData: $providerData, imdbId: $imdbId, runtime: $runtime, numberOfSeasons: $numberOfSeasons, numberOfEpisodes: $numberOfEpisodes, popularity: $popularity, ageRating: $ageRating, cast: $cast, crew: $crew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.originalTitle, originalTitle) ||
                other.originalTitle == originalTitle) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.posterPath, posterPath) ||
                other.posterPath == posterPath) &&
            (identical(other.backdropPath, backdropPath) ||
                other.backdropPath == backdropPath) &&
            (identical(other.voteAverage, voteAverage) ||
                other.voteAverage == voteAverage) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            const DeepCollectionEquality().equals(other._genreIds, _genreIds) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(
              other._availableOn,
              _availableOn,
            ) &&
            const DeepCollectionEquality().equals(
              other._providerData,
              _providerData,
            ) &&
            (identical(other.imdbId, imdbId) || other.imdbId == imdbId) &&
            (identical(other.runtime, runtime) || other.runtime == runtime) &&
            (identical(other.numberOfSeasons, numberOfSeasons) ||
                other.numberOfSeasons == numberOfSeasons) &&
            (identical(other.numberOfEpisodes, numberOfEpisodes) ||
                other.numberOfEpisodes == numberOfEpisodes) &&
            (identical(other.popularity, popularity) ||
                other.popularity == popularity) &&
            (identical(other.ageRating, ageRating) ||
                other.ageRating == ageRating) &&
            const DeepCollectionEquality().equals(other._cast, _cast) &&
            const DeepCollectionEquality().equals(other._crew, _crew));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    originalTitle,
    overview,
    posterPath,
    backdropPath,
    voteAverage,
    voteCount,
    releaseDate,
    const DeepCollectionEquality().hash(_genreIds),
    type,
    const DeepCollectionEquality().hash(_availableOn),
    const DeepCollectionEquality().hash(_providerData),
    imdbId,
    runtime,
    numberOfSeasons,
    numberOfEpisodes,
    popularity,
    ageRating,
    const DeepCollectionEquality().hash(_cast),
    const DeepCollectionEquality().hash(_crew),
  ]);

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaImplCopyWith<_$MediaImpl> get copyWith =>
      __$$MediaImplCopyWithImpl<_$MediaImpl>(this, _$identity);
}

abstract class _Media extends Media {
  const factory _Media({
    required final int id,
    required final String title,
    final String? originalTitle,
    required final String overview,
    final String? posterPath,
    final String? backdropPath,
    required final double voteAverage,
    required final int voteCount,
    final DateTime? releaseDate,
    required final List<int> genreIds,
    required final MediaType type,
    final List<StreamingProvider> availableOn,
    final List<({int id, String logoUrl, String name})> providerData,
    final String? imdbId,
    final int? runtime,
    final int? numberOfSeasons,
    final int? numberOfEpisodes,
    final double? popularity,
    final String? ageRating,
    final List<CastMember> cast,
    final List<CrewMember> crew,
  }) = _$MediaImpl;
  const _Media._() : super._();

  @override
  int get id;
  @override
  String get title;
  @override
  String? get originalTitle;
  @override
  String get overview;
  @override
  String? get posterPath;
  @override
  String? get backdropPath;
  @override
  double get voteAverage;
  @override
  int get voteCount;
  @override
  DateTime? get releaseDate;
  @override
  List<int> get genreIds;
  @override
  MediaType get type;
  @override
  List<StreamingProvider> get availableOn;
  @override
  List<({int id, String logoUrl, String name})> get providerData;
  @override
  String? get imdbId;
  @override
  int? get runtime; // in minutes
  @override
  int? get numberOfSeasons;
  @override
  int? get numberOfEpisodes;
  @override
  double? get popularity; // TMDB popularity score
  @override
  String? get ageRating; // FSK rating (e.g. "12", "16", "18")
  @override
  List<CastMember> get cast;
  @override
  List<CrewMember> get crew;

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaImplCopyWith<_$MediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
