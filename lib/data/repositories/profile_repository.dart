import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/app_profile.dart';

/// Repository for managing sub-profiles under a user account.
/// Firestore path: users/{uid}/profiles/{profileId}
class ProfileRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  ProfileRepository(this.userId, {FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('profiles');

  /// Returns all profiles for this user, sorted by creation date.
  Future<List<AppProfile>> getProfiles() async {
    final snapshot = await _collection.orderBy('createdAt').get();
    return snapshot.docs
        .map((doc) => AppProfile.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Creates a new profile. Generates a UUID for the id.
  Future<AppProfile> createProfile({
    required String name,
    String avatarEmoji = '🎬',
  }) async {
    final rand = Random().nextInt(999999).toString().padLeft(6, '0');
    final id = '${DateTime.now().millisecondsSinceEpoch}_$rand';
    final profile = AppProfile(
      id: id,
      name: name,
      avatarEmoji: avatarEmoji,
      createdAt: DateTime.now(),
    );
    await _collection.doc(id).set(profile.toJson());
    return profile;
  }

  /// Updates an existing profile's mutable fields.
  Future<void> updateProfile(AppProfile profile) async {
    await _collection
        .doc(profile.id)
        .set(profile.toJson(), SetOptions(merge: true));
  }

  /// Deletes a profile document. Does NOT delete sub-collections (watchlist etc.)
  /// — Firestore sub-collection cleanup is handled by a Cloud Function on deletion.
  Future<void> deleteProfile(String profileId) async {
    await _collection.doc(profileId).delete();
  }

  /// Returns a single profile by id, or null if not found.
  Future<AppProfile?> getProfile(String profileId) async {
    final doc = await _collection.doc(profileId).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppProfile.fromJson({...doc.data()!, 'id': doc.id});
  }
}
