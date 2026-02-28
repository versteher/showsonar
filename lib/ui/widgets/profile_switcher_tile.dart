import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_scout/config/providers/profile_providers.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';

/// Compact tile showing the active profile — tappable to go to profiles screen.
class ProfileSwitcherTile extends ConsumerWidget {
  const ProfileSwitcherTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);
    final profilesAsync = ref.watch(profilesProvider);

    final profileCount = profilesAsync.valueOrNull?.length ?? 0;
    final label = activeProfile?.name ?? 'Default';
    final emoji = activeProfile?.avatarEmoji ?? '👤';

    return InkWell(
      onTap: () => context.push('/profiles'),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Row(
          children: [
            // Avatar circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    profileCount > 0
                        ? '$profileCount profile${profileCount == 1 ? '' : 's'}'
                        : 'No additional profiles',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
