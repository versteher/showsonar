import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';

/// Card widget displaying an upcoming media item with countdown badge
class UpcomingCard extends StatelessWidget {
  final Media media;
  final VoidCallback? onTap;

  const UpcomingCard({super.key, required this.media, this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysUntil = media.releaseDate?.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with countdown
            Expanded(
              child: Stack(
                children: [
                  // Poster
                  Hero(
                    tag: 'upcoming_poster_${media.type.name}_${media.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      child: media.posterPath != null
                          ? CachedNetworkImage(
                              imageUrl: media.fullPosterPath,
                              width: 140,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 140,
                              color: AppTheme.surface,
                              child: const Center(
                                child: Icon(
                                  Icons.movie_outlined,
                                  color: AppTheme.textMuted,
                                  size: 32,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Neon border glow
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(
                          color: const Color(0xFF00E676).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // Countdown badge
                  if (daysUntil != null && daysUntil >= 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF00E676,
                              ).withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          daysUntil == 0
                              ? AppLocalizations.of(context)!.upcomingToday
                              : daysUntil == 1
                              ? AppLocalizations.of(context)!.upcomingTomorrow
                              : AppLocalizations.of(
                                  context,
                                )!.upcomingInDays(daysUntil),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Type badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        media.type.displayName,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Title
            Hero(
              tag: 'upcoming_title_${media.type.name}_${media.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  media.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Release date
            if (media.releaseDate != null)
              Text(
                '${media.releaseDate!.day}.${media.releaseDate!.month}.${media.releaseDate!.year}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF00E676),
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
