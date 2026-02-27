import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository for tracking individual episode watch states in Firestore.
///
/// Firestore path:
///   users/{uid}/episodeTracking/{tvId} → { "sN_eN": true, ... }
///
/// Each document key is the series TMDB ID, and the document stores a map of
/// episode keys ("s1_e3" = season 1, episode 3) to `true` (watched).
/// This design is efficient for reading all watched episodes for a series in
/// one document fetch.
class EpisodeTrackingRepository {
  final String userId;
  final String? profileId;
  final FirebaseFirestore _firestore;

  EpisodeTrackingRepository(
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
          .collection('episodeTracking');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('episodeTracking');
  }

  /// Returns the Firestore document reference for a given TV series.
  DocumentReference<Map<String, dynamic>> _doc(int tvId) =>
      _collection.doc('$tvId');

  /// A canonical string key for a season+episode pair.
  static String episodeKey(int seasonNumber, int episodeNumber) =>
      's${seasonNumber}_e$episodeNumber';

  /// Mark a single episode as watched.
  Future<void> markEpisodeWatched(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    final key = episodeKey(seasonNumber, episodeNumber);
    await _doc(tvId).set({key: true}, SetOptions(merge: true));
  }

  /// Unmark a single episode (remove from watched set).
  Future<void> unmarkEpisodeWatched(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    final key = episodeKey(seasonNumber, episodeNumber);
    await _doc(tvId).update({key: FieldValue.delete()});
  }

  /// Returns the set of episode keys that have been watched for [tvId].
  /// Keys are in the format "sN_eN" (e.g. "s1_e3").
  Future<Set<String>> getWatchedEpisodes(int tvId) async {
    final doc = await _doc(tvId).get();
    if (!doc.exists || doc.data() == null) return {};
    return doc.data()!.keys.toSet();
  }

  /// Check whether a specific episode has been watched.
  Future<bool> isEpisodeWatched(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    final watched = await getWatchedEpisodes(tvId);
    return watched.contains(episodeKey(seasonNumber, episodeNumber));
  }

  /// Returns the count of watched episodes for [tvId].
  Future<int> getWatchedCount(int tvId) async {
    final watched = await getWatchedEpisodes(tvId);
    return watched.length;
  }

  /// Remove all episode tracking data for [tvId] (e.g. when removing from watchlist).
  Future<void> clearEpisodeTracking(int tvId) async {
    await _doc(tvId).delete();
  }
}
