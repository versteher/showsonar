import '../data/models/media.dart';
import '../data/models/user_preferences.dart';
import '../data/models/genre.dart';
import '../data/repositories/tmdb_repository.dart';
import '../data/repositories/watch_history_repository.dart';

/// Intelligent recommendation engine that combines watch history,
/// ratings, genres, and streaming availability to suggest content
class RecommendationEngine {
  final ITmdbRepository _tmdbRepository;
  final WatchHistoryRepository _watchHistoryRepo;
  final UserPreferences _preferences;

  RecommendationEngine({
    required ITmdbRepository tmdbRepository,
    required WatchHistoryRepository watchHistoryRepo,
    required UserPreferences preferences,
  }) : _tmdbRepository = tmdbRepository,
       _watchHistoryRepo = watchHistoryRepo,
       _preferences = preferences;

  /// Get personalized recommendations based on watch history
  Future<List<Media>> getPersonalizedRecommendations({int limit = 20}) async {
    final watchHistory = await _watchHistoryRepo.getAllEntries();

    if (watchHistory.isEmpty) {
      // No history, return trending content
      return _getTrendingForNewUser(limit);
    }

    // Get recommendations based on highly rated watched content
    final recommendations = <Media>[];
    final seenIds = <String>{};

    // Mark all watched items as seen
    for (final entry in watchHistory) {
      seenIds.add('${entry.mediaType.name}_${entry.mediaId}');
    }

    // Get recommendations from top rated watched items
    final topRated = watchHistory
        .where((e) => e.userRating != null && e.userRating! >= 7.0)
        .take(5)
        .toList();

    for (final entry in topRated) {
      try {
        final similar = await _tmdbRepository.getRecommendations(
          entry.mediaId,
          entry.mediaType,
        );

        for (final media in similar) {
          final key = '${media.type.name}_${media.id}';
          if (!seenIds.contains(key) && _passesFilters(media)) {
            seenIds.add(key);
            recommendations.add(media);
          }
        }
      } catch (_) {
        // Skip if API call fails
      }
    }

    // If not enough recommendations, add based on favorite genres
    if (recommendations.length < limit) {
      final genreBasedRecs = await _getGenreBasedRecommendations(
        seenIds,
        limit - recommendations.length,
      );
      recommendations.addAll(genreBasedRecs);
    }

    // Sort by rating and return top results
    recommendations.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
    return recommendations.take(limit).toList();
  }

