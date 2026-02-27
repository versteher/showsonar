import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';
import 'app_snack_bar.dart';

void showLongPressMenu(BuildContext context, WidgetRef ref, Media media) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Rich preview card
            GestureDetector(
              onTap: () {
                context.pop();
                context.push('/media.type/media.id');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: media.posterPath != null
                          ? Image.network(
                              media.fullPosterPath,
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 60,
                              height: 90,
                              color: AppTheme.surfaceLight,
                              child: const Icon(
                                Icons.movie_rounded,
                                color: AppTheme.textMuted,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            media.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: AppTheme.getRatingColor(
                                  media.voteAverage,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                media.voteAverage.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getRatingColor(
                                    media.voteAverage,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${media.year} · ${media.type.displayName}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          if (media.overview.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              media.overview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppTheme.surfaceBorder),
            ListTile(
              leading: const Icon(
                Icons.bookmark_add_rounded,
                color: Color(0xFFE040FB),
              ),
              title: const Text('Zur Merkliste hinzufügen'),
              onTap: () async {
                context.pop();
                final repo = ref.read(watchlistRepositoryProvider);
                await repo.init();
                await repo.addMedia(media);
                ref.invalidate(watchlistEntriesProvider);
                if (context.mounted) {
                  AppSnackBar.showAccent(
                    context,
                    '${media.title} zur Merkliste hinzugefügt',
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppTheme.success,
              ),
              title: const Text('Als gesehen markieren'),
              onTap: () {
                context.pop();
                context.push('/media.type/media.id');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: AppTheme.error),
              title: const Text('Nicht interessiert'),
              onTap: () async {
                context.pop();
                final repo = ref.read(dismissedRepositoryProvider);
                await repo.init();
                await repo.dismiss('${media.type.name}_${media.id}');
                ref.invalidate(dismissedMediaIdsProvider);
                if (context.mounted) {
                  AppSnackBar.showNeutral(
                    context,
                    '${media.title} ausgeblendet',
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
