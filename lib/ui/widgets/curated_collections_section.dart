import 'package:stream_scout/utils/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/providers.dart';
import '../../config/providers/curated_providers.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';
import '../widgets/media_section.dart';
import '../widgets/error_retry_widget.dart';

/// Curated Collections section with chip selector and themed content
class CuratedCollectionsSection extends ConsumerWidget {
  final void Function(Media media, String? heroTagPrefix) onMediaTap;
  final void Function(Media media)? onMediaLongPress;

  const CuratedCollectionsSection({
    super.key,
    required this.onMediaTap,
    this.onMediaLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCollectionProvider);
    final contentAsync = ref.watch(curatedCollectionProvider);
    final watchedIds =
        ref.watch(watchedMediaIdsProvider).valueOrNull ?? <String>{};
    final hideWatched = ref.watch(hideWatchedProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Text(
            '📚 Sammlungen',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),

        // Collection chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            itemCount: CuratedCollection.values.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppTheme.spacingSm),
            itemBuilder: (context, index) {
              final collection = CuratedCollection.values[index];
              final isSelected = collection == selected;
              final label = locale == 'de'
                  ? collection.labelDe
                  : collection.labelEn;

              return GestureDetector(
                onTap: () {
                  AppHaptics.selectionClick();
                  ref.read(selectedCollectionProvider.notifier).state =
                      collection;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.surfaceBorder,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryLight
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Content
        contentAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                ),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Keine Inhalte für diese Sammlung gefunden',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ),
                ),
              );
            }
            return MediaSection(
              title: '',
              items: items,
              onMediaTap: onMediaTap,
              onMediaLongPress: onMediaLongPress,
              watchedIds: watchedIds,
              hideWatched: hideWatched,
              heroTagPrefix: 'curated_${selected.name}',
            );
          },
          loading: () =>
              MediaSection(title: '', items: const [], isLoading: true),
          error: (error, _) => ErrorRetryWidget(
            compact: true,
            message: 'Sammlung konnte nicht geladen werden',
            onRetry: () => ref.invalidate(curatedCollectionProvider),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}
