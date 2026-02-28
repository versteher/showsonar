part of 'tmdb_repository.dart';

extension _TmdbRepositoryDetails on TmdbRepository {
  Future<Media> _getMovieDetails(int movieId) async {
    final data = await _apiClient.getMovieDetails(movieId);
    return Media.fromTmdbJson(data, MediaType.movie);
  }

  Future<Media> _getTvDetails(int tvId) async {
    final data = await _apiClient.getTvDetails(tvId);
    return Media.fromTmdbJson(data, MediaType.tv);
  }

  Future<List<Media>> _getSimilar(int mediaId, MediaType type) async {
    final data = await _apiClient.getSimilar(type.tmdbPath, mediaId);
    return _parseMediaList(data, type);
  }

  Future<List<Media>> _getRecommendations(int mediaId, MediaType type) async {
    final data = await _apiClient.getRecommendations(type.tmdbPath, mediaId);
    return _parseMediaList(data, type);
  }

  Future<Person> _getPersonDetails(int personId) {
    return _cachedFetch('person_$personId', () async {
      final data = await _apiClient.getPersonDetails(personId);
      return Person.fromTmdbJson(data);
    });
  }

  Future<List<PersonCredit>> _getPersonCredits(int personId) {
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

  Future<TvSeason> _getTvSeasonDetails(int tvId, int seasonNumber) {
    return _cachedFetch('tv_season_${tvId}_$seasonNumber', () async {
      final data = await _apiClient.getTvSeasonDetails(tvId, seasonNumber);
      return TvSeason.fromTmdbJson(tvId, data);
    });
  }
}
