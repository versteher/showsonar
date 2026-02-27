import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

import 'package:neon_voyager/ui/screens/settings_screen.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';
import 'package:neon_voyager/ui/theme/app_theme.dart';
import 'package:neon_voyager/utils/remote_config_service.dart';

import '../../../utils/test_app_wrapper.dart';

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('SettingsScreen - Light and Dark Themes', (tester) async {
    final mockRemoteConfig = MockRemoteConfigService();
    when(() => mockRemoteConfig.enableSocial).thenReturn(true);
    when(() => mockRemoteConfig.enableWidgets).thenReturn(true);

    final mockPrefs = const UserPreferences(
      subscribedServiceIds: ['8', '9'], // Netflix, Amazon
      themeMode: 'system',
      countryCode: 'DE',
      countryName: 'Germany',
    );

    final overrides = [
      userPreferencesProvider.overrideWith((ref) => Future.value(mockPrefs)),
      authStateProvider.overrideWith((ref) => Stream.value(null)),
      remoteConfigServiceProvider.overrideWithValue(mockRemoteConfig),
    ];

    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [Device.phone, Device.iphone11])
      ..addScenario(
        widget: Theme(
          data: AppTheme.lightTheme,
          child: pumpAppScreen(
            child: const SettingsScreen(),
            overrides: overrides,
          ),
        ),
        name: 'Light Theme',
      )
      ..addScenario(
        widget: Theme(
          data: AppTheme.darkTheme,
          child: pumpAppScreen(
            child: const SettingsScreen(),
            overrides: overrides,
          ),
        ),
        name: 'Dark Theme',
      );

    await tester.pumpDeviceBuilder(builder);

    // Let the Futures resolve and animations settle
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    await screenMatchesGolden(tester, 'settings_screen');
  });
}
