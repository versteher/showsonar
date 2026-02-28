part of 'tmdb_repository.dart';

extension _TmdbRepositorySearch on TmdbRepository {
  Future<List<Media>> _searchMulti(
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

  Future<List<Media>> _searchMovies(
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

  Future<List<Media>> _searchTvSeries(
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
}
