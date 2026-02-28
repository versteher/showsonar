import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/watch_history_entry.dart';
import 'package:stream_scout/data/models/watchlist_entry.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:stream_scout/data/repositories/dismissed_repository.dart';
import 'package:stream_scout/data/repositories/local_preferences_repository.dart';
import 'package:stream_scout/data/repositories/tmdb_repository.dart';
import 'package:stream_scout/data/repositories/user_preferences_repository.dart';
import 'package:stream_scout/data/repositories/watch_history_repository.dart';
import 'package:stream_scout/data/repositories/watchlist_repository.dart';
import 'package:stream_scout/utils/analytics_service.dart';
import 'package:stream_scout/utils/notification_service.dart';
import 'package:stream_scout/utils/remote_config_service.dart';

class MockTmdbRepository extends Mock implements ITmdbRepository {}

class MockUserPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

class MockWatchHistoryRepository extends Mock
    implements WatchHistoryRepository {}

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

class MockDismissedRepository extends Mock implements DismissedRepository {}

class MockLocalPreferencesRepository extends Mock
    implements LocalPreferencesRepository {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockNotificationService extends Mock implements NotificationService {}

final mockMedia = Media(
  id: 1,
  title: 'Integration Test Movie',
  overview: 'This is a mock movie for testing.',
  voteAverage: 8.5,
  voteCount: 1000,
  genreIds: [28, 12],
  type: MediaType.movie,
);

class FakeMedia extends Fake implements Media {}

class FakeUserPreferences extends Fake implements UserPreferences {}

class FakeWatchHistoryEntry extends Fake implements WatchHistoryEntry {}

class FakeWatchlistEntry extends Fake implements WatchlistEntry {}

List<Override> getIntegrationTestOverrides() {
  registerFallbackValue(FakeMedia());
  registerFallbackValue(FakeUserPreferences());
  registerFallbackValue(FakeWatchHistoryEntry());
  registerFallbackValue(FakeWatchlistEntry());
  registerFallbackValue(ThemeMode.system);
  registerFallbackValue(MediaType.movie);

  final tmdbRepository = MockTmdbRepository();
  final userPreferencesRepository = MockUserPreferencesRepository();
  final watchHistoryRepository = MockWatchHistoryRepository();
  final watchlistRepository = MockWatchlistRepository();
  final dismissedRepository = MockDismissedRepository();
  final localPreferencesRepository = MockLocalPreferencesRepository();
  final remoteConfigService = MockRemoteConfigService();
  final analyticsService = MockAnalyticsService();

  when(() => analyticsService.logScreenView(any())).thenAnswer((_) async {});
  when(() => analyticsService.logEvent(any())).thenAnswer((_) async {});
  when(
    () =>
        analyticsService.logEvent(any(), parameters: any(named: 'parameters')),
  ).thenAnswer((_) async {});
  final notificationService = MockNotificationService();

  // Setup tmdbRepository mocks
  when(
    () => tmdbRepository.getTrending(
      type: any(named: 'type'),
      timeWindow: any(named: 'timeWindow'),
      page: any(named: 'page'),
    ),
  ).thenAnswer((_) async => [mockMedia]);

  when(
    () => tmdbRepository.searchMulti(
      any(),
      page: any(named: 'page'),
      includeAdult: any(named: 'includeAdult'),
      maxAgeRating: any(named: 'maxAgeRating'),
    ),
  ).thenAnswer((_) async => [mockMedia.copyWith(title: 'Search Result Movie')]);

  when(
    () => tmdbRepository.getMovieDetails(any()),
  ).thenAnswer((_) async => mockMedia);

  when(
    () => tmdbRepository.getTvDetails(any()),
  ).thenAnswer((_) async => mockMedia);

  when(
    () => tmdbRepository.discoverMovies(
      withProviders: any(named: 'withProviders'),
      watchRegion: any(named: 'watchRegion'),
      sortBy: any(named: 'sortBy'),
      maxAgeRating: any(named: 'maxAgeRating'),
      minRating: any(named: 'minRating'),
      page: any(named: 'page'),
    ),
  ).thenAnswer((_) async => [mockMedia]);

  when(
    () => tmdbRepository.discoverTvSeries(
      withProviders: any(named: 'withProviders'),
      watchRegion: any(named: 'watchRegion'),
      sortBy: any(named: 'sortBy'),
      maxAgeRating: any(named: 'maxAgeRating'),
      minRating: any(named: 'minRating'),
      page: any(named: 'page'),
    ),
  ).thenAnswer(
    (_) async => [
      mockMedia.copyWith(id: 2, title: 'Mock TV Show', type: MediaType.tv),
    ],
  );

  when(
    () => tmdbRepository.getWatchProviders(
      any(),
      any(),
      region: any(named: 'region'),
    ),
  ).thenAnswer(
    (_) async => const WatchProviderResult(
      flatrate: [
        WatchProvider(
          providerId: 8,
          name: 'Netflix',
          logoPath: '/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg',
        ),
      ],
      rent: [],
      buy: [],
    ),
  );

  // User preferences
  when(() => userPreferencesRepository.init()).thenAnswer((_) async {});
  when(
    () => userPreferencesRepository.getPreferences(),
  ).thenAnswer((_) async => UserPreferences.defaultDE());
  when(
    () => userPreferencesRepository.savePreferences(any()),
  ).thenAnswer((_) async {});

  // Watch History
  when(() => watchHistoryRepository.init()).thenAnswer((_) async {});
  when(
    () => watchHistoryRepository.getAllEntries(),
  ).thenAnswer((_) async => []);
  final mockEntry = WatchHistoryEntry(
    mediaId: mockMedia.id,
    mediaType: mockMedia.type,
    title: mockMedia.title,
    posterPath: mockMedia.posterPath,
    watchedAt: DateTime.now(),
  );

  when(
    () => watchHistoryRepository.markAsWatched(
      any(),
      rating: any(named: 'rating'),
    ),
  ).thenAnswer((_) async => mockEntry);

  when(
    () => watchHistoryRepository.updateEntry(any()),
  ).thenAnswer((_) async {});

  when(
    () => watchHistoryRepository.addToHistory(any()),
  ).thenAnswer((_) async {});

  // Watchlist
  when(() => watchlistRepository.init()).thenAnswer((_) async {});
  when(() => watchlistRepository.getAllEntries()).thenAnswer((_) async => []);
  final mockWatchlistEntry = WatchlistEntry(
    mediaId: mockMedia.id,
    mediaType: mockMedia.type,
    title: mockMedia.title,
    posterPath: mockMedia.posterPath,
    addedAt: DateTime.now(),
  );

  when(
    () => watchlistRepository.addMedia(any()),
  ).thenAnswer((_) async => mockWatchlistEntry);
  when(
    () => watchlistRepository.removeFromWatchlist(any(), any()),
  ).thenAnswer((_) async {});

  // Dismissed
  when(() => dismissedRepository.init()).thenAnswer((_) async {});
  when(
    () => dismissedRepository.isDismissed(any()),
  ).thenAnswer((_) async => false);

  // Local preferences (mock hasSeenOnboarding = false to show onboarding, then stateful)
  bool mockHasSeenOnboarding = false;
  when(
    () => localPreferencesRepository.hasSeenOnboarding,
  ).thenAnswer((_) => mockHasSeenOnboarding);
  when(() => localPreferencesRepository.setHasSeenOnboarding(any())).thenAnswer(
    (invocation) async {
      mockHasSeenOnboarding = invocation.positionalArguments[0] as bool;
    },
  );
  when(() => localPreferencesRepository.themeMode).thenReturn(ThemeMode.dark);
  when(
    () => localPreferencesRepository.setThemeMode(any()),
  ).thenAnswer((_) async {});

  // Remote config and notifications
  when(() => remoteConfigService.enableSocial).thenReturn(false);
  when(() => remoteConfigService.enableWidgets).thenReturn(false);
  when(() => remoteConfigService.initialize()).thenAnswer((_) async {});
  when(() => notificationService.initialize()).thenAnswer((_) async {});

  return [
    tmdbRepositoryProvider.overrideWithValue(tmdbRepository),
    userPreferencesRepositoryProvider.overrideWithValue(
      userPreferencesRepository,
    ),
    watchHistoryRepositoryProvider.overrideWithValue(watchHistoryRepository),
    watchlistRepositoryProvider.overrideWithValue(watchlistRepository),
    dismissedRepositoryProvider.overrideWithValue(dismissedRepository),
    localPreferencesRepositoryProvider.overrideWithValue(
      localPreferencesRepository,
    ),
    remoteConfigServiceProvider.overrideWithValue(remoteConfigService),
    analyticsServiceProvider.overrideWithValue(analyticsService),
    notificationServiceProvider.overrideWithValue(notificationService),

    // Simulate logged-in user to bypass login screen
    authStateProvider.overrideWith((ref) => Stream.value(MockUser())),
  ];
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'mock_uid_123';
}
