import '../models/media.dart';
import '../models/person.dart';
import '../models/tv_season.dart';
import '../../utils/age_rating_mapper.dart';
import '../../config/api_config.dart';
import '../services/tmdb_api_client.dart';

part 'tmdb_repository_search.dart';
part 'tmdb_repository_discover.dart';
part 'tmdb_repository_details.dart';

// ---------------------------------------------------------------------------
// Value types
// ---------------------------------------------------------------------------

/// Controls how genre IDs are joined in the TMDB `with_genres` parameter.
/// `and` uses comma (all genres must match), `or` uses pipe (any genre matches).
enum GenreFilterMode { and, or }

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

// ---------------------------------------------------------------------------
// Interface
// ---------------------------------------------------------------------------

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
    List<int>? withoutGenreIds,
    GenreFilterMode genreMode = GenreFilterMode.and,
    double? minRating,
    int? year,
    List<int>? withProviders,
    List<int>? withKeywords,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  });

  Future<({List<Media> results, int totalResults})> discoverMoviesWithCount({
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
  });

  Future<List<Media>> discoverTvSeries({
    List<int>? genreIds,
    List<int>? withoutGenreIds,
    GenreFilterMode genreMode = GenreFilterMode.and,
    double? minRating,
    int? year,
    List<int>? withProviders,
    List<int>? withKeywords,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  });

  Future<({List<Media> results, int totalResults})> discoverTvSeriesWithCount({
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

  Future<List<Media>> getList(int listId);

  void clearCache();
}

// ---------------------------------------------------------------------------
// Internal cache helper
// ---------------------------------------------------------------------------

class _CacheEntry<T> {
  final T data;
  final DateTime time;
  const _CacheEntry({required this.data, required this.time});
}

// ---------------------------------------------------------------------------
// Concrete implementation
// ---------------------------------------------------------------------------

class TmdbRepository implements ITmdbRepository {
  final TmdbApiClient _apiClient;

  final Map<String, _CacheEntry<dynamic>> _cache = {};
  static const _cacheTtl = Duration(minutes: 5);

  TmdbRepository(this._apiClient);

  @override
  void clearCache() => _cache.clear();

  // ---- Private helpers shared by all part files --------------------------

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

  // ---- Core: trending, popular, top-rated --------------------------------

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

  // ---- Delegates to part files -------------------------------------------

  // Search (tmdb_repository_search.dart)

  @override
  Future<List<Media>> searchMulti(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? maxAgeRating,
  }) => _searchMulti(
    query,
    page: page,
    includeAdult: includeAdult,
    maxAgeRating: maxAgeRating,
  );

  @override
  Future<List<Media>> searchMovies(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? maxAgeRating,
  }) => _searchMovies(
    query,
    page: page,
    includeAdult: includeAdult,
    maxAgeRating: maxAgeRating,
  );

  @override
  Future<List<Media>> searchTvSeries(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? maxAgeRating,
  }) => _searchTvSeries(
    query,
    page: page,
    includeAdult: includeAdult,
    maxAgeRating: maxAgeRating,
  );

  // Details (tmdb_repository_details.dart)

  @override
  Future<Media> getMovieDetails(int movieId) => _getMovieDetails(movieId);

  @override
  Future<Media> getTvDetails(int tvId) => _getTvDetails(tvId);

  @override
  Future<List<Media>> getSimilar(int mediaId, MediaType type) =>
      _getSimilar(mediaId, type);

  @override
  Future<List<Media>> getRecommendations(int mediaId, MediaType type) =>
      _getRecommendations(mediaId, type);

  @override
  Future<Person> getPersonDetails(int personId) => _getPersonDetails(personId);

  @override
  Future<List<PersonCredit>> getPersonCredits(int personId) =>
      _getPersonCredits(personId);

  @override
  Future<TvSeason> getTvSeasonDetails(int tvId, int seasonNumber) =>
      _getTvSeasonDetails(tvId, seasonNumber);

  // Discover / providers / upcoming / trailer (tmdb_repository_discover.dart)

  @override
  Future<List<Media>> discoverMovies({
    List<int>? genreIds,
    List<int>? withoutGenreIds,
    GenreFilterMode genreMode = GenreFilterMode.and,
    double? minRating,
    int? year,
    List<int>? withProviders,
    List<int>? withKeywords,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  }) async {
    final result = await _discoverMoviesWithCount(
      genreIds: genreIds,
      withoutGenreIds: withoutGenreIds,
      genreMode: genreMode,
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
  }) => _discoverMoviesWithCount(
    genreIds: genreIds,
    withoutGenreIds: withoutGenreIds,
    genreMode: genreMode,
    minRating: minRating,
    year: year,
    withProviders: withProviders,
    watchRegion: watchRegion,
    maxAgeRating: maxAgeRating,
    sortBy: sortBy,
    page: page,
    includeAdult: includeAdult,
  );

  @override
  Future<List<Media>> discoverTvSeries({
    List<int>? genreIds,
    List<int>? withoutGenreIds,
    GenreFilterMode genreMode = GenreFilterMode.and,
    double? minRating,
    int? year,
    List<int>? withProviders,
    List<int>? withKeywords,
    String? watchRegion,
    int? maxAgeRating,
    String sortBy = 'popularity.desc',
    int page = 1,
    bool includeAdult = false,
  }) async {
    final result = await _discoverTvSeriesWithCount(
      genreIds: genreIds,
      withoutGenreIds: withoutGenreIds,
      genreMode: genreMode,
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
  }) => _discoverTvSeriesWithCount(
    genreIds: genreIds,
    withoutGenreIds: withoutGenreIds,
    genreMode: genreMode,
    minRating: minRating,
    year: year,
    withProviders: withProviders,
    watchRegion: watchRegion,
    maxAgeRating: maxAgeRating,
    sortBy: sortBy,
    page: page,
    includeAdult: includeAdult,
  );

  @override
  Future<List<Media>> discoverByProvider({
    required List<int> providerIds,
    String region = 'DE',
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  }) => _discoverByProvider(
    providerIds: providerIds,
    region: region,
    minRating: minRating,
    page: page,
    includeAdult: includeAdult,
  );

  @override
  Future<WatchProviderResult> getWatchProviders(
    int mediaId,
    MediaType type, {
    String region = 'DE',
  }) => _getWatchProviders(mediaId, type, region: region);

  @override
  Future<List<Media>> getUpcomingMovies({
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  }) => _getUpcomingMovies(
    withProviders: withProviders,
    watchRegion: watchRegion,
    maxAgeRating: maxAgeRating,
    minRating: minRating,
    page: page,
    includeAdult: includeAdult,
  );

  @override
  Future<List<Media>> getUpcomingTvSeries({
    List<int>? withProviders,
    String? watchRegion,
    int? maxAgeRating,
    double? minRating,
    int page = 1,
    bool includeAdult = false,
  }) => _getUpcomingTvSeries(
    withProviders: withProviders,
    watchRegion: watchRegion,
    maxAgeRating: maxAgeRating,
    minRating: minRating,
    page: page,
    includeAdult: includeAdult,
  );

  @override
  Future<String?> getTrailerUrl(int mediaId, MediaType type) =>
      _getTrailerUrl(mediaId, type);

  @override
  Future<List<Media>> getList(int listId) => _getList(listId);
}
