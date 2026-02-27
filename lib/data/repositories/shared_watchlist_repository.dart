import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shared_watchlist.dart';

class SharedWatchlistRepository {
  final FirebaseFirestore _firestore;
  final String _currentUid;

  SharedWatchlistRepository({
    FirebaseFirestore? firestore,
    required String currentUid,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _currentUid = currentUid;

  Stream<List<SharedWatchlist>> getSharedWatchlists() {
    return _firestore
        .collection('sharedLists')
        .where('sharedWithUids', arrayContains: _currentUid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => SharedWatchlist.fromJson(
                  _normalizeData({...doc.data(), 'id': doc.id}),
                ),
              )
              .toList(),
        );
  }

  Future<SharedWatchlist?> getWatchlist(String listId) async {
    final doc = await _firestore.collection('sharedLists').doc(listId).get();
    if (!doc.exists) return null;
    return SharedWatchlist.fromJson(
      _normalizeData({...doc.data()!, 'id': doc.id}),
    );
  }

  Future<String> createWatchlist(String name) async {
    final docRef = _firestore.collection('sharedLists').doc();
    final now = DateTime.now();

    final list = SharedWatchlist(
      id: docRef.id,
      ownerId: _currentUid,
      name: name,
      sharedWithUids: [_currentUid],
      mediaIds: [],
      createdAt: now,
      updatedAt: now,
    );

    final data = list.toJson()..remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);
    return docRef.id;
  }

  Future<void> deleteWatchlist(String listId) async {
    await _firestore.collection('sharedLists').doc(listId).delete();
  }

  Future<void> updateWatchlistName(String listId, String newName) async {
    await _firestore.collection('sharedLists').doc(listId).update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> inviteUser(String listId, String targetUid) async {
    await _firestore.collection('sharedLists').doc(listId).update({
      'sharedWithUids': FieldValue.arrayUnion([targetUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeUser(String listId, String targetUid) async {
    await _firestore.collection('sharedLists').doc(listId).update({
      'sharedWithUids': FieldValue.arrayRemove([targetUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addMedia(String listId, String mediaId) async {
    await _firestore.collection('sharedLists').doc(listId).update({
      'mediaIds': FieldValue.arrayUnion([mediaId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeMedia(String listId, String mediaId) async {
    await _firestore.collection('sharedLists').doc(listId).update({
      'mediaIds': FieldValue.arrayRemove([mediaId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Converts Firestore Timestamps to ISO 8601 strings for JSON deserialization.
  Map<String, dynamic> _normalizeData(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      }
      return MapEntry(key, value);
    });
  }
}
