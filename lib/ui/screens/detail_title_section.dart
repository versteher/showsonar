import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';

import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';
import '../widgets/rt_scores_badge.dart';

class DetailTitleSection extends ConsumerWidget {
  const DetailTitleSection({
    super.key,
    required this.media,
    this.heroTagPrefix,
  });

  final Media media;
  final String? heroTagPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider).valueOrNull;
    final userProviderIds = userPrefs?.tmdbProviderIds ?? [];

    final displayedProviders = media.providerData.where((p) {
      if (userProviderIds.isEmpty) return true;
      return userProviderIds.contains(p.id);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag:
              '${heroTagPrefix != null ? '${heroTagPrefix}_' : ''}title_${media.type.name}_${media.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              media.title,
              style: Theme.of(context).textTheme.displaySmall,
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
          ),
        ),

        const SizedBox(height: AppTheme.spacingSm),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.getRatingColor(
                  media.voteAverage,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.getRatingColor(
                    media.voteAverage,
                  ).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'IMDB',
                    style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppTheme.getRatingColor(media.voteAverage),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    media.voteAverage.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.getRatingColor(media.voteAverage),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppTheme.spacingMd),
            Text(media.year, style: Theme.of(context).textTheme.bodyMedium),

            const SizedBox(width: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                media.type.displayName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),

            if (media.runtime != null) ...[
              const SizedBox(width: AppTheme.spacingMd),
              Text(
                '${media.runtime} min',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            const SizedBox(width: AppTheme.spacingMd),
            _FskBadge(media: media),
          ],
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

        const SizedBox(height: AppTheme.spacingSm),
        RtScoresBadge(
          imdbId: media.imdbId,
          title: media.title,
          year: int.tryParse(media.year),
        ),

        if (displayedProviders.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingMd),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: displayedProviders.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final logoUrl = displayedProviders[index].logoUrl;
                return Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: logoUrl.startsWith('assets/')
                        ? Image.asset(
                            logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                const Icon(
                                  Icons.movie,
                                  size: 14,
                                  color: Colors.white54,
                                ),
                          )
                        : CachedNetworkImage(
                            imageUrl: logoUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.white10,
                              child: const Center(
                                child: SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.movie,
                              size: 14,
                              color: Colors.white54,
                            ),
                          ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
        ],
      ],
    );
  }
}

class _FskBadge extends StatelessWidget {
  const _FskBadge({required this.media});
  final Media media;

  @override
  Widget build(BuildContext context) {
    if (media.ageRating == null) return const SizedBox.shrink();

    final ageLevel = media.ageLevel;
    final Color color;
    if (ageLevel >= 18 && ageLevel < 100) {
      color = Colors.red;
    } else if (ageLevel >= 16) {
      color = Colors.blue;
    } else if (ageLevel >= 12) {
      color = Colors.green;
    } else if (ageLevel >= 6) {
      color = Colors.yellow;
    } else if (ageLevel >= 0 && ageLevel < 100) {
      color = Colors.white;
    } else {
      color = AppTheme.textMuted;
    }

    if (ageLevel == 100) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Text(
          AppLocalizations.of(context)!.detailRatingUnknown,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        media.ageRating?.toUpperCase() ??
            AppLocalizations.of(context)!.detailAge(ageLevel),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
