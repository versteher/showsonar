import 'package:flutter/material.dart';
import 'package:neon_voyager/data/models/media.dart';
import 'package:neon_voyager/ui/theme/app_theme.dart';
import 'package:neon_voyager/ui/widgets/media_card.dart';

/// A horizontal scrolling list of media items with a section title
class MediaSection extends StatelessWidget {
  final String title;
  final List<Media> items;
  final VoidCallback? onSeeAllTap;
  final void Function(Media media, String? heroTagPrefix)? onMediaTap;
  final void Function(Media media)? onMediaLongPress;
  final bool isLoading;
  final double cardWidth;
  final Set<String>? watchedIds;
  final bool hideWatched;
  final String? heroTagPrefix;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;

  const MediaSection({
    super.key,
    required this.title,
    required this.items,
    this.onSeeAllTap,
    this.onMediaTap,
    this.onMediaLongPress,
    this.isLoading = false,
    this.cardWidth = AppTheme.posterWidthMedium,
    this.watchedIds,
    this.hideWatched = false,
    this.heroTagPrefix,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  /// Sort/filter items based on watched status
  List<Media> get _processedItems {
    if (watchedIds == null || watchedIds!.isEmpty) return items;
    final unwatched = <Media>[];
    final watched = <Media>[];
    for (final item in items) {
      final key = '${item.type.name}_${item.id}';
      if (watchedIds!.contains(key)) {
        watched.add(item);
      } else {
        unwatched.add(item);
      }
    }
    if (hideWatched) return unwatched;
    return [...unwatched, ...watched];
  }

  bool _isWatched(Media media) {
    if (watchedIds == null) return false;
    return watchedIds!.contains('${media.type.name}_${media.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                if (onSeeAllTap != null)
                  TextButton(
                    onPressed: onSeeAllTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Alle anzeigen',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

        const SizedBox(height: AppTheme.spacingMd),

        // Content
        if (isLoading)
          _buildLoadingState()
        else if (items.isEmpty)
          _buildEmptyState()
        else
          _buildMediaList(),
      ],
    );
  }

  Widget _buildMediaList() {
    final sorted = _processedItems;
    final displayCount = sorted.length + (isLoadingMore ? 1 : 0);

    return SizedBox(
      height: (cardWidth / AppTheme.posterAspectRatio) + 50,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (onLoadMore != null &&
              !isLoadingMore &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            onLoadMore!();
          }
          return false;
        },
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          itemCount: displayCount,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppTheme.spacingMd),
          itemBuilder: (context, index) {
            if (index == sorted.length && isLoadingMore) {
              return Container(
                width: cardWidth,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(color: AppTheme.primary),
              );
            }
            final media = sorted[index];
            return MediaCard(
              media: media,
              width: cardWidth,
              onTap: () => onMediaTap?.call(media, heroTagPrefix),
              onLongPress: onMediaLongPress,
              isWatched: _isWatched(media),
              heroTagPrefix: heroTagPrefix,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: (cardWidth / AppTheme.posterAspectRatio) + 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        itemCount: 5,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppTheme.spacingMd),
        itemBuilder: (context, index) {
          return Container(
            width: cardWidth,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_filter_outlined,
              size: 32,
              color: AppTheme.textMuted,
            ),
            SizedBox(height: AppTheme.spacingSm),
            Text(
              'Keine Inhalte verfügbar',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
