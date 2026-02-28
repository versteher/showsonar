import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_preferences.dart';
import '../data/services/tmdb_api_client.dart';
import '../data/services/gemini_service.dart';
import '../data/services/auth_service.dart';
import '../data/repositories/tmdb_repository.dart';
import '../data/repositories/user_preferences_repository.dart';
import '../data/repositories/watch_history_repository.dart';
import '../data/repositories/dismissed_repository.dart';
import '../data/repositories/local_preferences_repository.dart';
import '../domain/recommendation_engine.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/analytics_service.dart';
import 'firebase_fallback.dart';

// ============================================================================
// Barrel exports – all providers from sub-files
// ============================================================================
export 'providers/media_providers.dart';
export 'providers/media_discover_providers.dart';
export 'providers/media_detail_providers.dart';
export 'providers/watch_history_providers.dart';
export 'providers/watchlist_providers.dart';
export 'providers/mood_providers.dart';
export 'providers/streaming_providers.dart';
export 'providers/random_picker_providers.dart';
export 'providers/seasonal_providers.dart';
export 'providers/pagination_providers.dart';
export 'providers/notification_providers.dart';
export 'providers/remote_config_providers.dart';
export 'providers/social_providers.dart';
export 'providers/shared_watchlist_providers.dart';
export 'providers/profile_providers.dart';
export 'providers/episode_tracking_providers.dart';

// ============================================================================
// Core service & repository providers (kept here to avoid circular deps)
// ============================================================================

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for auth state
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for TMDB API Client
final tmdbApiClientProvider = Provider<TmdbApiClient>((ref) {
  return TmdbApiClient();
});

/// Provider for TMDB repository
final tmdbRepositoryProvider = Provider<ITmdbRepository>((ref) {
  final apiClient = ref.watch(tmdbApiClientProvider);
  return TmdbRepository(apiClient);
});

/// Provider for Gemini AI service
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

/// Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Provider for user preferences repository
final userPreferencesRepositoryProvider = Provider<UserPreferencesRepository>((
  ref,
) {
  final user = ref.watch(authStateProvider).value;
  return UserPreferencesRepository(
    user?.uid ?? 'guest',
    firestore: firestoreInstance,
  );
});

/// Provider for watch history repository
final watchHistoryRepositoryProvider = Provider<WatchHistoryRepository>((ref) {
  final user = ref.watch(authStateProvider).value;
  return WatchHistoryRepository(
    user?.uid ?? 'guest',
    firestore: firestoreInstance,
  );
});

/// Provider for dismissed (not interested) repository
final dismissedRepositoryProvider = Provider<DismissedRepository>((ref) {
  final user = ref.watch(authStateProvider).value;
  return DismissedRepository(
    user?.uid ?? 'guest',
    firestore: firestoreInstance,
  );
});

/// Provider for dismissed media IDs set (reactive)
final dismissedMediaIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(dismissedRepositoryProvider);
  await repo.init();
  return repo.getAllDismissed();
});

/// Provider for current user preferences (async)
final userPreferencesProvider = FutureProvider<UserPreferences>((ref) async {
  final repo = ref.watch(userPreferencesRepositoryProvider);
  await repo.init();
  return repo.getPreferences();
});

/// Provider for the recommendation engine
final recommendationEngineProvider = FutureProvider<RecommendationEngine>((
  ref,
) async {
  final tmdb = ref.watch(tmdbRepositoryProvider);
  final watchHistoryRepo = ref.watch(watchHistoryRepositoryProvider);
  final prefsAsync = await ref.watch(userPreferencesProvider.future);

  await watchHistoryRepo.init();

  return RecommendationEngine(
    tmdbRepository: tmdb,
    watchHistoryRepo: watchHistoryRepo,
    preferences: prefsAsync,
  );
});

/// Provider for local device preferences repository.
/// Must be overridden in ProviderScope with an initialized SharedPreferences instance.
final localPreferencesRepositoryProvider =
    Provider<LocalPreferencesRepository>((_) {
  throw UnimplementedError(
    'localPreferencesRepositoryProvider must be overridden with a SharedPreferences instance',
  );
});

/// Provider for theme mode state
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Try to load initial theme mode synchronously if possible, or default to dark.
  // We'll trust the initialization process to have opened the box.
  try {
    return ref.read(localPreferencesRepositoryProvider).themeMode;
  } catch (_) {
    return ThemeMode.dark;
  }
});

/// Initialize all repositories once at app startup.
/// Returns the [SharedPreferences] instance to be injected via ProviderScope.
Future<SharedPreferences> initializeRepositories() async {
  await Hive.initFlutter();

  // Pre-open Hive boxes needed for one-time Hive→Firestore migrations.
  // local_prefs is no longer stored in Hive (moved to shared_preferences).
  await Future.wait([
    Hive.openBox<String>('user_preferences'),
    Hive.openBox<String>('watch_history'),
    Hive.openBox<String>('watchlist'),
    Hive.openBox<String>('dismissed_media'),
  ]);

  return SharedPreferences.getInstance();
}

/// Provider for network connectivity state
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});
