import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/watchlist_entry.dart';
import '../models/media.dart';

/// Repository for managing the user's watchlist in Firestore.
/// When [profileId] is provided, the watchlist is stored in a profile sub-collection.
class WatchlistRepository {
  final String userId;
  final String? profileId;
  final FirebaseFirestore _firestore;

  WatchlistRepository(
    this.userId, {
    this.profileId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    if (profileId != null) {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId)
          .collection('watchlist');
    }
    return _firestore.collection('users').doc(userId).collection('watchlist');
  }

  /// Initialize the repository and run one-time Hive migration
  Future<void> init() async {
    if (userId == 'guest') return;

    const boxName = 'watchlist';
    if (await Hive.boxExists(boxName)) {
      final box = await Hive.openBox<String>(boxName);
      if (box.isNotEmpty) {
        final batch = _firestore.batch();
        for (final key in box.keys) {
          final jsonStr = box.get(key);
          if (jsonStr != null) {
            final entryMap = jsonDecode(jsonStr);
            final docRef = _collection.doc(key.toString());
            batch.set(docRef, entryMap);
          }
        }
        await batch.commit();
        await box.clear();
      }
      await box.close();
      await Hive.deleteBoxFromDisk(boxName);
    }
  }

  /// Add media to watchlist
  Future<void> addToWatchlist(WatchlistEntry entry) async {
    await _collection.doc(entry.uniqueKey).set(entry.toJson());
  }

  /// Create entry from Media and add to watchlist
  Future<WatchlistEntry> addMedia(Media media) async {
    final entry = WatchlistEntry.fromMedia(media);
    await addToWatchlist(entry);
    return entry;
  }

  /// Update an existing entry
  Future<void> updateEntry(WatchlistEntry entry) async {
    await _collection
        .doc(entry.uniqueKey)
        .set(entry.toJson(), SetOptions(merge: true));
  }

  /// Remove entry from watchlist
  Future<void> removeFromWatchlist(int mediaId, MediaType type) async {
    final key = '${type.name}_$mediaId';
    await _collection.doc(key).delete();
  }

  /// Get a specific entry
  Future<WatchlistEntry?> getEntry(int mediaId, MediaType type) async {
    final key = '${type.name}_$mediaId';
    final doc = await _collection.doc(key).get();
    if (!doc.exists || doc.data() == null) return null;
    return WatchlistEntry.fromJson(doc.data()!);
  }

  /// Check if media is on watchlist
  Future<bool> isOnWatchlist(int mediaId, MediaType type) async {
    final key = '${type.name}_$mediaId';
    final doc = await _collection
        .doc(key)
        .get(const GetOptions(source: Source.cache));
    if (doc.exists) return true;
    final serverDoc = await _collection.doc(key).get();
    return serverDoc.exists;
  }

  /// Get all entries in watchlist
  Future<List<WatchlistEntry>> getAllEntries() async {
    final snapshot = await _collection.get();
    final entries =
        snapshot.docs.map((doc) => WatchlistEntry.fromJson(doc.data())).toList()
          ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return entries;
  }

  /// Clear all watchlist entries
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
