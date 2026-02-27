import '../data/models/media.dart';
import '../data/models/user_preferences.dart';

/// Shared utility for client-side media filtering based on user preferences.
/// Centralizes the logic that was previously duplicated across 10+ providers.
class MediaFilter {
  /// Filter a list of media items based on user preferences.
  /// Removes items below the minimum rating or above the max age rating.
  static List<Media> applyPreferences(
    List<Media> items,
    UserPreferences prefs,
  ) {
    return items.where((item) {
      // Check minimum rating
      if (item.voteAverage < prefs.minimumRating) return false;

      // Check age rating
      if (prefs.maxAgeRating < 18) {
        if (item.ageLevel > prefs.maxAgeRating) return false;
      }

      return true;
    }).toList();
  }

  /// Filter and also exclude already-watched content
  static List<Media> applyPreferencesAndExcludeWatched(
    List<Media> items,
    UserPreferences prefs,
    Set<String> watchedIds,
  ) {
    return items.where((item) {
      // Check minimum rating
      if (item.voteAverage < prefs.minimumRating) return false;

      // Check age rating
      if (prefs.maxAgeRating < 18) {
        if (item.ageLevel > prefs.maxAgeRating) return false;
      }

      // Check if already watched
      final key = '${item.type.name}_${item.id}';
      if (watchedIds.contains(key)) return false;

      return true;
    }).toList();
  }
}
