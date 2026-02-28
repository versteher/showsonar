import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';
import 'package:stream_scout/ui/widgets/app_snack_bar.dart';

/// Card with a button to reset all user preferences to defaults.
class SettingsResetCard extends ConsumerWidget {
  const SettingsResetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.settingsResetTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  AppLocalizations.of(context)!.settingsResetSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  title: Text(
                    AppLocalizations.of(context)!.settingsResetConfirm,
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.settingsResetMessage,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(false),
                      child: Text(AppLocalizations.of(context)!.detailCancel),
                    ),
                    ElevatedButton(
                      onPressed: () => context.pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warning,
                      ),
                      child: Text(AppLocalizations.of(context)!.settingsReset),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final repo = ref.read(userPreferencesRepositoryProvider);
                await repo.init();
                await repo.resetToDefaults();
                ref.invalidate(userPreferencesProvider);

                if (context.mounted) {
                  AppSnackBar.showSuccess(
                    context,
                    AppLocalizations.of(context)!.settingsResetTitle,
                    icon: Icons.refresh_rounded,
                  );
                }
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
