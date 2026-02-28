import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/models/app_profile.dart';
import 'package:stream_scout/data/repositories/profile_repository.dart';
import 'package:stream_scout/data/repositories/user_preferences_repository.dart';
import 'package:stream_scout/data/repositories/watch_history_repository.dart';
import 'package:stream_scout/data/repositories/watchlist_repository.dart';
import '../firebase_fallback.dart';

/// Repository for managing sub-profiles. Scoped to the current auth user.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final user = ref.watch(authStateProvider).value;
  return ProfileRepository(user?.uid ?? 'guest', firestore: firestoreInstance);
});

/// All profiles for the current user.
final profilesProvider = FutureProvider<List<AppProfile>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfiles();
});

/// The currently active profile ID. null = default (main) profile.
final activeProfileIdProvider = StateProvider<String?>((ref) => null);

/// Convenience: the active AppProfile object (or null for the main profile).
final activeProfileProvider = Provider<AppProfile?>((ref) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return null;

  final profilesAsync = ref.watch(profilesProvider);
  return profilesAsync.valueOrNull?.firstWhere(
    (p) => p.id == profileId,
    orElse: () =>
        AppProfile(id: profileId, name: 'Profile', createdAt: DateTime.now()),
  );
});

/// Profile-aware UserPreferencesRepository.
/// When a profile is active the path becomes users/{uid}/profiles/{pid}/preferences/current.
final profileAwarePreferencesRepositoryProvider =
    Provider<UserPreferencesRepository>((ref) {
      final user = ref.watch(authStateProvider).value;
      final profileId = ref.watch(activeProfileIdProvider);
      return UserPreferencesRepository(
        user?.uid ?? 'guest',
        profileId: profileId,
      );
    });

/// Profile-aware WatchHistoryRepository.
final profileAwareWatchHistoryRepositoryProvider =
    Provider<WatchHistoryRepository>((ref) {
      final user = ref.watch(authStateProvider).value;
      final profileId = ref.watch(activeProfileIdProvider);
      return WatchHistoryRepository(user?.uid ?? 'guest', profileId: profileId);
    });

/// Profile-aware WatchlistRepository.
final profileAwareWatchlistRepositoryProvider = Provider<WatchlistRepository>((
  ref,
) {
  final user = ref.watch(authStateProvider).value;
  final profileId = ref.watch(activeProfileIdProvider);
  return WatchlistRepository(user?.uid ?? 'guest', profileId: profileId);
});
