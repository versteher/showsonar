import '../models/media.dart';
import '../models/person.dart';
import '../models/tv_season.dart';
import '../../utils/age_rating_mapper.dart';
import '../../config/api_config.dart';
import '../services/tmdb_api_client.dart';

/// Result from watch providers API
class WatchProviderResult {
  final List<WatchProvider> flatrate; // Streaming subscriptions
  final List<WatchProvider> buy; // Purchase
  final List<WatchProvider> rent; // Rental
  final String? link; // Link to JustWatch

  const WatchProviderResult({
    required this.flatrate,
    required this.buy,
    required this.rent,
    this.link,
  });

  factory WatchProviderResult.empty() =>
      const WatchProviderResult(flatrate: [], buy: [], rent: []);

  factory WatchProviderResult.fromJson(Map<String, dynamic> json) {
    final combinedFlatrate = <WatchProvider>[];
    combinedFlatrate.addAll(_parseProviders(json['flatrate']));
    combinedFlatrate.addAll(_parseProviders(json['free']));
    combinedFlatrate.addAll(_parseProviders(json['ads']));

    final uniqueFlatrate = <int, WatchProvider>{};
    for (final provider in combinedFlatrate) {
      uniqueFlatrate[provider.providerId] = provider;
    }

    return WatchProviderResult(
      flatrate: uniqueFlatrate.values.toList(),
      buy: _parseProviders(json['buy']),
      rent: _parseProviders(json['rent']),
      link: json['link'] as String?,
    );
  }

  static List<WatchProvider> _parseProviders(dynamic data) {
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((p) => WatchProvider.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  bool get hasStreamingOptions => flatrate.isNotEmpty;
  bool get hasAnyOptions =>
      flatrate.isNotEmpty || buy.isNotEmpty || rent.isNotEmpty;
}

/// A streaming/purchase provider from TMDB
class WatchProvider {
  final int providerId;
  final String name;
  final String? logoPath;
  final int displayPriority;

  const WatchProvider({
    required this.providerId,
    required this.name,
    this.logoPath,
    this.displayPriority = 0,
  });

  factory WatchProvider.fromJson(Map<String, dynamic> json) {
    return WatchProvider(
      providerId: json['provider_id'] as int,
      name: json['provider_name'] as String,
      logoPath: json['logo_path'] as String?,
      displayPriority: json['display_priority'] as int? ?? 0,
    );
  }

  String get fullLogoUrl =>
      logoPath != null ? 'https://image.tmdb.org/t/p/w92$logoPath' : '';
}

abstract class ITmdbRepository {
  Future<List<Media>> searchMulti(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? maxAgeRating,
  });
  Future<List<Media>> searchMovies(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? maxAgeRating,
  });
  Future<List<Media>> searchTvSeries(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? maxAgeRating,
  });

  Future<List<Media>> getTrending({
    MediaType? type,
    String timeWindow = 'week',
    int page = 1,
  });
  Future<List<Media>> getPopularMovies({int page = 1});
  Future<List<Media>> getPopularTvSeries({int page = 1});
  Future<List<Media>> getTopRatedMovies({int page = 1});
  Future<List<Media>> getTopRatedTvSeries({int page = 1});

  Future<Media> getMovieDetails(int movieId);
  Future<Media> getTvDetails(int tvId);
  Future<List<Media>> getSimilar(int mediaId, MediaType type);
  Future<List<Media>> getRecommendations(int mediaId, MediaType type);

  Future<List<Media>> discoverMovies({
    List<int>? genreIds,
    double? minRating,
    int? year,
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  });

  Future<({List<Media> results, int totalResults})> discoverMoviesWithCount({
    List<int>? genreIds,
    double? minRating,
    int? year,
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  });

  Future<List<Media>> discoverTvSeries({
    List<int>? genreIds,
    double? minRating,
    int? year,
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  });

  Future<({List<Media> results, int totalResults})> discoverTvSeriesWithCount({
    List<int>? genreIds,
    double? minRating,
    int? year,
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  });

  Future<WatchProviderResult> getWatchProviders(
    int mediaId,
    MediaType type, {
    String region = 'DE',
  });

  Future<List<Media>> getUpcomingMovies({
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  });

  Future<List<Media>> getUpcomingTvSeries({
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  });

  Future<String?> getTrailerUrl(int mediaId, MediaType type);

  Future<List<Media>> discoverByProvider({
    required List<int> providerIds,
    String region = 'DE',
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  });

  Future<Person> getPersonDetails(int personId);
  Future<List<PersonCredit>> getPersonCredits(int personId);

  Future<TvSeason> getTvSeasonDetails(int tvId, int seasonNumber);

  void clearCache();
}

