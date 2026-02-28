import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stream_scout/data/repositories/user_preferences_repository.dart';
import 'package:stream_scout/data/repositories/watchlist_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  final tempDir = Directory.systemTemp.createTempSync('hive_test');

  setUpAll(() {
    Hive.init(tempDir.path);
  });

  tearDownAll(() {
    tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
  });

  tearDown(() async {
    await Hive.close();
  });

  group('Hive to Firestore Migration', () {
    test(
      'guest user does not trigger migration and box is unmodified',
      () async {
        final box = await Hive.openBox<String>('watchlist');
        await box.put(
          'movie_123',
          jsonEncode({
            'mediaId': 123,
            'mediaType': 'movie',
            'title': 'Test',
            'addedAt': DateTime.now().toIso8601String(),
            'genreIds': [],
          }),
        );
        await box.close();

        final repo = WatchlistRepository('guest', firestore: fakeFirestore);
        await repo.init();

        expect(await Hive.boxExists('watchlist'), isTrue);
        final snapshot = await fakeFirestore
            .collection('users')
            .doc('guest')
            .collection('watchlist')
            .get();
        expect(snapshot.docs.isEmpty, isTrue);

        // Cleanup
        await Hive.deleteBoxFromDisk('watchlist');
      },
    );

    test(
      'authenticated user migrates data to Firestore and deletes Hive box',
      () async {
        final box = await Hive.openBox<String>('watchlist');
        await box.put(
          'movie_123',
          jsonEncode({
            'mediaId': 123,
            'mediaType': 'movie',
            'title': 'Test Movie',
            'addedAt': DateTime.now().toIso8601String(),
            'genreIds': [],
          }),
        );
        await box.close();

        final repo = WatchlistRepository(
          'real_user_id',
          firestore: fakeFirestore,
        );
        await repo.init();

        expect(await Hive.boxExists('watchlist'), isFalse);

        final snapshot = await fakeFirestore
            .collection('users')
            .doc('real_user_id')
            .collection('watchlist')
            .get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.id, 'movie_123');
        expect(snapshot.docs.first.data()['title'], 'Test Movie');
      },
    );

    test('authenticated user Preferences migration works', () async {
      final box = await Hive.openBox<String>('user_preferences');
      await box.put(
        'prefs',
        jsonEncode({
          'countryCode': 'GB',
          'countryName': 'United Kingdom',
          'subscribedServiceIds': [],
          'favoriteGenreIds': [],
        }),
      );
      await box.close();

      final repo = UserPreferencesRepository(
        'real_user_id',
        firestore: fakeFirestore,
      );
      await repo.init();

      expect(await Hive.boxExists('user_preferences'), isFalse);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('real_user_id')
          .collection('preferences')
          .doc('current')
          .get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['countryCode'], 'GB');
    });
  });
}
