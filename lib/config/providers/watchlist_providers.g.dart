// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$watchlistEntriesHash() => r'9de9d5c69835e0bfa7e81cfaf00e6bcb6973f3e9';

/// Provider for all watchlist entries (reactive)
///
/// Copied from [watchlistEntries].
@ProviderFor(watchlistEntries)
final watchlistEntriesProvider =
    AutoDisposeFutureProvider<List<WatchlistEntry>>.internal(
      watchlistEntries,
      name: r'watchlistEntriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$watchlistEntriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchlistEntriesRef =
    AutoDisposeFutureProviderRef<List<WatchlistEntry>>;
String _$isOnWatchlistHash() => r'4200b4a80483ce08cc19f92e9ff4cfc1804df037';

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

/// Provider to check if a specific media is on the watchlist
///
/// Copied from [isOnWatchlist].
@ProviderFor(isOnWatchlist)
const isOnWatchlistProvider = IsOnWatchlistFamily();

/// Provider to check if a specific media is on the watchlist
///
/// Copied from [isOnWatchlist].
class IsOnWatchlistFamily extends Family<AsyncValue<bool>> {
  /// Provider to check if a specific media is on the watchlist
  ///
  /// Copied from [isOnWatchlist].
  const IsOnWatchlistFamily();

  /// Provider to check if a specific media is on the watchlist
  ///
  /// Copied from [isOnWatchlist].
  IsOnWatchlistProvider call({required int id, required MediaType type}) {
    return IsOnWatchlistProvider(id: id, type: type);
  }

  @override
  IsOnWatchlistProvider getProviderOverride(
    covariant IsOnWatchlistProvider provider,
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
  String? get name => r'isOnWatchlistProvider';
}

/// Provider to check if a specific media is on the watchlist
///
/// Copied from [isOnWatchlist].
class IsOnWatchlistProvider extends AutoDisposeFutureProvider<bool> {
  /// Provider to check if a specific media is on the watchlist
  ///
  /// Copied from [isOnWatchlist].
  IsOnWatchlistProvider({required int id, required MediaType type})
    : this._internal(
        (ref) => isOnWatchlist(ref as IsOnWatchlistRef, id: id, type: type),
        from: isOnWatchlistProvider,
        name: r'isOnWatchlistProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isOnWatchlistHash,
        dependencies: IsOnWatchlistFamily._dependencies,
        allTransitiveDependencies:
            IsOnWatchlistFamily._allTransitiveDependencies,
        id: id,
        type: type,
      );

  IsOnWatchlistProvider._internal(
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
    FutureOr<bool> Function(IsOnWatchlistRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsOnWatchlistProvider._internal(
        (ref) => create(ref as IsOnWatchlistRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsOnWatchlistProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsOnWatchlistProvider &&
        other.id == id &&
        other.type == type;
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
mixin IsOnWatchlistRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `type` of this provider.
  MediaType get type;
}

class _IsOnWatchlistProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with IsOnWatchlistRef {
  _IsOnWatchlistProviderElement(super.provider);

  @override
  int get id => (origin as IsOnWatchlistProvider).id;
  @override
  MediaType get type => (origin as IsOnWatchlistProvider).type;
}

String _$watchlistMediaIdsHash() => r'f8a143f562dc90054f11a94df11435799e6894eb';

/// Provider for set of watchlist media IDs (for fast lookup)
///
/// Copied from [watchlistMediaIds].
@ProviderFor(watchlistMediaIds)
final watchlistMediaIdsProvider =
    AutoDisposeFutureProvider<Set<String>>.internal(
      watchlistMediaIds,
      name: r'watchlistMediaIdsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$watchlistMediaIdsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchlistMediaIdsRef = AutoDisposeFutureProviderRef<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
