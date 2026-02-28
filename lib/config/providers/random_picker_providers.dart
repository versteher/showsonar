import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/media.dart';
import '../providers.dart';

part 'random_picker_providers.g.dart';

// ============================================================================
// Random Picker Provider
// ============================================================================

/// Filter config for random picker
enum RandomPickerFilter { movies, series, both }

final randomPickerFilterProvider = StateProvider<RandomPickerFilter>(
  (ref) => RandomPickerFilter.both,
);

final randomPickerMinRatingProvider = StateProvider<double>((ref) => 6.0);

/// Fetches a random title matching the filters
@riverpod
Future<Media?> randomPickerResult(Ref ref) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final filter = ref.watch(randomPickerFilterProvider);
  final minRating = ref.watch(randomPickerMinRatingProvider);
  final providerIds = prefs.tmdbProviderIds;

  if (providerIds.isEmpty) return null;

  final random = Random();
  final randomPage = random.nextInt(5) + 1; // pages 1–5

  List<Media> pool = [];

  if (filter != RandomPickerFilter.series) {
    final movies = await tmdb.discoverMovies(
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      sortBy: 'popularity.desc',
      minRating: minRating,
      page: randomPage,
      maxAgeRating: prefs.maxAgeRating,
    );
    pool.addAll(movies);
  }

  if (filter != RandomPickerFilter.movies) {
    final series = await tmdb.discoverTvSeries(
      withProviders: providerIds,
      watchRegion: prefs.countryCode,
      sortBy: 'popularity.desc',
      minRating: minRating,
      page: randomPage,
      maxAgeRating: prefs.maxAgeRating,
    );
    pool.addAll(series);
  }

  if (pool.isEmpty) return null;
  pool.shuffle(random);
  return pool.first;
}
