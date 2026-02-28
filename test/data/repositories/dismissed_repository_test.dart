import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stream_scout/data/repositories/dismissed_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DismissedRepository repo;
  const userId = 'guest';

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    repo = DismissedRepository(userId, firestore: fakeFirestore);
    await repo.init();
  });

  group('DismissedRepository', () {
    group('dismiss / isDismissed', () {
      test('dismissed item returns true', () async {
        await repo.dismiss('movie_550');
        expect(await repo.isDismissed('movie_550'), isTrue);
      });

      test('non-dismissed item returns false', () async {
        expect(await repo.isDismissed('movie_999'), isFalse);
      });

      test('different key formats work', () async {
        await repo.dismiss('tv_1399');
        expect(await repo.isDismissed('tv_1399'), isTrue);
        expect(await repo.isDismissed('movie_1399'), isFalse);
      });
    });

    group('getAllDismissed', () {
      test('returns empty set when nothing dismissed', () async {
        expect(await repo.getAllDismissed(), isEmpty);
      });

      test('returns all dismissed keys', () async {
        await repo.dismiss('movie_1');
        await repo.dismiss('movie_2');
        await repo.dismiss('tv_3');

        final all = await repo.getAllDismissed();
        expect(all.length, 3);
        expect(all, containsAll(['movie_1', 'movie_2', 'tv_3']));
      });

      test('dismissing same key twice does not duplicate', () async {
        await repo.dismiss('movie_1');
        await repo.dismiss('movie_1');

        final all = await repo.getAllDismissed();
        expect(all.length, 1);
      });
    });

    group('undismiss', () {
      test('removes a dismissed item', () async {
        await repo.dismiss('movie_550');
        expect(await repo.isDismissed('movie_550'), isTrue);

        await repo.undismiss('movie_550');
        expect(await repo.isDismissed('movie_550'), isFalse);
      });

      test('undismissing non-existent key is safe', () async {
        await repo.undismiss('movie_999');
        expect(await repo.isDismissed('movie_999'), isFalse);
      });
    });

    group('clearAll', () {
      test('removes all dismissed items', () async {
        await repo.dismiss('movie_1');
        await repo.dismiss('movie_2');
        await repo.dismiss('tv_3');
        expect((await repo.getAllDismissed()).length, 3);

        await repo.clearAll();
        expect(await repo.getAllDismissed(), isEmpty);
      });

      test('clearing empty repo is safe', () async {
        await repo.clearAll();
        expect(await repo.getAllDismissed(), isEmpty);
      });
    });

    group('lazy init', () {
      test('calling init multiple times is safe', () async {
        await repo.init();
        await repo.init();
        await repo.dismiss('movie_1');
        expect(await repo.isDismissed('movie_1'), isTrue);
      });
    });
  });
}
