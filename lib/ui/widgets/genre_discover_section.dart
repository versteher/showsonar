import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';
import 'media_section.dart';
import 'error_retry_widget.dart';

/// Unified genre discovery section with tab chips + sort toggle
class GenreDiscoverSection extends ConsumerWidget {
  final void Function(Media media, String? heroTagPrefix) onMediaTap;

  static const _genres = [
    (id: 35, name: 'Komödie', emoji: '😄'),
    (id: 28, name: 'Action', emoji: '💥'),
    (id: 27, name: 'Horror', emoji: '👻'),
    (id: 18, name: 'Drama', emoji: '🎭'),
    (id: 878, name: 'Sci-Fi', emoji: '🚀'),
    (id: 10751, name: 'Familie', emoji: '👨‍👩‍👧'),
    (id: 53, name: 'Thriller', emoji: '🔪'),
    (id: 16, name: 'Animation', emoji: '🎨'),
    (id: 10749, name: 'Romantik', emoji: '💕'),
  ];

  const GenreDiscoverSection({super.key, required this.onMediaTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGenre = ref.watch(selectedGenreProvider);
    final sortBy = ref.watch(genreSortByProvider);
    final isRatingSort = sortBy == 'vote_average.desc';
    final watchedIdsAsync = ref.watch(watchedMediaIdsProvider);
    final watchedIds = watchedIdsAsync.valueOrNull ?? <String>{};
    final hideWatched = ref.watch(hideWatchedProvider);

    final dataAsync = ref.watch(
      genreDiscoverProvider((genreId: selectedGenre, sortBy: sortBy)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: title + sort button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Row(
            children: [
              Text(
                '🎯 Entdecken',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              // Sort toggle – simple icon button
              GestureDetector(
                onTap: () {
                  ref.read(genreSortByProvider.notifier).state = isRatingSort
                      ? 'popularity.desc'
                      : 'vote_average.desc';
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isRatingSort
                        ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isRatingSort
                          ? const Color(0xFFFFD700)
                          : AppTheme.surfaceBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isRatingSort ? '⭐' : '🔥',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRatingSort ? 'IMDB' : 'Beliebt',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isRatingSort
                              ? const Color(0xFFFFD700)
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Genre chip tabs
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            itemCount: _genres.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final genre = _genres[index];
              final isActive = selectedGenre == genre.id;
              return GestureDetector(
                onTap: () =>
                    ref.read(selectedGenreProvider.notifier).state = genre.id,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: isActive ? AppTheme.primaryGradient : null,
                    color: isActive ? null : AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: isActive
                        ? null
                        : Border.all(color: AppTheme.surfaceBorder),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    '${genre.emoji} ${genre.name}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Content carousel for selected genre
        dataAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppTheme.spacingMd),
                child: Text(
                  'Keine Inhalte gefunden',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              );
            }
            return MediaSection(
              title: '',
              items: items.take(20).toList(),
              onMediaTap: onMediaTap,
              watchedIds: watchedIds,
              hideWatched: hideWatched,
              heroTagPrefix: 'genre_discover',
            );
          },
          loading: () =>
              MediaSection(title: '', items: const [], isLoading: true),
          error: (error, stackTrace) => ErrorRetryWidget(
            compact: true,
            message: 'Genre konnte nicht geladen werden',
            onRetry: () => ref.invalidate(
              genreDiscoverProvider((genreId: selectedGenre, sortBy: sortBy)),
            ),
          ),
        ),
      ],
    );
  }
}
