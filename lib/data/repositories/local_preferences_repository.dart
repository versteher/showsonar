import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Repository for managing local-only device state (not synced to Firestore)
class LocalPreferencesRepository {
  static const _boxName = 'local_prefs';
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const _themeModeKey = 'theme_mode';

  Box get _box => Hive.box(_boxName);

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  bool get hasSeenOnboarding {
    return _box.get(_hasSeenOnboardingKey, defaultValue: false) as bool;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await _box.put(_hasSeenOnboardingKey, value);
  }

  ThemeMode get themeMode {
    final modeStr =
        _box.get(_themeModeKey, defaultValue: ThemeMode.dark.name) as String;
    return ThemeMode.values.firstWhere(
      (e) => e.name == modeStr,
      orElse: () => ThemeMode.dark,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(_themeModeKey, mode.name);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
