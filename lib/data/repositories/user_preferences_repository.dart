import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/streaming_provider.dart';
import '../models/user_preferences.dart';

/// Repository for managing user preferences in Firestore.
/// When [profileId] is provided, preferences are stored in a profile sub-collection.
class UserPreferencesRepository {
  final String userId;
  final String? profileId;
  final FirebaseFirestore _firestore;

  UserPreferencesRepository(
    this.userId, {
    this.profileId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _docRef {
    if (profileId != null) {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId)
          .collection('preferences')
          .doc('current');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('current');
  }

  /// Initialize the repository and perform one-time Hive migration
  Future<void> init() async {
    if (userId == 'guest') return;

    const boxName = 'user_preferences';
    const prefsKey = 'prefs';
    if (await Hive.boxExists(boxName)) {
      final box = await Hive.openBox<String>(boxName);
      if (box.isNotEmpty && box.containsKey(prefsKey)) {
        final jsonStr = box.get(prefsKey);
        if (jsonStr != null) {
          final entryMap = jsonDecode(jsonStr);
          await _docRef.set(entryMap, SetOptions(merge: true));
        }
        await box.clear();
      }
      await box.close();
      await Hive.deleteBoxFromDisk(boxName);
    }
  }

  /// Save user preferences
  Future<void> savePreferences(UserPreferences prefs) async {
    await _docRef.set(prefs.toJson());
  }

  /// Get current preferences or default
  Future<UserPreferences> getPreferences() async {
    final doc = await _docRef.get();
    if (!doc.exists || doc.data() == null) {
      return UserPreferences.defaultDE();
    }
    return UserPreferences.fromJson(doc.data()!);
  }

  /// Check if preferences exist
  Future<bool> hasPreferences() async {
    final doc = await _docRef.get(const GetOptions(source: Source.cache));
    if (doc.exists) return true;
    final serverDoc = await _docRef.get();
    return serverDoc.exists;
  }

  /// Update country and reset subscribed services to country defaults
  Future<void> updateCountry(String countryCode, String countryName) async {
    final current = await getPreferences();
    final newDefaults = StreamingProvider.getDefaultServiceIds(countryCode);
    final updated = current.copyWith(
      countryCode: countryCode,
      countryName: countryName,
      subscribedServiceIds: newDefaults,
    );
    await savePreferences(updated);
  }

  /// Add streaming service
  Future<void> addStreamingService(String serviceId) async {
    final current = await getPreferences();
    if (current.subscribedServiceIds.contains(serviceId)) return;

    final updated = current.copyWith(
      subscribedServiceIds: [...current.subscribedServiceIds, serviceId],
    );
    await savePreferences(updated);
  }

  /// Remove streaming service
  Future<void> removeStreamingService(String serviceId) async {
    final current = await getPreferences();
    final updated = current.copyWith(
      subscribedServiceIds: current.subscribedServiceIds
          .where((id) => id != serviceId)
          .toList(),
    );
    await savePreferences(updated);
  }

  Future<void> updateMinimumRating(double rating) async {
    final current = await getPreferences();
    final updated = current.copyWith(minimumRating: rating);
    await savePreferences(updated);
  }

  Future<void> updateMaxAgeRating(int? rating) async {
    final current = await getPreferences();
    final updated = current.copyWith(
      maxAgeRating: rating ?? current.maxAgeRating,
    );
    await savePreferences(updated);
  }

  /// Update include adult content setting
  Future<void> updateIncludeAdult(bool includeAdult) async {
    final current = await getPreferences();
    final updated = current.copyWith(includeAdult: includeAdult);
    await savePreferences(updated);
  }

  /// Add favorite genre
  Future<void> addFavoriteGenre(int genreId) async {
    final current = await getPreferences();
    if (current.favoriteGenreIds.contains(genreId)) return;

    final updated = current.copyWith(
      favoriteGenreIds: [...current.favoriteGenreIds, genreId],
    );
    await savePreferences(updated);
  }

  /// Remove favorite genre
  Future<void> removeFavoriteGenre(int genreId) async {
    final current = await getPreferences();
    final updated = current.copyWith(
      favoriteGenreIds: current.favoriteGenreIds
          .where((id) => id != genreId)
          .toList(),
    );
    await savePreferences(updated);
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    await savePreferences(UserPreferences.defaultDE());
  }

  /// Clear all preferences
  Future<void> clear() async {
    await _docRef.delete();
  }

  /// Update theme mode in cloud
  Future<void> updateThemeMode(String themeMode) async {
    final current = await getPreferences();
    if (current.themeMode == themeMode) return;

    final updated = current.copyWith(themeMode: themeMode);
    await savePreferences(updated);
  }

  /// Update show extended ratings setting
  Future<void> updateShowExtendedRatings(bool show) async {
    final current = await getPreferences();
    if (current.showExtendedRatings == show) return;

    final updated = current.copyWith(showExtendedRatings: show);
    await savePreferences(updated);
  }

  Future<void> close() async {}
}
