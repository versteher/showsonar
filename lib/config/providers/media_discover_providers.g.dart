// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_discover_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$genreDiscoverHash() => r'203321c6cdcdab74bc7ea4f0399fbaee7b399706';

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

/// Provider for genre-based content discovery with pagination (#10)
///
/// Copied from [genreDiscover].
@ProviderFor(genreDiscover)
const genreDiscoverProvider = GenreDiscoverFamily();

/// Provider for genre-based content discovery with pagination (#10)
///
/// Copied from [genreDiscover].
class GenreDiscoverFamily extends Family<AsyncValue<List<Media>>> {
  /// Provider for genre-based content discovery with pagination (#10)
  ///
  /// Copied from [genreDiscover].
  const GenreDiscoverFamily();

  /// Provider for genre-based content discovery with pagination (#10)
  ///
  /// Copied from [genreDiscover].
  GenreDiscoverProvider call({required int genreId, required String sortBy}) {
    return GenreDiscoverProvider(genreId: genreId, sortBy: sortBy);
  }

  @override
  GenreDiscoverProvider getProviderOverride(
    covariant GenreDiscoverProvider provider,
  ) {
    return call(genreId: provider.genreId, sortBy: provider.sortBy);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'genreDiscoverProvider';
}

/// Provider for genre-based content discovery with pagination (#10)
///
/// Copied from [genreDiscover].
class GenreDiscoverProvider extends AutoDisposeFutureProvider<List<Media>> {
  /// Provider for genre-based content discovery with pagination (#10)
  ///
  /// Copied from [genreDiscover].
  GenreDiscoverProvider({required int genreId, required String sortBy})
    : this._internal(
        (ref) => genreDiscover(
          ref as GenreDiscoverRef,
          genreId: genreId,
          sortBy: sortBy,
        ),
        from: genreDiscoverProvider,
        name: r'genreDiscoverProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$genreDiscoverHash,
        dependencies: GenreDiscoverFamily._dependencies,
        allTransitiveDependencies:
            GenreDiscoverFamily._allTransitiveDependencies,
        genreId: genreId,
        sortBy: sortBy,
      );

  GenreDiscoverProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.genreId,
    required this.sortBy,
  }) : super.internal();

  final int genreId;
  final String sortBy;

  @override
  Override overrideWith(
    FutureOr<List<Media>> Function(GenreDiscoverRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GenreDiscoverProvider._internal(
        (ref) => create(ref as GenreDiscoverRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        genreId: genreId,
        sortBy: sortBy,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Media>> createElement() {
    return _GenreDiscoverProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GenreDiscoverProvider &&
        other.genreId == genreId &&
        other.sortBy == sortBy;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, genreId.hashCode);
    hash = _SystemHash.combine(hash, sortBy.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GenreDiscoverRef on AutoDisposeFutureProviderRef<List<Media>> {
  /// The parameter `genreId` of this provider.
  int get genreId;

  /// The parameter `sortBy` of this provider.
  String get sortBy;
}

class _GenreDiscoverProviderElement
    extends AutoDisposeFutureProviderElement<List<Media>>
    with GenreDiscoverRef {
  _GenreDiscoverProviderElement(super.provider);

  @override
  int get genreId => (origin as GenreDiscoverProvider).genreId;
  @override
  String get sortBy => (origin as GenreDiscoverProvider).sortBy;
}

String _$becauseYouWatchedHash() => r'6e31978f7bea890b024cbdb2402db22b90fabdb0';

/// Provider for "Because You Watched X" recommendations.
/// Uses the existing RecommendationEngine which returns groups of similar
/// content based on the user's highly-rated watch history items.
///
/// Copied from [becauseYouWatched].
@ProviderFor(becauseYouWatched)
final becauseYouWatchedProvider =
    AutoDisposeFutureProvider<List<RecommendationGroup>>.internal(
      becauseYouWatched,
      name: r'becauseYouWatchedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$becauseYouWatchedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BecauseYouWatchedRef =
    AutoDisposeFutureProviderRef<List<RecommendationGroup>>;
String _$hiddenGemsHash() => r'96b7f158a95d185cf02a576fd9e440a0739b3d81';

/// Provider for hidden gem content: high rating + lower popularity.
/// Surfaces quality content that users wouldn't normally find browsing
/// mainstream lists. Filters to popularity < 80 (not viral) and
/// voteCount >= 500 (enough reviews to trust the rating).
///
/// Copied from [hiddenGems].
@ProviderFor(hiddenGems)
final hiddenGemsProvider = AutoDisposeFutureProvider<List<Media>>.internal(
  hiddenGems,
  name: r'hiddenGemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hiddenGemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HiddenGemsRef = AutoDisposeFutureProviderRef<List<Media>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