class _CacheEntry<T> {
  final T data;
  final DateTime time;
  const _CacheEntry({required this.data, required this.time});
}

class TmdbRepository implements ITmdbRepository {
  final TmdbApiClient _apiClient;

  final Map<String, _CacheEntry<dynamic>> _cache = {};
  static const _cacheTtl = Duration(minutes: 5);

  TmdbRepository(this._apiClient);

  @override
  void clearCache() => _cache.clear();

  Future<T> _cachedFetch<T>(
    String cacheKey,
    Future<T> Function() fetcher,
  ) async {
    final cached = _cache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.time) < _cacheTtl) {
      return cached.data as T;
    }

    try {
      final result = await fetcher();
      _cache[cacheKey] = _CacheEntry<T>(data: result, time: DateTime.now());
      return result;
    } on TmdbException {
      if (cached != null) return cached.data as T;
      rethrow;
    }
  }

  @override
  Future<List<Media>> searchMulti(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? maxAgeRating,
  }) async {
    if (query.isEmpty) return [];
    final effectiveIncludeAdult =
        includeAdult || (maxAgeRating != null && maxAgeRating >= 21);
    final data = await _apiClient.searchMulti(
      query,
      page: page,
      includeAdult: effectiveIncludeAdult,
    );
    return _parseMediaResults(data);
  }

  @override
  Future<List<Media>> searchMovies(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? maxAgeRating,
  }) async {
    if (query.isEmpty) return [];
    final effectiveIncludeAdult =
        includeAdult || (maxAgeRating != null && maxAgeRating >= 21);
    final data = await _apiClient.searchMovies(
      query,
      page: page,
      includeAdult: effectiveIncludeAdult,
    );
    return _parseMediaList(data, MediaType.movie);
  }

  @override
  Future<List<Media>> searchTvSeries(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? maxAgeRating,
  }) async {
    if (query.isEmpty) return [];
    final effectiveIncludeAdult =
        includeAdult || (maxAgeRating != null && maxAgeRating >= 21);
    final data = await _apiClient.searchTvSeries(
      query,
      page: page,
      includeAdult: effectiveIncludeAdult,
    );
    return _parseMediaList(data, MediaType.tv);
  }

  @override
  Future<List<Media>> getTrending({
    MediaType? type,
    String timeWindow = 'week',
    int page = 1,
  }) async {
    final mediaPath = type?.tmdbPath ?? 'all';
    final cacheKey = 'trending_${mediaPath}_${timeWindow}_$page';

    return _cachedFetch(cacheKey, () async {
      final data = await _apiClient.getTrending(
        mediaPath,
        timeWindow,
        page: page,
      );
      return _parseMediaResults(data);
    });
  }

  @override
  Future<List<Media>> getPopularMovies({int page = 1}) async {
    return _cachedFetch('popular_movie_$page', () async {
      final data = await _apiClient.getPopular(
        MediaType.movie.tmdbPath,
        page,
        ApiConfig.defaultRegion,
      );
      return _parseMediaList(data, MediaType.movie);
    });
  }

  @override
  Future<List<Media>> getPopularTvSeries({int page = 1}) async {
    return _cachedFetch('popular_tv_$page', () async {
      final data = await _apiClient.getPopular(
        MediaType.tv.tmdbPath,
        page,
        null,
      );
      return _parseMediaList(data, MediaType.tv);
    });
  }

  @override
  Future<List<Media>> getTopRatedMovies({int page = 1}) async {
    return _cachedFetch('top_rated_movie_$page', () async {
      final data = await _apiClient.getTopRated(
        MediaType.movie.tmdbPath,
        page,
        ApiConfig.defaultRegion,
      );
      return _parseMediaList(data, MediaType.movie);
    });
  }

  @override
  Future<List<Media>> getTopRatedTvSeries({int page = 1}) async {
    return _cachedFetch('top_rated_tv_$page', () async {
      final data = await _apiClient.getTopRated(
        MediaType.tv.tmdbPath,
        page,
        null,
      );
      return _parseMediaList(data, MediaType.tv);
    });
  }

  @override
  Future<Media> getMovieDetails(int movieId) async {
    final data = await _apiClient.getMovieDetails(movieId);
    return Media.fromTmdbJson(data, MediaType.movie);
  }

  @override
  Future<Media> getTvDetails(int tvId) async {
    final data = await _apiClient.getTvDetails(tvId);
    return Media.fromTmdbJson(data, MediaType.tv);
  }

  @override
  Future<List<Media>> getSimilar(int mediaId, MediaType type) async {
    final data = await _apiClient.getSimilar(type.tmdbPath, mediaId);
    return _parseMediaList(data, type);
  }

  @override
  Future<List<Media>> getRecommendations(int mediaId, MediaType type) async {
    final data = await _apiClient.getRecommendations(type.tmdbPath, mediaId);
    return _parseMediaList(data, type);
  }

  @override
  Future<List<Media>> discoverMovies({
    List<int>? genreIds,
    double? minRating,
    int? year,
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  }) async {
    final result = await discoverMoviesWithCount(
      genreIds: genreIds,
      minRating: minRating,
      year: year,
      withProviders: withProviders,
      watchRegion: watchRegion,
      maxAgeRating: maxAgeRating,
      sortBy: sortBy,
      page: page,
      includeAdult: includeAdult,
    );
    return result.results;
  }

  @override
  Future<({List<Media> results, int totalResults})> discoverMoviesWithCount({
    List<int>? genreIds,
    double? minRating,
    int? year,
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  }) async {
    final region = watchRegion ?? ApiConfig.defaultRegion;
    final effectiveIncludeAdult =
        includeAdult || (maxAgeRating != null && maxAgeRating >= 21);

    final queryParams = <String, dynamic>{
      'page': page,
      'sort_by': sortBy,
      'include_adult': effectiveIncludeAdult,
      'region': region,
    };

    if (genreIds != null && genreIds.isNotEmpty) {
      queryParams['with_genres'] = genreIds.join(',');
    }
    if (minRating != null) queryParams['vote_average.gte'] = minRating;
    if (year != null) queryParams['primary_release_year'] = year;
    if (withProviders != null && withProviders.isNotEmpty) {
      queryParams['with_watch_providers'] = withProviders.join('|');
      queryParams['watch_region'] = region;
      queryParams['with_watch_monetization_types'] = 'flatrate|free';
    }

    if (maxAgeRating != null && maxAgeRating < 18) {
      final cert = AgeRatingMapper.getCertification(region, maxAgeRating);
      if (cert != null) {
        queryParams['certification_country'] = region;
        queryParams['certification.lte'] = cert;
      }
    }

    final data = await _apiClient.discoverMovies(queryParams);
    final results = _parseMediaList(data, MediaType.movie, region: region);
    final totalResults = data['total_results'] as int? ?? 0;

    return (results: results, totalResults: totalResults);
  }

  @override
  Future<List<Media>> discoverTvSeries({
    List<int>? genreIds,
    double? minRating,
    int? year,
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  }) async {
    final result = await discoverTvSeriesWithCount(
      genreIds: genreIds,
      minRating: minRating,
      year: year,
      withProviders: withProviders,
      watchRegion: watchRegion,
      maxAgeRating: maxAgeRating,
      sortBy: sortBy,
      page: page,
      includeAdult: includeAdult,
    );
    return result.results;
  }

  @override
  Future<({List<Media> results, int totalResults})> discoverTvSeriesWithCount({
    List<int>? genreIds,
    double? minRating,
    int? year,
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  }) async {
    final effectiveIncludeAdult =
        includeAdult || (maxAgeRating != null && maxAgeRating >= 21);

    final queryParams = <String, dynamic>{
      'page': page,
      'sort_by': sortBy,
      'include_adult': effectiveIncludeAdult,
    };

    if (genreIds != null && genreIds.isNotEmpty) {
      queryParams['with_genres'] = genreIds.join(',');
    }
    if (minRating != null) queryParams['vote_average.gte'] = minRating;
    if (year != null) queryParams['first_air_date_year'] = year;
    if (withProviders != null && withProviders.isNotEmpty) {
      queryParams['with_watch_providers'] = withProviders.join('|');
      queryParams['watch_region'] = watchRegion ?? ApiConfig.defaultRegion;
      queryParams['with_watch_monetization_types'] = 'flatrate|free';
    }

    if (maxAgeRating != null && maxAgeRating <= 12) {
      final safeGenres = [10762, 10751, 16];
      if (maxAgeRating <= 6) {
        queryParams['with_genres'] = safeGenres.join('|');
        queryParams['without_genres'] = '10768,18,80,27,99';
      } else {
        queryParams['without_genres'] = '10768,80,27';
      }
    }

    final data = await _apiClient.discoverTvSeries(queryParams);
    final results = _parseMediaList(data, MediaType.tv);
    final totalResults = data['total_results'] as int? ?? 0;

    return (results: results, totalResults: totalResults);
  }

  @override
  Future<WatchProviderResult> getWatchProviders(
    int mediaId,
    MediaType type, {
    String region = 'DE',
  }) async {
    final data = await _apiClient.getWatchProviders(type.tmdbPath, mediaId);
    final results = data['results'] as Map<String, dynamic>? ?? {};
    final regionData = results[region] as Map<String, dynamic>?;

    if (regionData == null) return WatchProviderResult.empty();
    return WatchProviderResult.fromJson(regionData);
  }

  @override
  Future<List<Media>> getUpcomingMovies({
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  }) async {
    final region = watchRegion ?? ApiConfig.defaultRegion;
    final now = DateTime.now();
    final futureDate = now.add(const Duration(days: 90));
    final effectiveIncludeAdult =
        includeAdult || (maxAgeRating != null && maxAgeRating >= 21);

    final queryParams = <String, dynamic>{
      'page': page,
      'sort_by': 'popularity.desc',
      'include_adult': effectiveIncludeAdult,
      'primary_release_date.gte':
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'primary_release_date.lte':
          '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}',
      'region': region,
    };

    if (minRating != null) queryParams['vote_average.gte'] = minRating;
    if (withProviders != null && withProviders.isNotEmpty) {
      queryParams['with_watch_providers'] = withProviders.join('|');
      queryParams['watch_region'] = region;
      queryParams['with_watch_monetization_types'] = 'flatrate|free';
    }

    if (maxAgeRating != null && maxAgeRating < 18) {
      final cert = AgeRatingMapper.getCertification(region, maxAgeRating);
      if (cert != null) {
        queryParams['certification_country'] = region;
        queryParams['certification.lte'] = cert;
      }
    }

    final data = await _apiClient.discoverMovies(queryParams);
    return _parseMediaList(data, MediaType.movie, region: region);
  }

  @override
  Future<List<Media>> getUpcomingTvSeries({
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  }) async {
    final now = DateTime.now();
    final futureDate = now.add(const Duration(days: 90));
    final effectiveIncludeAdult =
        includeAdult || (maxAgeRating != null && maxAgeRating >= 21);

    final queryParams = <String, dynamic>{
      'page': page,
      'sort_by': 'popularity.desc',
      'include_adult': effectiveIncludeAdult,
      'first_air_date.gte':
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'first_air_date.lte':
          '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}',
    };

    if (minRating != null) queryParams['vote_average.gte'] = minRating;
    if (withProviders != null && withProviders.isNotEmpty) {
      queryParams['with_watch_providers'] = withProviders.join('|');
      queryParams['watch_region'] = watchRegion ?? ApiConfig.defaultRegion;
      queryParams['with_watch_monetization_types'] = 'flatrate|free';
    }

    if (maxAgeRating != null && maxAgeRating <= 12) {
      final safeGenres = [10762, 10751, 16];
      if (maxAgeRating <= 6) {
        queryParams['with_genres'] = safeGenres.join('|');
        queryParams['without_genres'] = '10768,18,80,27,99';
      } else {
        queryParams['without_genres'] = '10768,80,27';
      }
    }

    final data = await _apiClient.discoverTvSeries(queryParams);
    return _parseMediaList(data, MediaType.tv);
  }

  @override
  Future<String?> getTrailerUrl(int mediaId, MediaType type) async {
    try {
      final data = await _apiClient.get('/${type.tmdbPath}/$mediaId/videos');
      final results = data['results'] as List<dynamic>? ?? [];

      for (final video in results) {
        if (video['site'] == 'YouTube' &&
            (video['type'] == 'Trailer' || video['type'] == 'Teaser')) {
          return 'https://www.youtube.com/watch?v=${video['key']}';
        }
      }
      return null;
    } on TmdbException {
      return null;
    }
  }

  @override
  Future<List<Media>> discoverByProvider({
    required List<int> providerIds,
    String region = 'DE',
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'sort_by': 'popularity.desc',
      'include_adult': includeAdult,
      'watch_region': region,
      'with_watch_providers': providerIds.join('|'),
      'with_watch_monetization_types': 'flatrate|free',
    };

    if (minRating != null) queryParams['vote_average.gte'] = minRating;

    final data = await _apiClient.discoverMovies(queryParams);
    return _parseMediaList(data, MediaType.movie, region: region);
  }

  @override
  Future<Person> getPersonDetails(int personId) async {
    return _cachedFetch('person_$personId', () async {
      final data = await _apiClient.getPersonDetails(personId);
      return Person.fromTmdbJson(data);
    });
  }

  @override
  Future<List<PersonCredit>> getPersonCredits(int personId) async {
    return _cachedFetch('person_credits_$personId', () async {
      final data = await _apiClient.getPersonCredits(personId);
      final castData = data['cast'] as List<dynamic>? ?? [];
      final crewData = data['crew'] as List<dynamic>? ?? [];

      final allCredits = <PersonCredit>[];

      for (final item in castData) {
        try {
          allCredits.add(
            PersonCredit.fromTmdbJson(item as Map<String, dynamic>),
          );
        } catch (_) {} // Skip invalid items
      }

      for (final item in crewData) {
        try {
          allCredits.add(
            PersonCredit.fromTmdbJson(item as Map<String, dynamic>),
          );
        } catch (_) {} // Skip invalid items
      }

      // Sort by popularity or release date
      return allCredits;
    });
  }

  @override
  Future<TvSeason> getTvSeasonDetails(int tvId, int seasonNumber) async {
    return _cachedFetch('tv_season_${tvId}_$seasonNumber', () async {
      final data = await _apiClient.getTvSeasonDetails(tvId, seasonNumber);
      return TvSeason.fromTmdbJson(tvId, data);
    });
  }

  List<Media> _parseMediaResults(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .where(
          (item) => item['media_type'] == 'movie' || item['media_type'] == 'tv',
        )
        .map((item) {
          final type = item['media_type'] == 'movie'
              ? MediaType.movie
              : MediaType.tv;
          return Media.fromTmdbJson(
            item,
            type,
            targetRegion: ApiConfig.defaultRegion,
          );
        })
        .toList();
  }

  List<Media> _parseMediaList(
    Map<String, dynamic> data,
    MediaType type, {
    String region = 'DE',
  }) {
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .map((item) => Media.fromTmdbJson(item, type, targetRegion: region))
        .toList();
  }
}
