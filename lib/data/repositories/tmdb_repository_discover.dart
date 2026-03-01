part of 'tmdb_repository.dart';

extension _TmdbRepositoryDiscover on TmdbRepository {
  Future<({List<Media> results, int totalResults})> _discoverMoviesWithCount({
    List<int>? genreIds,
    List<int>? withoutGenreIds,
    GenreFilterMode genreMode = GenreFilterMode.and,
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
      final sep = genreMode == GenreFilterMode.or ? '|' : ',';
      queryParams['with_genres'] = genreIds.join(sep);
    }
    if (withoutGenreIds != null && withoutGenreIds.isNotEmpty) {
      queryParams['without_genres'] = withoutGenreIds.join(',');
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

  Future<({List<Media> results, int totalResults})> _discoverTvSeriesWithCount({
    List<int>? genreIds,
    List<int>? withoutGenreIds,
    GenreFilterMode genreMode = GenreFilterMode.and,
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
      final sep = genreMode == GenreFilterMode.or ? '|' : ',';
      queryParams['with_genres'] = genreIds.join(sep);
    }
    if (minRating != null) queryParams['vote_average.gte'] = minRating;
    if (year != null) queryParams['first_air_date_year'] = year;
    if (withProviders != null && withProviders.isNotEmpty) {
      queryParams['with_watch_providers'] = withProviders.join('|');
      queryParams['watch_region'] = watchRegion ?? ApiConfig.defaultRegion;
      queryParams['with_watch_monetization_types'] = 'flatrate|free';
    }

    // Collect all excluded genre IDs (caller + age-rating based)
    final allExcluded = <int>{...?withoutGenreIds};

    if (maxAgeRating != null && maxAgeRating <= 12) {
      final safeGenres = [10762, 10751, 16];
      if (maxAgeRating <= 6) {
        queryParams['with_genres'] = safeGenres.join('|');
        allExcluded.addAll([10768, 18, 80, 27, 99]);
      } else {
        allExcluded.addAll([10768, 80, 27]);
      }
    }

    if (allExcluded.isNotEmpty) {
      queryParams['without_genres'] = allExcluded.join(',');
    }

    final data = await _apiClient.discoverTvSeries(queryParams);
    final results = _parseMediaList(data, MediaType.tv);
    final totalResults = data['total_results'] as int? ?? 0;

    return (results: results, totalResults: totalResults);
  }

  Future<List<Media>> _discoverByProvider({
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

  Future<WatchProviderResult> _getWatchProviders(
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

  Future<List<Media>> _getUpcomingMovies({
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

  Future<List<Media>> _getUpcomingTvSeries({
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

  Future<String?> _getTrailerUrl(int mediaId, MediaType type) async {
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
}