  /// Get recommendations for a new user (no watch history)
  Future<List<Media>> _getTrendingForNewUser(int limit) async {
    try {
      final trending = await _tmdbRepository.getTrending();
      return trending.where(_passesFilters).take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get recommendations based on genre preferences
  Future<List<Media>> _getGenreBasedRecommendations(
    Set<String> seenIds,
    int limit,
  ) async {
    final recommendations = <Media>[];

    // Get top genres from watch history
    final topGenres = await _getTopGenresFromHistory();

    if (topGenres.isEmpty) {
      // Use user's explicit favorite genres
      final favoriteGenres = _preferences.favoriteGenreIds;
      if (favoriteGenres.isNotEmpty) {
        topGenres.addAll(favoriteGenres.take(3));
      }
    }

    if (topGenres.isEmpty) return [];

    try {
      // Discover movies with top genres
      final movies = await _tmdbRepository.discoverMovies(
        genreIds: topGenres,
        minRating: _preferences.minimumRating,
      );

      for (final movie in movies) {
        final key = '${movie.type.name}_${movie.id}';
        if (!seenIds.contains(key) && _passesFilters(movie)) {
          seenIds.add(key);
          recommendations.add(movie);
          if (recommendations.length >= limit) break;
        }
      }

      // Also get TV series if needed
      if (recommendations.length < limit) {
        final tvSeries = await _tmdbRepository.discoverTvSeries(
          genreIds: topGenres,
          minRating: _preferences.minimumRating,
        );

        for (final tv in tvSeries) {
          final key = '${tv.type.name}_${tv.id}';
          if (!seenIds.contains(key) && _passesFilters(tv)) {
            seenIds.add(key);
            recommendations.add(tv);
            if (recommendations.length >= limit) break;
          }
        }
      }
    } catch (_) {
      // Skip if API call fails
    }

    return recommendations;
  }

  /// Get top genres from watch history based on genre frequency in entries
  Future<List<int>> _getTopGenresFromHistory() async {
    final entries = await _watchHistoryRepo.getAllEntries();
    final genreFreq = <int, int>{};
    for (final entry in entries) {
      for (final g in entry.genreIds) {
        genreFreq[g] = (genreFreq[g] ?? 0) + 1;
      }
    }
    final sorted = genreFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
  }

  /// Check if media passes user's filter criteria
  bool _passesFilters(Media media) {
    // Check minimum rating
    if (media.voteAverage < _preferences.minimumRating) {
      return false;
    }

    // Check if enough votes (avoid obscure content)
    if (media.voteCount < 100) {
      return false;
    }

    // Check age rating
    if (_preferences.maxAgeRating < 18) {
      if (media.ageLevel > _preferences.maxAgeRating) {
        return false;
      }
    }

    return true;
  }

  /// Get "Because you watched X" recommendations
  Future<List<RecommendationGroup>> getBecauseYouWatched({
    int groupLimit = 3,
  }) async {
    final groups = <RecommendationGroup>[];
    final allEntries = await _watchHistoryRepo.getAllEntries();
    final watchHistory = allEntries.take(10).toList();

    // Get highly rated recent watches
    final recentRated = watchHistory
        .where((e) => e.userRating != null && e.userRating! >= 7.0)
        .take(groupLimit)
        .toList();

    for (final entry in recentRated) {
      try {
        final recommendations = await _tmdbRepository.getRecommendations(
          entry.mediaId,
          entry.mediaType,
        );

        final filtered = recommendations
            .where(_passesFilters)
            .take(10)
            .toList();

        if (filtered.isNotEmpty) {
          groups.add(
            RecommendationGroup(
              title: 'Weil du "${entry.title}" gesehen hast',
              reason: RecommendationReason.becauseYouWatched,
              sourceMediaId: entry.mediaId,
              items: filtered,
            ),
          );
        }
      } catch (_) {
        // Skip failed lookups
      }
    }

    return groups;
  }

  /// Get recommendations by genre
  Future<List<RecommendationGroup>> getByGenre({int genreLimit = 4}) async {
    final groups = <RecommendationGroup>[];
    final topGenres = await _getTopGenresFromHistory();

    // Fall back to popular genres if no history
    final genresToUse = topGenres.isNotEmpty
        ? topGenres
        : [28, 35, 18, 878]; // Action, Comedy, Drama, Sci-Fi

    for (final genreId in genresToUse.take(genreLimit)) {
      final genre = Genre.fromId(genreId);
      if (genre == null) continue;

      try {
        final movies = await _tmdbRepository.discoverMovies(
          genreIds: [genreId],
          minRating: _preferences.minimumRating,
        );

        final filtered = movies.where(_passesFilters).take(10).toList();

        if (filtered.isNotEmpty) {
          groups.add(
            RecommendationGroup(
              title: genre.name,
              reason: RecommendationReason.genre,
              items: filtered,
            ),
          );
        }
      } catch (_) {
        // Skip failed lookups
      }
    }

    return groups;
  }

  /// Get top rated content
  Future<RecommendationGroup> getTopRated({MediaType? type}) async {
    try {
      List<Media> items;
      String title;

      if (type == MediaType.movie) {
        items = await _tmdbRepository.getTopRatedMovies();
        title = 'Top bewertete Filme';
      } else if (type == MediaType.tv) {
        items = await _tmdbRepository.getTopRatedTvSeries();
        title = 'Top bewertete Serien';
      } else {
        final movies = await _tmdbRepository.getTopRatedMovies();
        final tv = await _tmdbRepository.getTopRatedTvSeries();
        items = [...movies.take(10), ...tv.take(10)]
          ..sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
        title = 'Top bewertet';
      }

      return RecommendationGroup(
        title: title,
        reason: RecommendationReason.topRated,
        items: items.where(_passesFilters).take(20).toList(),
      );
    } catch (e) {
      return RecommendationGroup(
        title: 'Top bewertet',
        reason: RecommendationReason.topRated,
        items: [],
      );
    }
  }

  /// Get trending content
  Future<RecommendationGroup> getTrending() async {
    try {
      final items = await _tmdbRepository.getTrending();
      return RecommendationGroup(
        title: 'Gerade im Trend',
        reason: RecommendationReason.trending,
        items: items.where(_passesFilters).take(20).toList(),
      );
    } catch (_) {
      return RecommendationGroup(
        title: 'Gerade im Trend',
        reason: RecommendationReason.trending,
        items: [],
      );
    }
  }
}

/// A group of recommended media with a title and reason
class RecommendationGroup {
  final String title;
  final RecommendationReason reason;
  final int? sourceMediaId;
  final List<Media> items;

  const RecommendationGroup({
    required this.title,
    required this.reason,
    this.sourceMediaId,
    required this.items,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

/// Reasons for recommendations
enum RecommendationReason {
  becauseYouWatched,
  genre,
  topRated,
  trending,
  popular,
  similar,
}
