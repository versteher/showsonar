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
  @override
  int get viewingContextIndex => 0;

  @override
  Future<void> setViewingContextIndex(int index) async {}

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
  testWidgets('SettingsScreen displays theme options and syncs changes', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockUserPreferencesRepository();
    final mockLocalRepo = MockLocalPreferencesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userPreferencesRepositoryProvider.overrideWithValue(mockRepo),
          localPreferencesRepositoryProvider.overrideWithValue(mockLocalRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );

    // Initial load
    await tester.pumpAndSettle();

    // Verify Theme section is there
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    // Scroll until Light mode button is visible
    await tester.ensureVisible(find.text('Light'));
    await tester.pumpAndSettle();

    // Tap Light mode
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    // Verify repository was updated
    final prefs = await mockRepo.getPreferences();
    expect(prefs.themeMode, 'light');
  });
}
