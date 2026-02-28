import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing local-only device state (not synced to Firestore).
/// Uses shared_preferences — no Hive lock-file issues on macOS.
class LocalPreferencesRepository {
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const _themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  const LocalPreferencesRepository(this._prefs);

  bool get hasSeenOnboarding =>
      _prefs.getBool(_hasSeenOnboardingKey) ?? false;

  Future<void> setHasSeenOnboarding(bool value) =>
      _prefs.setBool(_hasSeenOnboardingKey, value);

  ThemeMode get themeMode {
    final modeStr = _prefs.getString(_themeModeKey) ?? ThemeMode.dark.name;
    return ThemeMode.values.firstWhere(
      (e) => e.name == modeStr,
      orElse: () => ThemeMode.dark,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  Future<void> clear() => _prefs.clear();
}
