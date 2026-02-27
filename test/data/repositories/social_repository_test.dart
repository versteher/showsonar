import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/repositories/social_repository.dart';

void main() {
  group('SocialRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SocialRepository repoA;

    const uidA = 'user_a';
    const uidB = 'user_b';

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      repoA = SocialRepository(firestore: fakeFirestore, currentUid: uidA);

      // Seed user profiles
      await fakeFirestore.collection('users').doc(uidA).set({
        'displayName': 'Alice',
        'displayNameLowercase': 'alice',
        'followersCount': 0,
        'followingCount': 0,
      });
      await fakeFirestore.collection('users').doc(uidB).set({
        'displayName': 'Bob',
        'displayNameLowercase': 'bob',
        'followersCount': 0,
        'followingCount': 0,
      });
    });

    test('searchUsers returns matching profiles excluding self', () async {
      final results = await repoA.searchUsers('bob');
      expect(results.length, equals(1));
      expect(results.first.uid, equals(uidB));
      expect(results.first.displayName, equals('Bob'));
    });

    test('searchUsers returns empty list for empty query', () async {
      final results = await repoA.searchUsers('');
      expect(results, isEmpty);
    });

    test('getUserProfile returns correct profile', () async {
      final profile = await repoA.getUserProfile(uidB);
      expect(profile, isNotNull);
      expect(profile!.displayName, equals('Bob'));
    });

    test('getUserProfile returns null for non-existent user', () async {
      final profile = await repoA.getUserProfile('nonexistent');
      expect(profile, isNull);
    });

    test('followUser creates following and follower documents', () async {
      await repoA.followUser(uidB);

      final followingDoc = await fakeFirestore
          .collection('users')
          .doc(uidA)
          .collection('following')
          .doc(uidB)
          .get();
      expect(followingDoc.exists, isTrue);

      final followerDoc = await fakeFirestore
          .collection('users')
          .doc(uidB)
          .collection('followers')
          .doc(uidA)
          .get();
      expect(followerDoc.exists, isTrue);
    });

    test('unfollowUser removes following and follower documents', () async {
      await repoA.followUser(uidB);
      await repoA.unfollowUser(uidB);

      final followingDoc = await fakeFirestore
          .collection('users')
          .doc(uidA)
          .collection('following')
          .doc(uidB)
          .get();
      expect(followingDoc.exists, isFalse);

      final followerDoc = await fakeFirestore
          .collection('users')
          .doc(uidB)
          .collection('followers')
          .doc(uidA)
          .get();
      expect(followerDoc.exists, isFalse);
    });

    test('isFollowing stream emits true after follow', () async {
      final stream = repoA.isFollowing(uidB);

      // Initially false
      expect(await stream.first, isFalse);

      await repoA.followUser(uidB);

      expect(await repoA.isFollowing(uidB).first, isTrue);
    });

    test('getFollowing returns profiles after following', () async {
      await repoA.followUser(uidB);
      final following = await repoA.getFollowing();
      expect(following.length, equals(1));
      expect(following.first.uid, equals(uidB));
    });
  });
}
