import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';
import 'media_section.dart';

/// "Because You Watched" section — shows personalized recommendation groups
/// based on the user's highly-rated watch history items.
/// Only visible when the user has rated content ≥ 7.0.
class BecauseYouWatchedSection extends ConsumerWidget {
  final void Function(Media media, String? heroTagPrefix) onMediaTap;
  final void Function(Media media)? onMediaLongPress;

  const BecauseYouWatchedSection({
    super.key,
    required this.onMediaTap,
    this.onMediaLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(becauseYouWatchedProvider);
    final watchedIds =
        ref.watch(watchedMediaIdsProvider).valueOrNull ?? <String>{};
    final hideWatched = ref.watch(hideWatchedProvider);

    return groupsAsync.when(
      data: (groups) {
        if (groups.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(top: AppTheme.spacingMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withValues(alpha: 0.15),
                AppTheme.primaryDark.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final group in groups) ...[
                if (group != groups.first)
                  const SizedBox(height: AppTheme.spacingLg),
                MediaSection(
                  title: '✨ ${group.title}',
                  items: group.items,
                  onMediaTap: onMediaTap,
                  onMediaLongPress: onMediaLongPress,
                  watchedIds: watchedIds,
                  hideWatched: hideWatched,
                  heroTagPrefix:
                      'byw_${group.sourceMediaId ?? group.title.hashCode}',
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 400.ms);
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
