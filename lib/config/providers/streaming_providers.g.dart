// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streaming_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$providerCountsHash() => r'5c7bb54aa4bbd5fb87858863accfec92feb8bcf0';

/// Provider for the number of matching titles per streaming provider.
/// Uses keepAlive to avoid refetching on every widget rebuild.
///
/// Copied from [providerCounts].
@ProviderFor(providerCounts)
final providerCountsProvider =
    AutoDisposeFutureProvider<Map<String, int>>.internal(
      providerCounts,
      name: r'providerCountsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$providerCountsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProviderCountsRef = AutoDisposeFutureProviderRef<Map<String, int>>;
String _$mediaAvailabilityHash() => r'7356378f2a18d7de5dc17b11bc0128c6c6976ae8';

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

/// Provider for streaming availability of a specific media item.
/// Uses keepAlive so logo data is cached and doesn't flicker when cards
/// scroll in and out of view.
///
/// Copied from [mediaAvailability].
@ProviderFor(mediaAvailability)
const mediaAvailabilityProvider = MediaAvailabilityFamily();

/// Provider for streaming availability of a specific media item.
/// Uses keepAlive so logo data is cached and doesn't flicker when cards
/// scroll in and out of view.
///
/// Copied from [mediaAvailability].
class MediaAvailabilityFamily
    extends
        Family<
          AsyncValue<List<({StreamingProvider provider, String logoUrl})>>
        > {
  /// Provider for streaming availability of a specific media item.
  /// Uses keepAlive so logo data is cached and doesn't flicker when cards
  /// scroll in and out of view.
  ///
  /// Copied from [mediaAvailability].
  const MediaAvailabilityFamily();

  /// Provider for streaming availability of a specific media item.
  /// Uses keepAlive so logo data is cached and doesn't flicker when cards
  /// scroll in and out of view.
  ///
  /// Copied from [mediaAvailability].
  MediaAvailabilityProvider call({required int id, required MediaType type}) {
    return MediaAvailabilityProvider(id: id, type: type);
  }

  @override
  MediaAvailabilityProvider getProviderOverride(
    covariant MediaAvailabilityProvider provider,
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
  String? get name => r'mediaAvailabilityProvider';
}

/// Provider for streaming availability of a specific media item.
/// Uses keepAlive so logo data is cached and doesn't flicker when cards
/// scroll in and out of view.
///
/// Copied from [mediaAvailability].
class MediaAvailabilityProvider
    extends
        AutoDisposeFutureProvider<
          List<({StreamingProvider provider, String logoUrl})>
        > {
  /// Provider for streaming availability of a specific media item.
  /// Uses keepAlive so logo data is cached and doesn't flicker when cards
  /// scroll in and out of view.
  ///
  /// Copied from [mediaAvailability].
  MediaAvailabilityProvider({required int id, required MediaType type})
    : this._internal(
        (ref) =>
            mediaAvailability(ref as MediaAvailabilityRef, id: id, type: type),
        from: mediaAvailabilityProvider,
        name: r'mediaAvailabilityProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mediaAvailabilityHash,
        dependencies: MediaAvailabilityFamily._dependencies,
        allTransitiveDependencies:
            MediaAvailabilityFamily._allTransitiveDependencies,
        id: id,
        type: type,
      );

  MediaAvailabilityProvider._internal(
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
    FutureOr<List<({StreamingProvider provider, String logoUrl})>> Function(
      MediaAvailabilityRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MediaAvailabilityProvider._internal(
        (ref) => create(ref as MediaAvailabilityRef),
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
  AutoDisposeFutureProviderElement<
    List<({StreamingProvider provider, String logoUrl})>
  >
  createElement() {
    return _MediaAvailabilityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MediaAvailabilityProvider &&
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
mixin MediaAvailabilityRef
    on
        AutoDisposeFutureProviderRef<
          List<({StreamingProvider provider, String logoUrl})>
        > {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `type` of this provider.
  MediaType get type;
}

class _MediaAvailabilityProviderElement
    extends
        AutoDisposeFutureProviderElement<
          List<({StreamingProvider provider, String logoUrl})>
        >
    with MediaAvailabilityRef {
  _MediaAvailabilityProviderElement(super.provider);

  @override
  int get id => (origin as MediaAvailabilityProvider).id;
  @override
  MediaType get type => (origin as MediaAvailabilityProvider).type;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
