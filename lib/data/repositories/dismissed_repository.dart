import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

/// Repository for managing dismissed/not-interested media items in Firestore.
class DismissedRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  DismissedRepository(this.userId, {FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('dismissedMedia');

  /// Initialize and perform one-time migration from Hive
  Future<void> init() async {
    if (userId == 'guest') return;

    const boxName = 'dismissed_media';
    if (await Hive.boxExists(boxName)) {
      final box = await Hive.openBox<String>(boxName);
      if (box.isNotEmpty) {
        final batch = _firestore.batch();
        for (final key in box.keys) {
          final docRef = _collection.doc(key.toString());
          batch.set(docRef, {'dismissedAt': FieldValue.serverTimestamp()});
        }
        await batch.commit();
        await box.clear();
      }
      await box.close();
      await Hive.deleteBoxFromDisk(boxName);
    }
  }

  /// Dismiss a media item (type_id format, e.g., "movie_123")
  Future<void> dismiss(String key) async {
    await _collection.doc(key).set({
      'dismissedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Check if a media item is dismissed
  Future<bool> isDismissed(String key) async {
    final doc = await _collection
        .doc(key)
        .get(const GetOptions(source: Source.cache));
    if (doc.exists) return true;
    final serverDoc = await _collection.doc(key).get();
    return serverDoc.exists;
  }

  /// Get all dismissed keys
  Future<Set<String>> getAllDismissed() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Undismiss a media item
  Future<void> undismiss(String key) async {
    await _collection.doc(key).delete();
  }

  /// Clear all dismissed items
  Future<void> clearAll() async {
    final snapshot = await _collection.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> close() async {}
}
