import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/media.dart';
import '../../data/models/watchlist_entry.dart';
import '../../data/repositories/watchlist_repository.dart';
import '../providers.dart';
import '../firebase_fallback.dart';

part 'watchlist_providers.g.dart';

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
@riverpod
Future<List<WatchlistEntry>> watchlistEntries(Ref ref) async {
  final repo = ref.watch(watchlistRepositoryProvider);
  await repo.init();
  return repo.getAllEntries();
}

/// Provider to check if a specific media is on the watchlist
@riverpod
Future<bool> isOnWatchlist(
  Ref ref, {
  required int id,
  required MediaType type,
}) async {
  final repo = ref.watch(watchlistRepositoryProvider);
  await repo.init();
  return repo.isOnWatchlist(id, type);
}

/// Provider for set of watchlist media IDs (for fast lookup)
@riverpod
Future<Set<String>> watchlistMediaIds(Ref ref) async {
  final entries = await ref.watch(watchlistEntriesProvider.future);
  return entries.map((e) => e.uniqueKey).toSet();
}
