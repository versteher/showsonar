import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/activity_feed_item.dart';

class SocialRepository {
  final FirebaseFirestore _firestore;
  final String _currentUid;

  SocialRepository({FirebaseFirestore? firestore, required String currentUid})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _currentUid = currentUid;

  // Search users by name (prefix match)
  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();

    final snapshot = await _firestore
        .collection('users')
        .where('displayNameLowercase', isGreaterThanOrEqualTo: lowerQuery)
        .where('displayNameLowercase', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => UserProfile.fromJson({...doc.data(), 'uid': doc.id}))
        .where((user) => user.uid != _currentUid)
        .toList();
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromJson({...doc.data()!, 'uid': doc.id});
  }

  // Check if following
  Stream<bool> isFollowing(String targetUid) {
    return _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('following')
        .doc(targetUid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // Follow a user
  Future<void> followUser(String targetUid) async {
    final batch = _firestore.batch();

    // Add to current user's following list
    final followingRef = _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('following')
        .doc(targetUid);
    batch.set(followingRef, {'timestamp': FieldValue.serverTimestamp()});

    // Add to target user's followers list
    final followerRef = _firestore
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(_currentUid);
    batch.set(followerRef, {'timestamp': FieldValue.serverTimestamp()});

    // Increment counts
    final currentUserRef = _firestore.collection('users').doc(_currentUid);
    batch.update(currentUserRef, {'followingCount': FieldValue.increment(1)});

    final targetUserRef = _firestore.collection('users').doc(targetUid);
    batch.update(targetUserRef, {'followersCount': FieldValue.increment(1)});

    await batch.commit();
  }

  // Unfollow a user
  Future<void> unfollowUser(String targetUid) async {
    final batch = _firestore.batch();

    final followingRef = _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('following')
        .doc(targetUid);
    batch.delete(followingRef);

    final followerRef = _firestore
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(_currentUid);
    batch.delete(followerRef);

    final currentUserRef = _firestore.collection('users').doc(_currentUid);
    batch.update(currentUserRef, {'followingCount': FieldValue.increment(-1)});

    final targetUserRef = _firestore.collection('users').doc(targetUid);
    batch.update(targetUserRef, {'followersCount': FieldValue.increment(-1)});

    await batch.commit();
  }

  // Get following list
  Future<List<UserProfile>> getFollowing() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('following')
        .get();

    final uids = snapshot.docs.map((doc) => doc.id).toList();
    if (uids.isEmpty) return [];

    final profiles = <UserProfile>[];
    for (var i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(
        i,
        i + 10 > uids.length ? uids.length : i + 10,
      );
      final profilesSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      profiles.addAll(
        profilesSnapshot.docs.map(
          (doc) => UserProfile.fromJson({...doc.data(), 'uid': doc.id}),
        ),
      );
    }

    return profiles;
  }

  // Get activity feed (simplified fan-out)
  Stream<List<ActivityFeedItem>> getActivityFeed() {
    return _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('feed')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    ActivityFeedItem.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  Future<void> postActivity(ActivityFeedItem activity) async {
    final activityData = activity.toJson()..remove('id');

    if (activityData['timestamp'] is String) {
      activityData['timestamp'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('activities')
        .add(activityData);
  }
}
