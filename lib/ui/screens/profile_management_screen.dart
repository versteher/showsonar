import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/config/providers/profile_providers.dart';
import 'package:neon_voyager/data/models/app_profile.dart';
import 'package:neon_voyager/ui/theme/app_theme.dart';
import 'package:neon_voyager/ui/widgets/app_snack_bar.dart';

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
                    _ProfileTile(
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
                          return _EmptyProfilesHint(
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
                                child: _ProfileTile(
                                  emoji: profile.avatarEmoji,
                                  name: profile.name,
                                  subtitle:
                                      'Independent watchlist & watch history',
                                  isActive: activeProfileId == profile.id,
                                  onSwitch: () {
                                    ref
                                        .read(activeProfileIdProvider.notifier)
                                        .state = profile
                                        .id;
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
          _AddProfileSheet(onCreated: () => ref.invalidate(profilesProvider)),
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
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
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

// ─────────────────────────────────────────────────────────────────────────────
// Profile tile
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  final String emoji;
  final String name;
  final String subtitle;
  final bool isActive;
  final VoidCallback onSwitch;
  final VoidCallback? onDelete;

  const _ProfileTile({
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.isActive,
    required this.onSwitch,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primary.withValues(alpha: 0.12)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isActive
              ? AppTheme.primary.withValues(alpha: 0.6)
              : AppTheme.surfaceBorder,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isActive ? AppTheme.primaryGradient : null,
              color: isActive ? null : AppTheme.surfaceBorder,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),

          // Name + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isActive)
                TextButton(onPressed: onSwitch, child: const Text('Switch')),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.error,
                    size: 20,
                  ),
                  tooltip: 'Delete profile',
                  onPressed: onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyProfilesHint extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyProfilesHint({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            style: BorderStyle.solid,
            color: AppTheme.surfaceBorder,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.person_add_alt_1_rounded,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Add a Family Profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Create separate profiles for family members.\nEach profile has its own independent watchlist.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add profile bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddProfileSheet extends ConsumerStatefulWidget {
  final VoidCallback onCreated;

  const _AddProfileSheet({required this.onCreated});

  @override
  ConsumerState<_AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends ConsumerState<_AddProfileSheet> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '🎬';
  bool _saving = false;

  static const _emojis = [
    '🎬',
    '🍿',
    '👦',
    '👧',
    '🧑',
    '👩',
    '👨',
    '👴',
    '👵',
    '🦸',
    '🧙',
    '🤖',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('New Profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppTheme.spacingMd),

          // Emoji picker
          Text(
            'Choose an avatar',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _emojis.map((e) {
              final selected = e == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = e),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: selected ? AppTheme.primaryGradient : null,
                    color: selected ? null : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : AppTheme.surfaceBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(e, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Name field
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Profile name',
              hintText: 'e.g. Kids, Partner, Alex',
              prefixText: '$_selectedEmoji  ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .createProfile(name: name, avatarEmoji: _selectedEmoji);
      widget.onCreated();
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
