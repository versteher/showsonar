import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
import '../../utils/media_filter.dart';
import '../providers.dart';

// ============================================================================
// Curated Collection Providers
// ============================================================================

/// Available curated collections
enum CuratedCollection {
  criticallyAcclaimed(
    '⭐ Critically Acclaimed',
    'Kritiker-Lieblinge',
    28,
  ), // IMDb Top 250 (Example list ID 28)
  perfectForTonight(
    '🌙 Perfect for Tonight',
    'Perfekt für heute Abend',
    112870,
  ), // Example TMDB list for "Tonight"
  bingeWorthy(
    '📺 Binge-Worthy',
    'Serien-Marathon',
    114569,
  ), // Example TMDB list for Bingeable TV
  modernClassics(
    '🏆 Modern Classics',
    'Moderne Klassiker',
    15,
  ); // Example TMDB list for Modern Classics

  final String labelEn;
  final String labelDe;
  final int listId;
  const CuratedCollection(this.labelEn, this.labelDe, this.listId);
}

/// Currently selected collection
final selectedCollectionProvider = StateProvider<CuratedCollection>(
  (ref) => CuratedCollection.criticallyAcclaimed,
);

/// Provider for curated collection content
final curatedCollectionProvider = FutureProvider<List<Media>>((ref) async {
  final collection = ref.watch(selectedCollectionProvider);
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final prefs = await ref.watch(userPreferencesProvider.future);
  final providerIds = prefs.tmdbProviderIds;

  // Wait for the requested list
  final items = await tmdb.getList(collection.listId);

  // Still apply local viewing preferences (age rating, region filters, etc.)
  final filtered = MediaFilter.applyPreferences(items, prefs);

  if (providerIds.isNotEmpty) {
    // For lists, we must do a local check on watch providers if we want to restrict
    // because TMDB's /list endpoint doesn't support with_watch_providers directly.
    // To avoid massive N+1 queries, we'll optimistically return the filtered list
    // or do a lightweight intersection. For now, just return filtered to keep it fast.
  }

  return filtered.take(20).toList();
});
