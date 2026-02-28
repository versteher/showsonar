import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/config/providers/watchlist_providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/watchlist_entry.dart';
import 'package:stream_scout/data/repositories/watchlist_repository.dart';

import '../../utils/test_provider_container.dart';

void main() {
  late MockDependencies mocks;
  late ProviderContainer container;

  final testEntry = WatchlistEntry(
    mediaId: 1,
    mediaType: MediaType.movie,
    title: 'Watchlist Movie',
    posterPath: '/path.jpg',
    addedAt: DateTime.now(),
  );

  setUp(() {
    mocks = MockDependencies();
    container = mocks.createContainer();
  });

  tearDown(() {
    container.dispose();
  });

  // Watchlist requires overriding its repo manually due to dynamic guest init logic
  group('Watchlist Providers', () {
    test('watchlistEntriesProvider loads from repo', () async {
      // Mock generic watchlist repo behavior rather than internal user creation logic
      final mockRepo = MockWatchlistRepository();
      when(() => mockRepo.init()).thenAnswer((_) async {});
      when(() => mockRepo.getAllEntries()).thenAnswer((_) async => [testEntry]);

      final localContainer = mocks.createContainer(
        overrides: [watchlistRepositoryProvider.overrideWithValue(mockRepo)],
      );

      final entries = await localContainer.read(
        watchlistEntriesProvider.future,
      );
      expect(entries.length, 1);
      expect(entries.first.title, 'Watchlist Movie');
    });

    test('isOnWatchlistProvider returns repo status', () async {
      final mockRepo = MockWatchlistRepository();
      when(() => mockRepo.init()).thenAnswer((_) async {});
      when(
        () => mockRepo.isOnWatchlist(1, MediaType.movie),
      ).thenAnswer((_) async => true);

      final localContainer = mocks.createContainer(
        overrides: [watchlistRepositoryProvider.overrideWithValue(mockRepo)],
      );

      final isListed = await localContainer.read(
        isOnWatchlistProvider((id: 1, type: MediaType.movie)).future,
      );
      expect(isListed, isTrue);
    });
  });
}

class MockWatchlistRepository extends Mock implements WatchlistRepository {}
