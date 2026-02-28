import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_scout/config/providers/profile_providers.dart';
import 'package:stream_scout/data/models/app_profile.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';
import 'package:stream_scout/ui/widgets/add_profile_sheet.dart';
import 'package:stream_scout/ui/widgets/app_snack_bar.dart';
import 'package:stream_scout/ui/widgets/empty_profiles_hint.dart';
import 'package:stream_scout/ui/widgets/profile_tile.dart';

/// Screen for creating, switching, and removing family sub-profiles.
class ProfileManagementScreen extends ConsumerWidget {
  const ProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesProvider);
    final activeProfileId = ref.watch(activeProfileIdProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.background,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Icon(Icons.people_rounded, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Profiles'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Add Profile',
                  onPressed: () => _showAddProfileSheet(context, ref),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Default (main) profile tile
                    ProfileTile(
                      emoji: '👤',
                      name: 'Default',
                      subtitle: 'Main profile — shared across the account',
                      isActive: activeProfileId == null,
                      onSwitch: () {
                        ref.read(activeProfileIdProvider.notifier).state = null;
                        AppSnackBar.showSuccess(
                          context,
                          'Switched to Default profile',
                          icon: Icons.check_circle_rounded,
                        );
                      },
                      onDelete: null, // Cannot delete default
                    ),

                    const SizedBox(height: AppTheme.spacingMd),

                    Text(
                      'Family Profiles',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),

                    // Sub-profiles from Firestore
                    profilesAsync.when(
                      data: (profiles) {
                        if (profiles.isEmpty) {
                          return EmptyProfilesHint(
                            onAdd: () => _showAddProfileSheet(context, ref),
                          );
                        }
                        return Column(
                          children: [
                            for (final profile in profiles)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppTheme.spacingSm,
                                ),
                                child: ProfileTile(
                                  emoji: profile.avatarEmoji,
                                  name: profile.name,
                                  subtitle:
                                      'Independent watchlist & watch history',
                                  isActive: activeProfileId == profile.id,
                                  onSwitch: () {
                                    ref
                                        .read(activeProfileIdProvider.notifier)
                                        .state = profile.id;
                                    AppSnackBar.showSuccess(
                                      context,
                                      'Switched to ${profile.name}',
                                      icon: Icons.check_circle_rounded,
                                    );
                                  },
                                  onDelete: () =>
                                      _confirmDelete(context, ref, profile),
                                ),
                              ),
                          ],
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Text('Error: $e'),
                    ),

                    const SizedBox(height: AppTheme.spacingXl),

                    // Info card
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          Expanded(
                            child: Text(
                              'Each profile has its own watchlist, watch history, and preferences. Switching profiles changes all content immediately.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddProfileSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) =>
          AddProfileSheet(onCreated: () => ref.invalidate(profilesProvider)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppProfile profile,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Delete "${profile.name}"?'),
        content: Text(
          'This profile and its data will be removed. This cannot be undone.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => ctx.pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(profileRepositoryProvider).deleteProfile(profile.id);
      // If the deleted profile was active, reset to default
      if (ref.read(activeProfileIdProvider) == profile.id) {
        ref.read(activeProfileIdProvider.notifier).state = null;
      }
      ref.invalidate(profilesProvider);
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          '"${profile.name}" deleted',
          icon: Icons.delete_rounded,
        );
      }
    }
  }
}
