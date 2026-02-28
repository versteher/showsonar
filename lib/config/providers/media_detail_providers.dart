import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
import '../../data/models/person.dart';
import '../providers.dart';

/// Provider for movie/series details
final mediaDetailsProvider =
    FutureProvider.family<Media, ({int id, MediaType type})>((
      ref,
      params,
    ) async {
      final tmdb = ref.watch(tmdbRepositoryProvider);

      if (params.type == MediaType.movie) {
        return tmdb.getMovieDetails(params.id);
      } else {
        return tmdb.getTvDetails(params.id);
      }
    });

/// Provider for similar content
final similarContentProvider =
    FutureProvider.family<List<Media>, ({int id, MediaType type})>((
      ref,
      params,
    ) async {
      final tmdb = ref.watch(tmdbRepositoryProvider);
      return tmdb.getSimilar(params.id, params.type);
    });

/// Provider for recommendations based on specific media
final mediaRecommendationsProvider =
    FutureProvider.family<List<Media>, ({int id, MediaType type})>((
      ref,
      params,
    ) async {
      final tmdb = ref.watch(tmdbRepositoryProvider);
      return tmdb.getRecommendations(params.id, params.type);
    });

/// Provider for actor/director details
final personDetailsProvider = FutureProvider.family<Person, int>((
  ref,
  personId,
) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  return tmdb.getPersonDetails(personId);
});

/// Provider for actor/director filmography credits
final personCreditsProvider = FutureProvider.family<List<PersonCredit>, int>((
  ref,
  personId,
) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  return tmdb.getPersonCredits(personId);
});
