import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';

/// Thin wrapper around [FirebaseAnalytics] that keeps the rest of the app
/// decoupled from the Firebase SDK and makes it easy to mock in tests.
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
    : _analytics =
          analytics ??
          ((Firebase.apps.isNotEmpty &&
                  Firebase.app().options.projectId != 'dummy-project-id')
              ? FirebaseAnalytics.instance
              : null);

  final FirebaseAnalytics? _analytics;

  /// Returns the [FirebaseAnalyticsObserver] to attach to [MaterialApp] or
  /// [Navigator] so route-level screen views are logged automatically.
  FirebaseAnalyticsObserver? get observer => _analytics != null
      ? FirebaseAnalyticsObserver(analytics: _analytics)
      : null;

  /// Screen names for the 5 bottom-nav tabs.
  static const String screenHome = 'home';
  static const String screenSearch = 'search';
  static const String screenAiChat = 'ai_chat';
  static const String screenMyList = 'my_list';
  static const String screenSettings = 'settings';

  /// Maps a bottom-nav [tabIndex] to a human-readable screen name.
  static String screenNameForTab(int index) => const [
    screenHome,
    screenSearch,
    screenAiChat,
    screenMyList,
    screenSettings,
  ][index];

  /// Logs a `screen_view` event for the given [screenName].
  ///
  /// Silently no-ops in debug mode so development runs don't pollute
  /// production analytics data.
  Future<void> logScreenView(String screenName) async {
    if (kDebugMode || _analytics == null) return;
    await _analytics.logScreenView(screenName: screenName);
  }

  /// Logs a custom event (e.g. user rated a movie, added to watchlist).
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (kDebugMode || _analytics == null) return;
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
