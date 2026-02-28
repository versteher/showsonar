// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$watchHistoryEntriesHash() =>
    r'a30984242f9a2ae77cf4c07e607f534ae8da58f9';

/// Provider for all watch history entries (reactive)
///
/// Copied from [watchHistoryEntries].
@ProviderFor(watchHistoryEntries)
final watchHistoryEntriesProvider =
    AutoDisposeFutureProvider<List<WatchHistoryEntry>>.internal(
      watchHistoryEntries,
      name: r'watchHistoryEntriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$watchHistoryEntriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchHistoryEntriesRef =
    AutoDisposeFutureProviderRef<List<WatchHistoryEntry>>;
String _$watchedMediaIdsHash() => r'6c9503b53bca7985396ddcb487857c30a9b0af96';

/// Provider for a set of watched media IDs (for fast lookup)
/// Returns a Set of "type_id" strings, e.g. {"movie_123", "tv_456"}
///
/// Copied from [watchedMediaIds].
@ProviderFor(watchedMediaIds)
final watchedMediaIdsProvider = AutoDisposeFutureProvider<Set<String>>.internal(
  watchedMediaIds,
  name: r'watchedMediaIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchedMediaIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchedMediaIdsRef = AutoDisposeFutureProviderRef<Set<String>>;
String _$isWatchedHash() => r'e4325da5e5ea249e3a0695e5d60eed6d5fef1c22';

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

/// Provider to check if a specific media is watched
///
/// Copied from [isWatched].
@ProviderFor(isWatched)
const isWatchedProvider = IsWatchedFamily();

/// Provider to check if a specific media is watched
///
/// Copied from [isWatched].
class IsWatchedFamily extends Family<AsyncValue<bool>> {
  /// Provider to check if a specific media is watched
  ///
  /// Copied from [isWatched].
  const IsWatchedFamily();

  /// Provider to check if a specific media is watched
  ///
  /// Copied from [isWatched].
  IsWatchedProvider call({required int id, required MediaType type}) {
    return IsWatchedProvider(id: id, type: type);
  }

  @override
  IsWatchedProvider getProviderOverride(covariant IsWatchedProvider provider) {
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
  String? get name => r'isWatchedProvider';
}

/// Provider to check if a specific media is watched
///
/// Copied from [isWatched].
class IsWatchedProvider extends AutoDisposeFutureProvider<bool> {
  /// Provider to check if a specific media is watched
  ///
  /// Copied from [isWatched].
  IsWatchedProvider({required int id, required MediaType type})
    : this._internal(
        (ref) => isWatched(ref as IsWatchedRef, id: id, type: type),
        from: isWatchedProvider,
        name: r'isWatchedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isWatchedHash,
        dependencies: IsWatchedFamily._dependencies,
        allTransitiveDependencies: IsWatchedFamily._allTransitiveDependencies,
        id: id,
        type: type,
      );

  IsWatchedProvider._internal(
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
  Override overrideWith(FutureOr<bool> Function(IsWatchedRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsWatchedProvider._internal(
        (ref) => create(ref as IsWatchedRef),
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
    return _IsWatchedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsWatchedProvider && other.id == id && other.type == type;
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
mixin IsWatchedRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `type` of this provider.
  MediaType get type;
}

class _IsWatchedProviderElement extends AutoDisposeFutureProviderElement<bool>
    with IsWatchedRef {
  _IsWatchedProviderElement(super.provider);

  @override
  int get id => (origin as IsWatchedProvider).id;
  @override
  MediaType get type => (origin as IsWatchedProvider).type;
}

String _$watchHistoryEntryHash() => r'9ba00eaab1df455f6c931680896f88f901c70012';

/// Provider to get a specific watch history entry
///
/// Copied from [watchHistoryEntry].
@ProviderFor(watchHistoryEntry)
const watchHistoryEntryProvider = WatchHistoryEntryFamily();

/// Provider to get a specific watch history entry
///
/// Copied from [watchHistoryEntry].
class WatchHistoryEntryFamily extends Family<AsyncValue<WatchHistoryEntry?>> {
  /// Provider to get a specific watch history entry
  ///
  /// Copied from [watchHistoryEntry].
  const WatchHistoryEntryFamily();

  /// Provider to get a specific watch history entry
  ///
  /// Copied from [watchHistoryEntry].
  WatchHistoryEntryProvider call({required int id, required MediaType type}) {
    return WatchHistoryEntryProvider(id: id, type: type);
  }

  @override
  WatchHistoryEntryProvider getProviderOverride(
    covariant WatchHistoryEntryProvider provider,
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
  String? get name => r'watchHistoryEntryProvider';
}

/// Provider to get a specific watch history entry
///
/// Copied from [watchHistoryEntry].
class WatchHistoryEntryProvider
    extends AutoDisposeFutureProvider<WatchHistoryEntry?> {
  /// Provider to get a specific watch history entry
  ///
  /// Copied from [watchHistoryEntry].
  WatchHistoryEntryProvider({required int id, required MediaType type})
    : this._internal(
        (ref) =>
            watchHistoryEntry(ref as WatchHistoryEntryRef, id: id, type: type),
        from: watchHistoryEntryProvider,
        name: r'watchHistoryEntryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$watchHistoryEntryHash,
        dependencies: WatchHistoryEntryFamily._dependencies,
        allTransitiveDependencies:
            WatchHistoryEntryFamily._allTransitiveDependencies,
        id: id,
        type: type,
      );

  WatchHistoryEntryProvider._internal(
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
    FutureOr<WatchHistoryEntry?> Function(WatchHistoryEntryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchHistoryEntryProvider._internal(
        (ref) => create(ref as WatchHistoryEntryRef),
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
  AutoDisposeFutureProviderElement<WatchHistoryEntry?> createElement() {
    return _WatchHistoryEntryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchHistoryEntryProvider &&
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
mixin WatchHistoryEntryRef on AutoDisposeFutureProviderRef<WatchHistoryEntry?> {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `type` of this provider.
  MediaType get type;
}

class _WatchHistoryEntryProviderElement
    extends AutoDisposeFutureProviderElement<WatchHistoryEntry?>
    with WatchHistoryEntryRef {
  _WatchHistoryEntryProviderElement(super.provider);

  @override
  int get id => (origin as WatchHistoryEntryProvider).id;
  @override
  MediaType get type => (origin as WatchHistoryEntryProvider).type;
}

String _$watchHistoryStatsHash() => r'2490933eff853972847b9161412e0900c746b57b';

/// Provider for watch history statistics
///
/// Copied from [watchHistoryStats].
@ProviderFor(watchHistoryStats)
final watchHistoryStatsProvider =
    AutoDisposeFutureProvider<WatchHistoryStats>.internal(
      watchHistoryStats,
      name: r'watchHistoryStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$watchHistoryStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchHistoryStatsRef = AutoDisposeFutureProviderRef<WatchHistoryStats>;
String _$weeklyRecapHash() => r'8ea2bca2f6d37572a1a7c794393cd408276c763d';

/// See also [weeklyRecap].
@ProviderFor(weeklyRecap)
final weeklyRecapProvider = AutoDisposeFutureProvider<WeeklyRecap>.internal(
  weeklyRecap,
  name: r'weeklyRecapProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weeklyRecapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyRecapRef = AutoDisposeFutureProviderRef<WeeklyRecap>;
String _$continueWatchingHash() => r'28286acd3415773f39b71098d15ab7006a9459a6';

/// In-progress TV series (completed == false)
///
/// Copied from [continueWatching].
@ProviderFor(continueWatching)
final continueWatchingProvider =
    AutoDisposeFutureProvider<List<WatchHistoryEntry>>.internal(
      continueWatching,
      name: r'continueWatchingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$continueWatchingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContinueWatchingRef =
    AutoDisposeFutureProviderRef<List<WatchHistoryEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
