// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mediaDetailsHash() => r'f6f68be43c2e6f6a4b993cc430d49a9acc0214be';

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

/// Provider for movie/series details
///
/// Copied from [mediaDetails].
@ProviderFor(mediaDetails)
const mediaDetailsProvider = MediaDetailsFamily();

/// Provider for movie/series details
///
/// Copied from [mediaDetails].
class MediaDetailsFamily extends Family<AsyncValue<Media>> {
  /// Provider for movie/series details
  ///
  /// Copied from [mediaDetails].
  const MediaDetailsFamily();

  /// Provider for movie/series details
  ///
  /// Copied from [mediaDetails].
  MediaDetailsProvider call({required int id, required MediaType type}) {
    return MediaDetailsProvider(id: id, type: type);
  }

  @override
  MediaDetailsProvider getProviderOverride(
    covariant MediaDetailsProvider provider,
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
  String? get name => r'mediaDetailsProvider';
}

/// Provider for movie/series details
///
/// Copied from [mediaDetails].
class MediaDetailsProvider extends AutoDisposeFutureProvider<Media> {
  /// Provider for movie/series details
  ///
  /// Copied from [mediaDetails].
  MediaDetailsProvider({required int id, required MediaType type})
    : this._internal(
        (ref) => mediaDetails(ref as MediaDetailsRef, id: id, type: type),
        from: mediaDetailsProvider,
        name: r'mediaDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mediaDetailsHash,
        dependencies: MediaDetailsFamily._dependencies,
        allTransitiveDependencies:
            MediaDetailsFamily._allTransitiveDependencies,
        id: id,
        type: type,
      );

