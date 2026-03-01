// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trendingHash() => r'9609fc98e03af8e543857e5e9f8c61e6796b4ea4';

/// Provider for trending content - filtered by user's streaming services
/// Uses discover sorted by popularity since /trending doesn't support provider filter
///
/// Copied from [trending].
@ProviderFor(trending)
final trendingProvider = AutoDisposeFutureProvider<List<Media>>.internal(
  trending,
  name: r'trendingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trendingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrendingRef = AutoDisposeFutureProviderRef<List<Media>>;
String _$popularMoviesHash() => r'24433f916629a9c292fc8b97c1c948b1cdec3737';

/// Provider for popular movies - filtered by user's streaming services
///
/// Copied from [popularMovies].
@ProviderFor(popularMovies)
final popularMoviesProvider = AutoDisposeFutureProvider<List<Media>>.internal(
  popularMovies,
  name: r'popularMoviesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$popularMoviesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PopularMoviesRef = AutoDisposeFutureProviderRef<List<Media>>;
String _$popularTvSeriesHash() => r'a624bfe200989ff2b8bd79c992d31e6f2ec697f6';

/// Provider for popular TV series - filtered by user's streaming services
///
/// Copied from [popularTvSeries].
@ProviderFor(popularTvSeries)
final popularTvSeriesProvider = AutoDisposeFutureProvider<List<Media>>.internal(
  popularTvSeries,
  name: r'popularTvSeriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$popularTvSeriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PopularTvSeriesRef = AutoDisposeFutureProviderRef<List<Media>>;
String _$topRatedMoviesHash() => r'7179ec7fb8ceb8efb8adf3470bd9a4a2a45b53b2';

/// Provider for top rated movies - filtered by user's streaming services
///
/// Copied from [topRatedMovies].
@ProviderFor(topRatedMovies)
final topRatedMoviesProvider = AutoDisposeFutureProvider<List<Media>>.internal(
  topRatedMovies,
  name: r'topRatedMoviesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$topRatedMoviesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TopRatedMoviesRef = AutoDisposeFutureProviderRef<List<Media>>;
String _$topRatedTvSeriesHash() => r'86323b4fb357f939fd95fae3ffec9bcf4388cc1b';

/// Provider for top rated TV series - filtered by user's streaming services
///
/// Copied from [topRatedTvSeries].
@ProviderFor(topRatedTvSeries)
final topRatedTvSeriesProvider =
    AutoDisposeFutureProvider<List<Media>>.internal(
      topRatedTvSeries,
      name: r'topRatedTvSeriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$topRatedTvSeriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TopRatedTvSeriesRef = AutoDisposeFutureProviderRef<List<Media>>;
String _$upcomingMoviesHash() => r'9fc1253ec9143df60615c7896bc34d75143777a5';

/// Provider for upcoming movies - filtered by user's streaming services
///
/// Copied from [upcomingMovies].
@ProviderFor(upcomingMovies)
final upcomingMoviesProvider = AutoDisposeFutureProvider<List<Media>>.internal(
  upcomingMovies,
  name: r'upcomingMoviesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$upcomingMoviesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingMoviesRef = AutoDisposeFutureProviderRef<List<Media>>;
String _$upcomingTvHash() => r'a017bfbf3e87e4e1dc9fd4ce1d8cadc9849f4371';

/// Provider for upcoming TV series - filtered by user's streaming services
///
/// Copied from [upcomingTv].
@ProviderFor(upcomingTv)
final upcomingTvProvider = AutoDisposeFutureProvider<List<Media>>.internal(
  upcomingTv,
  name: r'upcomingTvProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$upcomingTvHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingTvRef = AutoDisposeFutureProviderRef<List<Media>>;
String _$upcomingHash() => r'b1ab310e291bafd40284ac53e44ab1abaaacdeaa';

/// Combined upcoming content (movies + TV)
///
/// Copied from [upcoming].
@ProviderFor(upcoming)
final upcomingProvider = AutoDisposeFutureProvider<List<Media>>.internal(
  upcoming,
  name: r'upcomingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$upcomingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingRef = AutoDisposeFutureProviderRef<List<Media>>;
String _$trailerUrlHash() => r'4d41550354059e6e1612e19c30cd443a949352ab';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for trailer URL
///
/// Copied from [trailerUrl].
@ProviderFor(trailerUrl)
const trailerUrlProvider = TrailerUrlFamily();

/// Provider for trailer URL
///
/// Copied from [trailerUrl].
class TrailerUrlFamily extends Family<AsyncValue<String?>> {
  /// Provider for trailer URL
  ///
  /// Copied from [trailerUrl].
  const TrailerUrlFamily();

  /// Provider for trailer URL
  ///
  /// Copied from [trailerUrl].
  TrailerUrlProvider call({required int id, required MediaType type}) {
    return TrailerUrlProvider(id: id, type: type);
  }

  @override
  TrailerUrlProvider getProviderOverride(
    covariant TrailerUrlProvider provider,
  ) {
    return call(id: provider.id, type: provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'trailerUrlProvider';
}

/// Provider for trailer URL
///
/// Copied from [trailerUrl].
class TrailerUrlProvider extends AutoDisposeFutureProvider<String?> {
  /// Provider for trailer URL
  ///
  /// Copied from [trailerUrl].
  TrailerUrlProvider({required int id, required MediaType type})
    : this._internal(
        (ref) => trailerUrl(ref as TrailerUrlRef, id: id, type: type),
        from: trailerUrlProvider,
        name: r'trailerUrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trailerUrlHash,
        dependencies: TrailerUrlFamily._dependencies,
        allTransitiveDependencies: TrailerUrlFamily._allTransitiveDependencies,
        id: id,
        type: type,
      );

  TrailerUrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
    required this.type,
  }) : super.internal();

  final int id;
  final MediaType type;

  @override
  Override overrideWith(
    FutureOr<String?> Function(TrailerUrlRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TrailerUrlProvider._internal(
        (ref) => create(ref as TrailerUrlRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _TrailerUrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrailerUrlProvider && other.id == id && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TrailerUrlRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `type` of this provider.
  MediaType get type;
}

class _TrailerUrlProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with TrailerUrlRef {
  _TrailerUrlProviderElement(super.provider);

  @override
  int get id => (origin as TrailerUrlProvider).id;
  @override
  MediaType get type => (origin as TrailerUrlProvider).type;
}

String _$searchResultsHash() => r'7804729f28b86986d502f19eb74ead336c434616';

/// See also [searchResults].
@ProviderFor(searchResults)
final searchResultsProvider = AutoDisposeFutureProvider<List<Media>>.internal(
  searchResults,
  name: r'searchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchResultsRef = AutoDisposeFutureProviderRef<List<Media>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
