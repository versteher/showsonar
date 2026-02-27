import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/shared_watchlist_repository.dart';
import '../../data/models/shared_watchlist.dart';
import '../providers.dart';
import '../firebase_fallback.dart';

final sharedWatchlistRepositoryProvider = Provider<SharedWatchlistRepository>((
  ref,
) {
  final user = ref.watch(authStateProvider).value;
  return SharedWatchlistRepository(
    currentUid: user?.uid ?? 'guest',
    firestore: firestoreInstance,
  );
});

final sharedWatchlistsProvider = StreamProvider<List<SharedWatchlist>>((ref) {
  final repo = ref.watch(sharedWatchlistRepositoryProvider);
  return repo.getSharedWatchlists();
});

final sharedWatchlistProvider = FutureProvider.family<SharedWatchlist?, String>(
  (ref, listId) async {
    final repo = ref.watch(sharedWatchlistRepositoryProvider);
    return repo.getWatchlist(listId);
  },
);
