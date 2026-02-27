import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/services/auth_service.dart';
import 'package:neon_voyager/data/services/tmdb_api_client.dart';
import 'package:neon_voyager/data/services/gemini_service.dart';
import 'package:neon_voyager/data/repositories/tmdb_repository.dart';
import 'package:neon_voyager/data/repositories/user_preferences_repository.dart';
import 'package:neon_voyager/data/repositories/watch_history_repository.dart';
import 'package:neon_voyager/data/repositories/watchlist_repository.dart';
import 'package:neon_voyager/data/repositories/dismissed_repository.dart';
import 'package:neon_voyager/data/repositories/local_preferences_repository.dart';
import 'package:neon_voyager/utils/remote_config_service.dart';
import 'package:neon_voyager/utils/notification_service.dart';

// Mocks
class MockAuthService extends Mock implements AuthService {}

class MockTmdbApiClient extends Mock implements TmdbApiClient {}

class MockTmdbRepository extends Mock implements ITmdbRepository {}

class MockGeminiService extends Mock implements GeminiService {}

class MockUserPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

class MockWatchHistoryRepository extends Mock
    implements WatchHistoryRepository {}

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

class MockDismissedRepository extends Mock implements DismissedRepository {}

class MockLocalPreferencesRepository extends Mock
    implements LocalPreferencesRepository {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockNotificationService extends Mock implements NotificationService {}

/// A helper class to hold all mocked dependencies for testing providers
class MockDependencies {
  final authService = MockAuthService();
  final tmdbApiClient = MockTmdbApiClient();
  final tmdbRepository = MockTmdbRepository();
  final geminiService = MockGeminiService();
  final userPreferencesRepository = MockUserPreferencesRepository();
  final watchHistoryRepository = MockWatchHistoryRepository();
  final watchlistRepository = MockWatchlistRepository();
  final dismissedRepository = MockDismissedRepository();
  final localPreferencesRepository = MockLocalPreferencesRepository();
  final remoteConfigService = MockRemoteConfigService();
  final notificationService = MockNotificationService();

  MockDependencies() {
    // Setup sensible defaults for core methods often called during initialization
    when(() => userPreferencesRepository.init()).thenAnswer((_) async {});
    when(() => watchHistoryRepository.init()).thenAnswer((_) async {});
    when(() => watchlistRepository.init()).thenAnswer((_) async {});
    when(() => dismissedRepository.init()).thenAnswer((_) async {});

    when(() => remoteConfigService.enableSocial).thenReturn(false);
    when(() => remoteConfigService.enableWidgets).thenReturn(false);
  }

  /// Creates a ProviderContainer with all base dependencies overridden with these mocks.
  ProviderContainer createContainer({List<Override> overrides = const []}) {
    return ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        tmdbApiClientProvider.overrideWithValue(tmdbApiClient),
        tmdbRepositoryProvider.overrideWithValue(tmdbRepository),
        geminiServiceProvider.overrideWithValue(geminiService),
        userPreferencesRepositoryProvider.overrideWithValue(
          userPreferencesRepository,
        ),
        watchHistoryRepositoryProvider.overrideWithValue(
          watchHistoryRepository,
        ),
        watchlistRepositoryProvider.overrideWithValue(watchlistRepository),
        dismissedRepositoryProvider.overrideWithValue(dismissedRepository),
        localPreferencesRepositoryProvider.overrideWithValue(
          localPreferencesRepository,
        ),
        remoteConfigServiceProvider.overrideWithValue(remoteConfigService),
        notificationServiceProvider.overrideWithValue(notificationService),
        ...overrides,
      ],
    );
  }
}
