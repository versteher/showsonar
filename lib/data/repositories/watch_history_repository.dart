import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/watch_history_entry.dart';
import '../models/media.dart';

/// Repository for managing watch history in Firestore.
/// When [profileId] is provided, history is stored in a profile sub-collection.
class WatchHistoryRepository {
  final String userId;
  final String? profileId;
  final FirebaseFirestore _firestore;

  WatchHistoryRepository(
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
          .collection('watchHistory');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('watchHistory');
  }

  /// Initialize the repository, executing a one-time migration from Hive if needed
  Future<void> init() async {
    if (userId == 'guest') return;

    const boxName = 'watch_history';
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

  /// Add media to watch history
  Future<void> addToHistory(WatchHistoryEntry entry) async {
    await _collection.doc(entry.uniqueKey).set(entry.toJson());
  }

  /// Create entry from Media and add to history
  Future<WatchHistoryEntry> markAsWatched(Media media, {double? rating}) async {
    final entry = WatchHistoryEntry.fromMedia(media, rating: rating);
    await addToHistory(entry);
    return entry;
  }

  /// Update an existing entry
  Future<void> updateEntry(WatchHistoryEntry entry) async {
    await _collection
        .doc(entry.uniqueKey)
        .set(entry.toJson(), SetOptions(merge: true));
  }

  /// Remove entry from history
  Future<void> removeFromHistory(int mediaId, MediaType type) async {
    final key = '${type.name}_$mediaId';
    await _collection.doc(key).delete();
  }

  /// Get a specific entry
  Future<WatchHistoryEntry?> getEntry(int mediaId, MediaType type) async {
    final key = '${type.name}_$mediaId';
    final doc = await _collection.doc(key).get();
    if (!doc.exists || doc.data() == null) return null;
    return WatchHistoryEntry.fromJson(doc.data()!);
  }

  /// Check if media is in watch history
  Future<bool> hasWatched(int mediaId, MediaType type) async {
    final key = '${type.name}_$mediaId';
    final doc = await _collection
        .doc(key)
        .get(const GetOptions(source: Source.cache));
    if (doc.exists) return true;
    final serverDoc = await _collection.doc(key).get();
    return serverDoc.exists;
  }

  /// Get all entries in watch history
  Future<List<WatchHistoryEntry>> getAllEntries() async {
    final snapshot = await _collection.get();
    final entries =
        snapshot.docs
            .map((doc) => WatchHistoryEntry.fromJson(doc.data()))
            .toList()
          ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    return entries;
  }

  Future<List<WatchHistoryEntry>> getRecentlyWatched({int limit = 10}) async {
    final entries = await getAllEntries();
    return entries.take(limit).toList();
  }

  Future<List<WatchHistoryEntry>> getEntriesByType(MediaType type) async {
    final entries = await getAllEntries();
    return entries.where((e) => e.mediaType == type).toList();
  }

  Future<List<WatchHistoryEntry>> getRatedEntries() async {
    final entries = await getAllEntries();
    return entries.where((e) => e.userRating != null).toList();
  }

  Future<List<WatchHistoryEntry>> getHighlyRated({
    double minRating = 8.0,
  }) async {
    final entries = await getRatedEntries();
    return entries.where((e) => e.userRating! >= minRating).toList();
  }

  Future<Map<int, int>> getGenreFrequency(
    List<int> Function(int, MediaType) getGenres,
  ) async {
    final entries = await getAllEntries();
    final frequency = <int, int>{};
    for (final entry in entries) {
      final genres = getGenres(entry.mediaId, entry.mediaType);
      for (final genre in genres) {
        frequency[genre] = (frequency[genre] ?? 0) + 1;
      }
    }
    return frequency;
  }

  Future<int> getCountByType(MediaType type) async {
    final entries = await getEntriesByType(type);
    return entries.length;
  }

  /// Clear all watch history (DANGER)
  Future<void> clearAll() async {
    final snapshot = await _collection.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Close is kept for API compatibility, though Firestore doesn't require closing
  Future<void> close() async {}
}
