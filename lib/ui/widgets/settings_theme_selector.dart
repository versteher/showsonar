import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';
import 'package:neon_voyager/ui/theme/app_theme.dart';

/// Segmented button card for selecting the app theme mode.
class SettingsThemeSelector extends ConsumerWidget {
  const SettingsThemeSelector({super.key, required this.prefs});

  final UserPreferences prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(
            value: 'system',
            icon: Icon(Icons.brightness_auto),
            label: Text('System'),
          ),
          ButtonSegment<String>(
            value: 'light',
            icon: Icon(Icons.light_mode),
            label: Text('Light'),
          ),
          ButtonSegment<String>(
            value: 'dark',
            icon: Icon(Icons.dark_mode),
            label: Text('Dark'),
          ),
        ],
        selected: {prefs.themeMode},
        onSelectionChanged: (Set<String> newSelection) async {
          final modeStr = newSelection.first;
          final newMode = ThemeMode.values.firstWhere(
            (e) => e.name == modeStr,
            orElse: () => ThemeMode.system,
          );
          ref.read(themeModeProvider.notifier).state = newMode;
          ref.read(localPreferencesRepositoryProvider).setThemeMode(newMode);

          final repo = ref.read(userPreferencesRepositoryProvider);
          await repo.init();
          await repo.updateThemeMode(modeStr);
          ref.invalidate(userPreferencesProvider);
        },
      ),
    );
  }
}
