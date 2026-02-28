import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/media.dart';
import '../../data/models/person.dart';
import '../providers.dart';

part 'media_detail_providers.g.dart';

/// Provider for movie/series details
@riverpod
Future<Media> mediaDetails(
  Ref ref, {
  required int id,
  required MediaType type,
}) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);

  if (type == MediaType.movie) {
    return tmdb.getMovieDetails(id);
  } else {
    return tmdb.getTvDetails(id);
  }
}

/// Provider for similar content
@riverpod
Future<List<Media>> similarContent(
  Ref ref, {
  required int id,
  required MediaType type,
}) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  return tmdb.getSimilar(id, type);
}

/// Provider for recommendations based on specific media
@riverpod
Future<List<Media>> mediaRecommendations(
  Ref ref, {
  required int id,
  required MediaType type,
}) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  return tmdb.getRecommendations(id, type);
}

/// Provider for actor/director details
@riverpod
Future<Person> personDetails(Ref ref, int personId) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  return tmdb.getPersonDetails(personId);
}

/// Provider for actor/director filmography credits
@riverpod
Future<List<PersonCredit>> personCredits(Ref ref, int personId) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  return tmdb.getPersonCredits(personId);
}