  MediaDetailsProvider._internal(
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
    FutureOr<Media> Function(MediaDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MediaDetailsProvider._internal(
        (ref) => create(ref as MediaDetailsRef),
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
  AutoDisposeFutureProviderElement<Media> createElement() {
    return _MediaDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MediaDetailsProvider &&
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
mixin MediaDetailsRef on AutoDisposeFutureProviderRef<Media> {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `type` of this provider.
  MediaType get type;
}

class _MediaDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Media>
    with MediaDetailsRef {
  _MediaDetailsProviderElement(super.provider);

  @override
  int get id => (origin as MediaDetailsProvider).id;
  @override
  MediaType get type => (origin as MediaDetailsProvider).type;
}

String _$similarContentHash() => r'fc7dbe85441aa7fd7a310a1d4595f3c835263936';

/// Provider for similar content
///
/// Copied from [similarContent].
@ProviderFor(similarContent)
const similarContentProvider = SimilarContentFamily();

/// Provider for similar content
///
/// Copied from [similarContent].
class SimilarContentFamily extends Family<AsyncValue<List<Media>>> {
  /// Provider for similar content
  ///
  /// Copied from [similarContent].
  const SimilarContentFamily();

  /// Provider for similar content
  ///
  /// Copied from [similarContent].
  SimilarContentProvider call({required int id, required MediaType type}) {
    return SimilarContentProvider(id: id, type: type);
  }

  @override
  SimilarContentProvider getProviderOverride(
    covariant SimilarContentProvider provider,
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
  String? get name => r'similarContentProvider';
}

/// Provider for similar content
///
/// Copied from [similarContent].
class SimilarContentProvider extends AutoDisposeFutureProvider<List<Media>> {
  /// Provider for similar content
  ///
  /// Copied from [similarContent].
  SimilarContentProvider({required int id, required MediaType type})
    : this._internal(
        (ref) => similarContent(ref as SimilarContentRef, id: id, type: type),
        from: similarContentProvider,
        name: r'similarContentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$similarContentHash,
        dependencies: SimilarContentFamily._dependencies,
        allTransitiveDependencies:
            SimilarContentFamily._allTransitiveDependencies,
        id: id,
        type: type,
      );

  SimilarContentProvider._internal(
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
    FutureOr<List<Media>> Function(SimilarContentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SimilarContentProvider._internal(
        (ref) => create(ref as SimilarContentRef),
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
  AutoDisposeFutureProviderElement<List<Media>> createElement() {
    return _SimilarContentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SimilarContentProvider &&
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
mixin SimilarContentRef on AutoDisposeFutureProviderRef<List<Media>> {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `type` of this provider.
  MediaType get type;
}

class _SimilarContentProviderElement
    extends AutoDisposeFutureProviderElement<List<Media>>
    with SimilarContentRef {
  _SimilarContentProviderElement(super.provider);

  @override
  int get id => (origin as SimilarContentProvider).id;
  @override
  MediaType get type => (origin as SimilarContentProvider).type;
}

String _$mediaRecommendationsHash() =>
    r'6443110f3e4639def5f0ac919a47ee523cd60f0b';

/// Provider for recommendations based on specific media
///
/// Copied from [mediaRecommendations].
@ProviderFor(mediaRecommendations)
const mediaRecommendationsProvider = MediaRecommendationsFamily();

/// Provider for recommendations based on specific media
///
/// Copied from [mediaRecommendations].
class MediaRecommendationsFamily extends Family<AsyncValue<List<Media>>> {
  /// Provider for recommendations based on specific media
  ///
  /// Copied from [mediaRecommendations].
  const MediaRecommendationsFamily();

  /// Provider for recommendations based on specific media
  ///
  /// Copied from [mediaRecommendations].
  MediaRecommendationsProvider call({
    required int id,
    required MediaType type,
  }) {
    return MediaRecommendationsProvider(id: id, type: type);
  }

  @override
  MediaRecommendationsProvider getProviderOverride(
    covariant MediaRecommendationsProvider provider,
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
  String? get name => r'mediaRecommendationsProvider';
}

/// Provider for recommendations based on specific media
///
/// Copied from [mediaRecommendations].
class MediaRecommendationsProvider
    extends AutoDisposeFutureProvider<List<Media>> {
  /// Provider for recommendations based on specific media
  ///
  /// Copied from [mediaRecommendations].
  MediaRecommendationsProvider({required int id, required MediaType type})
    : this._internal(
        (ref) => mediaRecommendations(
          ref as MediaRecommendationsRef,
          id: id,
          type: type,
        ),
        from: mediaRecommendationsProvider,
        name: r'mediaRecommendationsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mediaRecommendationsHash,
        dependencies: MediaRecommendationsFamily._dependencies,
        allTransitiveDependencies:
            MediaRecommendationsFamily._allTransitiveDependencies,
        id: id,
        type: type,
      );

  MediaRecommendationsProvider._internal(
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
    FutureOr<List<Media>> Function(MediaRecommendationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MediaRecommendationsProvider._internal(
        (ref) => create(ref as MediaRecommendationsRef),
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
  AutoDisposeFutureProviderElement<List<Media>> createElement() {
    return _MediaRecommendationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MediaRecommendationsProvider &&
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
mixin MediaRecommendationsRef on AutoDisposeFutureProviderRef<List<Media>> {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `type` of this provider.
  MediaType get type;
}

class _MediaRecommendationsProviderElement
    extends AutoDisposeFutureProviderElement<List<Media>>
    with MediaRecommendationsRef {
  _MediaRecommendationsProviderElement(super.provider);

  @override
  int get id => (origin as MediaRecommendationsProvider).id;
  @override
  MediaType get type => (origin as MediaRecommendationsProvider).type;
}

String _$personDetailsHash() => r'4bcc692850b4b26f5fb55ade7aaafee329a00ef1';

/// Provider for actor/director details
///
/// Copied from [personDetails].
@ProviderFor(personDetails)
const personDetailsProvider = PersonDetailsFamily();

/// Provider for actor/director details
///
/// Copied from [personDetails].
class PersonDetailsFamily extends Family<AsyncValue<Person>> {
  /// Provider for actor/director details
  ///
  /// Copied from [personDetails].
  const PersonDetailsFamily();

  /// Provider for actor/director details
  ///
  /// Copied from [personDetails].
  PersonDetailsProvider call(int personId) {
    return PersonDetailsProvider(personId);
  }

  @override
  PersonDetailsProvider getProviderOverride(
    covariant PersonDetailsProvider provider,
  ) {
    return call(provider.personId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'personDetailsProvider';
}

/// Provider for actor/director details
///
/// Copied from [personDetails].
class PersonDetailsProvider extends AutoDisposeFutureProvider<Person> {
  /// Provider for actor/director details
  ///
  /// Copied from [personDetails].
  PersonDetailsProvider(int personId)
    : this._internal(
        (ref) => personDetails(ref as PersonDetailsRef, personId),
        from: personDetailsProvider,
        name: r'personDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$personDetailsHash,
        dependencies: PersonDetailsFamily._dependencies,
        allTransitiveDependencies:
            PersonDetailsFamily._allTransitiveDependencies,
        personId: personId,
      );

  PersonDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personId,
  }) : super.internal();

  final int personId;

  @override
  Override overrideWith(
    FutureOr<Person> Function(PersonDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PersonDetailsProvider._internal(
        (ref) => create(ref as PersonDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personId: personId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Person> createElement() {
    return _PersonDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonDetailsProvider && other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PersonDetailsRef on AutoDisposeFutureProviderRef<Person> {
  /// The parameter `personId` of this provider.
  int get personId;
}

class _PersonDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Person>
    with PersonDetailsRef {
  _PersonDetailsProviderElement(super.provider);

  @override
  int get personId => (origin as PersonDetailsProvider).personId;
}

String _$personCreditsHash() => r'cd7be3678ba8d0aafc18a26f075a959e26f368e2';

/// Provider for actor/director filmography credits
///
/// Copied from [personCredits].
@ProviderFor(personCredits)
const personCreditsProvider = PersonCreditsFamily();

/// Provider for actor/director filmography credits
///
/// Copied from [personCredits].
class PersonCreditsFamily extends Family<AsyncValue<List<PersonCredit>>> {
  /// Provider for actor/director filmography credits
  ///
  /// Copied from [personCredits].
  const PersonCreditsFamily();

  /// Provider for actor/director filmography credits
  ///
  /// Copied from [personCredits].
  PersonCreditsProvider call(int personId) {
    return PersonCreditsProvider(personId);
  }

  @override
  PersonCreditsProvider getProviderOverride(
    covariant PersonCreditsProvider provider,
  ) {
    return call(provider.personId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'personCreditsProvider';
}

/// Provider for actor/director filmography credits
///
/// Copied from [personCredits].
class PersonCreditsProvider
    extends AutoDisposeFutureProvider<List<PersonCredit>> {
  /// Provider for actor/director filmography credits
  ///
  /// Copied from [personCredits].
  PersonCreditsProvider(int personId)
    : this._internal(
        (ref) => personCredits(ref as PersonCreditsRef, personId),
        from: personCreditsProvider,
        name: r'personCreditsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$personCreditsHash,
        dependencies: PersonCreditsFamily._dependencies,
        allTransitiveDependencies:
            PersonCreditsFamily._allTransitiveDependencies,
        personId: personId,
      );

  PersonCreditsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personId,
  }) : super.internal();

  final int personId;

  @override
  Override overrideWith(
    FutureOr<List<PersonCredit>> Function(PersonCreditsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PersonCreditsProvider._internal(
        (ref) => create(ref as PersonCreditsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personId: personId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PersonCredit>> createElement() {
    return _PersonCreditsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonCreditsProvider && other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PersonCreditsRef on AutoDisposeFutureProviderRef<List<PersonCredit>> {
  /// The parameter `personId` of this provider.
  int get personId;
}

class _PersonCreditsProviderElement
    extends AutoDisposeFutureProviderElement<List<PersonCredit>>
    with PersonCreditsRef {
  _PersonCreditsProviderElement(super.provider);

  @override
  int get personId => (origin as PersonCreditsProvider).personId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
