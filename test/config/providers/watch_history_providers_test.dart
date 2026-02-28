import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/config/providers/watch_history_providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/watch_history_entry.dart';

import '../../utils/test_provider_container.dart';

void main() {
  late MockDependencies mocks;
  late ProviderContainer container;

  final testEntry = WatchHistoryEntry(
    mediaId: 1,
    mediaType: MediaType.movie,
    title: 'History Movie',
    posterPath: '/path.jpg',
    watchedAt: DateTime.now(),
    genreIds: [28],
    userRating: 8.0,
    completed: true,
  );

  setUp(() {
    mocks = MockDependencies();
    container = mocks.createContainer();

    when(() => mocks.watchHistoryRepository.init()).thenAnswer((_) async {});
  });

  tearDown(() {
    container.dispose();
  });

  group('Watch History Providers', () {
    test('watchHistoryEntriesProvider loads from repo', () async {
      when(
        () => mocks.watchHistoryRepository.getAllEntries(),
      ).thenAnswer((_) async => [testEntry]);

      final entries = await container.read(watchHistoryEntriesProvider.future);
      expect(entries.length, 1);
      expect(entries.first.title, 'History Movie');
    });

    test('watchedMediaIdsProvider generates unique key set', () async {
      when(
        () => mocks.watchHistoryRepository.getAllEntries(),
      ).thenAnswer((_) async => [testEntry]);

      final keys = await container.read(watchedMediaIdsProvider.future);
      expect(keys, contains('movie_1'));
    });

    test('isWatchedProvider interrogates repository', () async {
      when(
        () => mocks.watchHistoryRepository.hasWatched(1, MediaType.movie),
      ).thenAnswer((_) async => true);

      final isWatched = await container.read(
        isWatchedProvider((id: 1, type: MediaType.movie)).future,
      );
      expect(isWatched, isTrue);
    });

    test(
      'watchHistoryStatsProvider calculates frequencies and counts',
      () async {
        when(
          () => mocks.watchHistoryRepository.getAllEntries(),
        ).thenAnswer((_) async => [testEntry]);

        final stats = await container.read(watchHistoryStatsProvider.future);
        expect(stats.totalCount, 1);
        expect(stats.movieCount, 1);
        expect(stats.seriesCount, 0);
        expect(stats.averageRating, 8.0);
        expect(stats.topGenres.first, 28);
      },
    );
  });
}
