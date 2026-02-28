import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_scout/ui/screens/search_screen.dart';
import 'package:stream_scout/data/repositories/tmdb_repository.dart';
import 'package:stream_scout/data/repositories/user_preferences_repository.dart';
import 'package:stream_scout/data/repositories/watch_history_repository.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/test_app_wrapper.dart';

class MockTmdbRepository extends Mock implements ITmdbRepository {}

class MockPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

class MockWatchHistoryRepository extends Mock
    implements WatchHistoryRepository {}

void main() {
  late MockTmdbRepository mockTmdb;
  late MockPreferencesRepository mockPrefs;
  late MockWatchHistoryRepository mockWatchHistory;

  setUpAll(() {
    Animate.restartOnHotReload = true;
  });

  setUp(() {
    mockTmdb = MockTmdbRepository();
    mockPrefs = MockPreferencesRepository();
    mockWatchHistory = MockWatchHistoryRepository();

    when(() => mockPrefs.getPreferences()).thenAnswer(
      (_) async => const UserPreferences(
        countryCode: 'US',
        countryName: 'United States',
        subscribedServiceIds: [],
      ),
    );

    when(() => mockWatchHistory.getAllEntries()).thenAnswer((_) async => []);

    // Mock platform channels for SpeechToText
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugin.csdcorp.com/speech_to_text'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'initialize') {
              return true;
            }
            return null;
          },
        );
  });

  group('SearchScreen Widget Tests', () {
    testWidgets('renders search initial state empty view', (tester) async {
      // Set surface size to avoid rendering constraints errors for grid
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        pumpAppScreen(
          child: const SearchScreen(),
          overrides: [
            tmdbRepositoryProvider.overrideWithValue(mockTmdb),
            userPreferencesRepositoryProvider.overrideWithValue(mockPrefs),
            watchHistoryRepositoryProvider.overrideWithValue(mockWatchHistory),
            userPreferencesProvider.overrideWith(
              (ref) => Future.value(
                const UserPreferences(
                  countryCode: 'US',
                  countryName: 'United States',
                  subscribedServiceIds: [],
                ),
              ),
            ),
            searchResultsProvider.overrideWith((ref) => Future.value([])),
          ],
        ),
      );

      // SearchScreen might have a loading shimmer briefly or the search results provider could trigger its own load shimmer.
      // Avoid pumpAndSettle.
      await tester.pump(const Duration(milliseconds: 500));

      // Look for the search text field
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays search results when typed', (tester) async {
      // Set surface size to avoid rendering constraints errors for grid
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockSearchMedia = <Media>[
        Media(
          id: 11,
          title: 'Matrix',
          overview: 'Matrix Overview',
          posterPath: '/matrix.jpg',
          type: MediaType.movie,
          releaseDate: DateTime(1999),
          voteAverage: 8.7,
          voteCount: 5000,
          genreIds: [28, 878],
        ),
      ];

      when(
        () => mockTmdb.searchMulti(
          any(),
          page: any(named: 'page'),
          includeAdult: any(named: 'includeAdult'),
          maxAgeRating: any(named: 'maxAgeRating'),
        ),
      ).thenAnswer((_) async => mockSearchMedia);

      await tester.pumpWidget(
        pumpAppScreen(
          child: const SearchScreen(),
          overrides: [
            tmdbRepositoryProvider.overrideWithValue(mockTmdb),
            userPreferencesRepositoryProvider.overrideWithValue(mockPrefs),
            watchHistoryRepositoryProvider.overrideWithValue(mockWatchHistory),
            userPreferencesProvider.overrideWith(
              (ref) => Future.value(
                const UserPreferences(
                  countryCode: 'US',
                  countryName: 'United States',
                  subscribedServiceIds: [],
                ),
              ),
            ),
            searchResultsProvider.overrideWith(
              (ref) => Future.value(mockSearchMedia),
            ),
          ],
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Matrix');

      // Allow debounce to trigger
      await tester.pump(const Duration(milliseconds: 600));

      // Allow Riverpod and animations to finish layout
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // One for the TextField input, one for the MediaCard title
      expect(find.text('Matrix'), findsNWidgets(2));
    });
  });
}
