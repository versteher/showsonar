import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/providers.dart';
import '../../data/models/shared_watchlist.dart';
import '../theme/app_theme.dart';
import '../../utils/app_haptics.dart';

class SharedWatchlistsScreen extends ConsumerWidget {
  const SharedWatchlistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(sharedWatchlistsProvider);

    return listsAsync.when(
      data: (lists) {
        if (lists.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.playlist_add_rounded,
                    size: 64,
                    color: AppTheme.textMuted,
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                  const SizedBox(height: AppTheme.spacingMd),
                  const Text(
                    'No shared watchlists yet',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  const Text(
                    'Create a list and invite friends for movie nights',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  FilledButton.icon(
                    onPressed: () => _showCreateDialog(context, ref),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create a shared list'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                return _SharedWatchlistCard(list: lists[index])
                    .animate(delay: (index * 60).ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
            // FAB to create new list
            Positioned(
              bottom: AppTheme.spacingMd,
              right: AppTheme.spacingMd,
              child: FloatingActionButton.extended(
                heroTag: 'create_shared_list',
                onPressed: () {
                  AppHaptics.mediumImpact();
                  _showCreateDialog(context, ref);
                },
                backgroundColor: AppTheme.primary,
                icon: const Icon(Icons.add_rounded),
                label: const Text('New List'),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (_, __) => const Center(
        child: Text(
          'Could not load shared lists',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'New Shared List',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Movie night with Alex',
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.surfaceBorder),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              ctx.pop();
              AppHaptics.mediumImpact();
              await ref
                  .read(sharedWatchlistRepositoryProvider)
                  .createWatchlist(name);
              ref.invalidate(sharedWatchlistsProvider);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _SharedWatchlistCard extends ConsumerWidget {
  final SharedWatchlist list;

  const _SharedWatchlistCard({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(sharedWatchlistRepositoryProvider);
    final authUser = ref.read(authStateProvider).value;
    final isOwner = authUser?.uid == list.ownerId;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: const Icon(Icons.group_rounded, color: Colors.white),
        ),
        title: Text(
          list.name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${list.mediaIds.length} items · ${list.sharedWithUids.length} members',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        trailing: isOwner
            ? PopupMenuButton<String>(
                color: AppTheme.surface,
                icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
                onSelected: (value) async {
                  if (value == 'delete') {
                    AppHaptics.heavyImpact();
                    await repo.deleteWatchlist(list.id);
                    ref.invalidate(sharedWatchlistsProvider);
                  } else if (value == 'rename') {
                    if (context.mounted) _showRenameDialog(context, ref, repo);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Text(
                      'Rename',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, dynamic repo) {
    final controller = TextEditingController(text: list.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Rename List',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.surfaceBorder),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              ctx.pop();
              await repo.updateWatchlistName(list.id, name);
              ref.invalidate(sharedWatchlistsProvider);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
