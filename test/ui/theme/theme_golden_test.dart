import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_scout/ui/screens/settings_screen.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/models/user_preferences.dart';
import 'package:stream_scout/data/repositories/user_preferences_repository.dart';
import 'package:stream_scout/data/repositories/local_preferences_repository.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockUserPreferencesRepository extends UserPreferencesRepository {
  MockUserPreferencesRepository()
    : super('test_uid', firestore: FakeFirebaseFirestore());

  UserPreferences _prefs = UserPreferences.defaultDE();

  @override
  Future<void> init() async {}

  @override
  Future<UserPreferences> getPreferences() async => _prefs;

  @override
  Future<void> updateThemeMode(String themeMode) async {
    _prefs = _prefs.copyWith(themeMode: themeMode);
  }
}

class MockLocalPreferencesRepository implements LocalPreferencesRepository {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  bool get hasSeenOnboarding => false;
  @override
  Future<void> setHasSeenOnboarding(bool value) async {}
  @override
  ThemeMode get themeMode => _themeMode;
  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
  }
  @override
  Future<void> clear() async {}
}

void main() {
  Widget buildApp(ThemeData baseTheme) {
    return ProviderScope(
      overrides: [
        userPreferencesRepositoryProvider.overrideWithValue(
          MockUserPreferencesRepository(),
        ),
        localPreferencesRepositoryProvider.overrideWithValue(
          MockLocalPreferencesRepository(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: baseTheme,
        home: const SettingsScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  testWidgets('SettingsScreen Golden - Light Mode', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400); // Typical mobile size
    tester.view.devicePixelRatio = 3.0;

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildApp(ThemeData.light()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SettingsScreen),
        matchesGoldenFile('goldens/settings_screen_light.png'),
      );
    });

    // reset
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('SettingsScreen Golden - Dark Mode', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400); // Typical mobile size
    tester.view.devicePixelRatio = 3.0;

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildApp(ThemeData.dark()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SettingsScreen),
        matchesGoldenFile('goldens/settings_screen_dark.png'),
      );
    });

    // reset
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
