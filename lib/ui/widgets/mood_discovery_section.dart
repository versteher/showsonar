import 'package:neon_voyager/utils/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/media_card.dart';
import '../screens/detail_screen.dart';

/// Mood-based quick discovery section with emoji chips and results
class MoodDiscoverySection extends ConsumerWidget {
  const MoodDiscoverySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMood = ref.watch(selectedMoodProvider);
    final moodResultsAsync = ref.watch(moodDiscoverProvider);
    final watchedIds =
        ref.watch(watchedMediaIdsProvider).valueOrNull ?? <String>{};
    final hideWatched = ref.watch(hideWatchedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.mood_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.moodTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),

        // Mood chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            itemCount: DiscoveryMood.values.length,
            itemBuilder: (context, index) {
              final mood = DiscoveryMood.values[index];
              final isSelected = selectedMood == mood;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    AppHaptics.selectionClick();
                    ref.read(selectedMoodProvider.notifier).state = isSelected
                        ? null
                        : mood;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                            )
                          : null,
                      color: isSelected ? null : AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppTheme.surfaceBorder,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF7C4DFF,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Results
        if (selectedMood != null) ...[
          const SizedBox(height: AppTheme.spacingSm),
          moodResultsAsync.when(
            data: (items) {
              final filtered = hideWatched
                  ? items
                        .where(
                          (m) => !watchedIds.contains('${m.type.name}_${m.id}'),
                        )
                        .toList()
                  : items;
              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.moodNoResults(selectedMood.label),
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                );
              }
              return SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: MediaCard(
                        media: filtered[index],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(
                                mediaId: filtered[index].id,
                                mediaType: filtered[index].type,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(duration: 300.ms);
            },
            loading: () => const SizedBox(
              height: 210,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE040FB)),
              ),
            ),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}
