import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
import '../../data/models/watchlist_entry.dart';
import '../../data/repositories/watchlist_repository.dart';
import '../providers.dart';
import '../firebase_fallback.dart';

// ============================================================================
// Watchlist Providers
// ============================================================================

/// Provider for watchlist repository
final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  final user = ref.watch(authStateProvider).value;
  return WatchlistRepository(
    user?.uid ?? 'guest',
    firestore: firestoreInstance,
  );
});

/// Provider for all watchlist entries (reactive)
final watchlistEntriesProvider = FutureProvider<List<WatchlistEntry>>((
  ref,
) async {
  final repo = ref.watch(watchlistRepositoryProvider);
  await repo.init();
  return repo.getAllEntries();
});

/// Provider to check if a specific media is on the watchlist
final isOnWatchlistProvider =
    FutureProvider.family<bool, ({int id, MediaType type})>((
      ref,
      params,
    ) async {
      final repo = ref.watch(watchlistRepositoryProvider);
      await repo.init();
      return repo.isOnWatchlist(params.id, params.type);
    });

/// Provider for set of watchlist media IDs (for fast lookup)
final watchlistMediaIdsProvider = FutureProvider<Set<String>>((ref) async {
  final entries = await ref.watch(watchlistEntriesProvider.future);
  return entries.map((e) => e.uniqueKey).toSet();
});
