import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import 'streaming_provider.dart';
import 'person.dart';

part 'media.freezed.dart';

/// Represents a movie or TV series
@freezed
class Media with _$Media {
  const Media._();

  const factory Media({
    required int id,
    required String title,
    String? originalTitle,
    required String overview,
    String? posterPath,
    String? backdropPath,
    required double voteAverage,
    required int voteCount,
    DateTime? releaseDate,
    required List<int> genreIds,
    required MediaType type,
    @Default([]) List<StreamingProvider> availableOn,
    @Default([]) List<({int id, String logoUrl, String name})> providerData,
    String? imdbId,
    int? runtime, // in minutes
    int? numberOfSeasons,
    int? numberOfEpisodes,
    double? popularity, // TMDB popularity score
    String? ageRating, // FSK rating (e.g. "12", "16", "18")
    @Default([]) List<CastMember> cast,
    @Default([]) List<CrewMember> crew,
  }) = _Media;

  List<String> get providerLogos => providerData.map((e) => e.logoUrl).toList();

  String get fullPosterPath =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get fullBackdropPath => backdropPath != null
      ? 'https://image.tmdb.org/t/p/original$backdropPath'
      : '';

  String get year => releaseDate?.year.toString() ?? 'Unknown';

  bool get isHighlyRated => voteAverage >= 7.0;

  /// Returns the numeric age level based on the current region and certification.
  /// Returns 0 for unknown/missing ratings (treat as unrestricted).
  /// Returns 18 for explicitly "Unrated" / "NR" labels.
  int get ageLevel {
    if (ageRating == null || ageRating!.isEmpty) return 0;

    final isNumeric =
        int.tryParse(ageRating!.replaceAll(RegExp(r'[^0-9]'), '')) != null;
    if (isNumeric && !ageRating!.contains(RegExp(r'[a-zA-Z]'))) {
      return int.parse(ageRating!.replaceAll(RegExp(r'[^0-9]'), ''));
    }

    switch (ageRating!.toUpperCase()) {
      case 'G':
        return 0;
      case 'PG':
        return 6;
      case 'PG-13':
        return 12;
      case 'R':
        return 16;
      case 'NC-17':
        return 18;
      case 'NR':
      case 'UNRATED':
        return 18;
      case 'U':
        return 0;
      case '12A':
        return 12;
      case '15':
        return 15;
      case '18':
        return 18;
    }

    final clean = ageRating!.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  int get fskLevel => ageLevel;

  factory Media.fromTmdbJson(
    Map<String, dynamic> json,
    MediaType type, {
    String targetRegion = 'DE',
  }) {
    String? rating;

    if (type == MediaType.movie) {
      final releaseDates =
          json['release_dates']?['results'] as List<dynamic>? ?? [];
      dynamic regionRelease;

      for (final r in releaseDates) {
        if (r['iso_3166_1'] == targetRegion) {
          regionRelease = r;
          break;
        }
      }

      if (regionRelease == null && targetRegion != 'US') {
        for (final r in releaseDates) {
          if (r['iso_3166_1'] == 'US') {
            regionRelease = r;
            break;
          }
        }
      }

      if (regionRelease != null) {
        final dates = regionRelease['release_dates'] as List<dynamic>? ?? [];
        for (final date in dates) {
          final cert = date['certification'] as String?;
          if (cert != null && cert.isNotEmpty) {
            rating = cert;
            break;
          }
        }
      }
    } else {
      final contentRatings =
          json['content_ratings']?['results'] as List<dynamic>? ?? [];
      dynamic regionRating;

      for (final r in contentRatings) {
        if (r['iso_3166_1'] == targetRegion) {
          regionRating = r;
          break;
        }
      }
      if (regionRating == null && targetRegion != 'US') {
        for (final r in contentRatings) {
          if (r['iso_3166_1'] == 'US') {
            regionRating = r;
            break;
          }
        }
      }

      if (regionRating != null) {
        rating = regionRating['rating'] as String?;
      }
    }

    List<({int id, String logoUrl, String name})> providers = [];
    final watchProviders =
        json['watch/providers']?['results'] as Map<String, dynamic>?;
    if (watchProviders != null) {
      final regionData = watchProviders[targetRegion] as Map<String, dynamic>?;
      if (regionData != null) {
        final List<dynamic> combinedProviders = [];
        if (regionData['flatrate'] != null) {
          combinedProviders.addAll(regionData['flatrate'] as List<dynamic>);
        }
        if (regionData['free'] != null) {
          combinedProviders.addAll(regionData['free'] as List<dynamic>);
        }
        if (regionData['ads'] != null) {
          combinedProviders.addAll(regionData['ads'] as List<dynamic>);
        }

        final seenIds = <int>{};
        for (final p in combinedProviders) {
          final logoPath = p['logo_path'] as String?;
          final providerId = p['provider_id'] as int?;
          final providerName = p['provider_name'] as String?;

          if (logoPath != null && providerId != null && providerName != null) {
            if (!seenIds.contains(providerId)) {
              seenIds.add(providerId);
              // Prefer local asset logos; fall back to TMDB network URL
              final internal = StreamingProvider.fromTmdbId(providerId);
              providers.add((
                id: providerId,
                logoUrl:
                    internal?.logoPath ??
                    'https://image.tmdb.org/t/p/original$logoPath',
                name: providerName,
              ));
            }
          }
        }
      }
    }

    List<CastMember> cast = [];
    List<CrewMember> crew = [];
    final credits = json['credits'];
    if (credits != null) {
      final castData = credits['cast'] as List<dynamic>?;
      if (castData != null) {
        cast = castData
            .map((e) => CastMember.fromTmdbJson(e as Map<String, dynamic>))
            .toList();
      }
      final crewData = credits['crew'] as List<dynamic>?;
      if (crewData != null) {
        crew = crewData
            .map((e) => CrewMember.fromTmdbJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return Media(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      originalTitle:
          json['original_title'] as String? ?? json['original_name'] as String?,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['vote_count'] as int?) ?? 0,
      releaseDate: _parseDate(json['release_date'] ?? json['first_air_date']),
      genreIds:
          (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      type: type,
      popularity: (json['popularity'] as num?)?.toDouble(),
      ageRating: rating,
      providerData: providers,
      cast: cast,
      crew: crew,
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null || date == '') return null;
    try {
      return DateTime.parse(date as String);
    } catch (_) {
      return null;
    }
  }
}

enum MediaType {
  movie,
  tv;

  /// Fallback English display name (no BuildContext needed).
  String get displayName {
    switch (this) {
      case MediaType.movie:
        return 'Movie';
      case MediaType.tv:
        return 'TV Series';
    }
  }

  /// Localized display name — call from within a widget with
  /// `AppLocalizations.of(context)!`.
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case MediaType.movie:
        return l10n.mediaTypeMovie;
      case MediaType.tv:
        return l10n.mediaTypeTv;
    }
  }

  String get tmdbPath {
    switch (this) {
      case MediaType.movie:
        return 'movie';
      case MediaType.tv:
        return 'tv';
    }
  }
}
