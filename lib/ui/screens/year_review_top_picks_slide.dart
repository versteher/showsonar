import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stream_scout/config/api_config.dart';

import '../../config/providers/year_in_review_provider.dart';
import '../theme/app_theme.dart';

class Slide3TopPicks extends StatelessWidget {
  const Slide3TopPicks({required this.data, super.key});
  final YearInReviewData data;

  @override
  Widget build(BuildContext context) {
    final entries = data.topRated;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingXl,
          80,
          AppTheme.spacingXl,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Top\nPicks',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
              ),
            ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.2, end: 0),

            const SizedBox(height: AppTheme.spacingXl),

            if (entries.isEmpty)
              Text(
                'Rate some titles to see your favourites here.',
                style: TextStyle(color: AppTheme.textMuted),
              )
            else
              ...entries.asMap().entries.map((mapEntry) {
                final i = mapEntry.key;
                final entry = mapEntry.value;
                final posterUrl = entry.posterPath != null
                    ? '${ApiConfig.tmdbImageBaseUrl}/${ApiConfig.posterSizeMedium}${entry.posterPath}'
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          _medal(i),
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                        child: posterUrl != null
                            ? CachedNetworkImage(
                                imageUrl: posterUrl,
                                width: 48,
                                height: 72,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) =>
                                    const _PosterPlaceholder(),
                              )
                            : const _PosterPlaceholder(),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppTheme.warning,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  entry.userRating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppTheme.warning,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.mediaType.displayName,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 150 + i * 100),
                  duration: 400.ms,
                );
              }),
          ],
        ),
      ),
    );
  }

  String _medal(int index) {
    return switch (index) {
      0 => '🥇',
      1 => '🥈',
      2 => '🥉',
      _ => '${index + 1}.',
    };
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 72,
      color: AppTheme.surface,
      child: const Icon(Icons.movie_rounded, color: AppTheme.textMuted),
    );
  }
}
