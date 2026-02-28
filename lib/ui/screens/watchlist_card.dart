import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../../data/models/watchlist_entry.dart';
import '../theme/app_theme.dart';

class WatchlistCard extends StatelessWidget {
  final WatchlistEntry entry;
  final VoidCallback onTap;

  const WatchlistCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Row(
          children: [
            // Poster
            Hero(
              tag: 'watchlist_poster_${entry.mediaType.name}_${entry.mediaId}',
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppTheme.radiusMedium),
                ),
                child: entry.posterPath != null
                    ? CachedNetworkImage(
                        imageUrl: entry.fullPosterPath,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 120,
                        color: AppTheme.surfaceLight,
                        child: const Icon(
                          Icons.movie_rounded,
                          color: AppTheme.textMuted,
                        ),
                      ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag:
                          'watchlist_title_${entry.mediaType.name}_${entry.mediaId}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          entry.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.mediaType.displayName,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ),
                        if (entry.voteAverage != null) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFFFD740),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            entry.voteAverage!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD740),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.watchlistAddedAgo(entry.addedAgo),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chevron
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
