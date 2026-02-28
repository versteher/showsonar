import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/repositories/shared_watchlist_repository.dart';

void main() {
  group('SharedWatchlistRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SharedWatchlistRepository repo;

    const uidOwner = 'owner_uid';
    const uidGuest = 'guest_uid';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repo = SharedWatchlistRepository(
        firestore: fakeFirestore,
        currentUid: uidOwner,
      );
    });

    test(
      'createWatchlist creates a Firestore document with correct fields',
      () async {
        final listId = await repo.createWatchlist('Movie Night');
        expect(listId, isNotEmpty);

        final doc = await fakeFirestore
            .collection('sharedLists')
            .doc(listId)
            .get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['name'], equals('Movie Night'));
        expect(doc.data()!['ownerId'], equals(uidOwner));
        final sharedWith = List<String>.from(doc.data()!['sharedWithUids']);
        expect(sharedWith, contains(uidOwner));
      },
    );

    test('getSharedWatchlists streams lists where user is a member', () async {
      await repo.createWatchlist('Action Picks');

      final stream = repo.getSharedWatchlists();
      final lists = await stream.first;
      expect(lists.length, equals(1));
      expect(lists.first.name, equals('Action Picks'));
    });

    test('inviteUser adds uid to sharedWithUids', () async {
      final listId = await repo.createWatchlist('Shared Night');
      await repo.inviteUser(listId, uidGuest);

      final doc = await fakeFirestore
          .collection('sharedLists')
          .doc(listId)
          .get();
      final sharedWith = List<String>.from(doc.data()!['sharedWithUids']);
      expect(sharedWith, containsAll([uidOwner, uidGuest]));
    });

    test('removeUser removes uid from sharedWithUids', () async {
      final listId = await repo.createWatchlist('Test List');
      await repo.inviteUser(listId, uidGuest);
      await repo.removeUser(listId, uidGuest);

      final doc = await fakeFirestore
          .collection('sharedLists')
          .doc(listId)
          .get();
      final sharedWith = List<String>.from(doc.data()!['sharedWithUids']);
      expect(sharedWith, isNot(contains(uidGuest)));
    });

    test('addMedia inserts mediaId into mediaIds list', () async {
      final listId = await repo.createWatchlist('Watchlist');
      await repo.addMedia(listId, 'movie_123');

      final doc = await fakeFirestore
          .collection('sharedLists')
          .doc(listId)
          .get();
      final mediaIds = List<String>.from(doc.data()!['mediaIds']);
      expect(mediaIds, contains('movie_123'));
    });

    test('removeMedia removes mediaId from mediaIds list', () async {
      final listId = await repo.createWatchlist('Watchlist');
      await repo.addMedia(listId, 'movie_123');
      await repo.removeMedia(listId, 'movie_123');

      final doc = await fakeFirestore
          .collection('sharedLists')
          .doc(listId)
          .get();
      final mediaIds = List<String>.from(doc.data()!['mediaIds']);
      expect(mediaIds, isNot(contains('movie_123')));
    });

    test('updateWatchlistName changes the name', () async {
      final listId = await repo.createWatchlist('Old Name');
      await repo.updateWatchlistName(listId, 'New Name');

      final doc = await fakeFirestore
          .collection('sharedLists')
          .doc(listId)
          .get();
      expect(doc.data()!['name'], equals('New Name'));
    });

    test('deleteWatchlist removes the document', () async {
      final listId = await repo.createWatchlist('To Delete');
      await repo.deleteWatchlist(listId);

      final doc = await fakeFirestore
          .collection('sharedLists')
          .doc(listId)
          .get();
      expect(doc.exists, isFalse);
    });
  });
}
