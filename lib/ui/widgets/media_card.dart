import 'package:stream_scout/utils/app_haptics.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:stream_scout/l10n/app_localizations.dart';
import '../../data/models/media.dart';
import '../../config/providers.dart';
import '../theme/app_theme.dart';
import 'rt_scores_badge.dart';

/// A premium movie/series poster card with glassmorphism effect
class MediaCard extends ConsumerWidget {
  final Media media;
  final VoidCallback? onTap;
  final void Function(Media media)? onLongPress;
  final double width;
  final bool showTitle;
  final bool showRating;
  final bool isWatched;
  final bool enableHero;
  final String? heroTagPrefix;

  const MediaCard({
    super.key,
    required this.media,
    this.onTap,
    this.onLongPress,
    this.width = AppTheme.posterWidthMedium,
    this.showTitle = true,
    this.showRating = true,
    this.isWatched = false,
    this.enableHero = true,
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = width / AppTheme.posterAspectRatio;
    // Logo icons come directly from the user's subscribed services —
    // no extra getWatchProviders API call per card. The content appeared
    // via the discover filter so the selected provider logos are the
    // correct context to show. See docs/TMDB_DATA_NOTES.md.
    final prefsAsync = ref.watch(userPreferencesProvider);

    final l10n = AppLocalizations.of(context)!;
    final cardLabel = l10n.semanticMediaCard(
      media.title,
      media.type.displayName,
      media.voteAverage.toStringAsFixed(1),
    );

    return Semantics(
      button: onTap != null,
      label: cardLabel,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress != null
            ? () {
                AppHaptics.mediumImpact();
                onLongPress!(media);
              }
            : null,
        child: Container(
          width: width,
          // Let the title section size itself based on text scale instead of
          // a fixed 50px addition, so layouts don't break at 2× text scale.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poster Image
              SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    // Image — wrapped in Semantics so the poster label is
                    // available but the card-level label takes priority.
                    _wrapHero(
                      Semantics(
                        label: l10n.semanticPosterOf(media.title),
                        image: true,
                        excludeSemantics: true,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          child:
                              media.posterPath != null &&
                                  media.posterPath!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: media.fullPosterPath,
                                  width: width,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      _buildPlaceholder(),
                                  errorWidget: (context, url, error) =>
                                      _buildErrorWidget(),
                                )
                              : _buildErrorWidget(),
                        ),
                      ),
                    ),

                    // Gradient overlay for rating — purely decorative
                    if (showRating)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ExcludeSemantics(
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingSm),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(AppTheme.radiusMedium),
                                topRight: Radius.circular(
                                  AppTheme.radiusMedium,
                                ),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: prefsAsync.when(
                              data: (prefs) => prefs.showExtendedRatings
                                  ? RtScoresBadge(
                                      imdbId:
                                          null, // TMDB Discover usually doesn't return IMDb ID, use title
                                      title: media.title,
                                      year: int.tryParse(media.year),
                                    )
                                  : _buildRatingBadge(),
                              loading: () => _buildRatingBadge(),
                              error: (_, _) => _buildRatingBadge(),
                            ),
                          ),
                        ),
                      ),

                    // Selected providers overlay — max 2 logos + overflow count
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: ExcludeSemantics(
                        child: prefsAsync.when(
                          data: (prefs) {
                            final logos = prefs.subscribedServices
                                .where((p) => p.logoPath.isNotEmpty)
                                .toList();

                            if (logos.isEmpty) return const SizedBox.shrink();

                            const maxVisible = 2;
                            final visible = logos.take(maxVisible).toList();
                            final overflow = logos.length - maxVisible;

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...visible.map(
                                  (provider) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.asset(
                                          provider.logoPath,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stack) =>
                                                  const Icon(
                                                    Icons.play_circle,
                                                    size: 14,
                                                    color: Colors.white70,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (overflow > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '+$overflow',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),

                    // Watched overlay — decorative, card-level label covers it
                    if (isWatched) ...[
                      ExcludeSemantics(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: ExcludeSemantics(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context)!.mediaWatched,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Title, Year, and Runtime
              // No fixed height — lets text expand naturally at large text scales
              if (showTitle) ...[
                const SizedBox(height: AppTheme.spacingSm),
                _wrapHero(
                  Text(
                    media.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  isTitle: true,
                ),
                Row(
                  children: [
                    Text(
                      media.year,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (_runtimeText != null) ...[
                      Text(
                        ' · ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _runtimeText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrapHero(Widget child, {bool isTitle = false}) {
    if (!enableHero) return child;
    final prefix = heroTagPrefix != null ? '${heroTagPrefix}_' : '';
    final type = isTitle ? 'title' : 'poster';
    return Hero(
      tag: '$prefix${type}_${media.type.name}_${media.id}',
      child: Material(type: MaterialType.transparency, child: child),
    );
  }

  /// Formatted runtime text for movies (e.g. "1h 42m") or seasons for TV
  String? get _runtimeText {
    if (media.type == MediaType.movie &&
        media.runtime != null &&
        media.runtime! > 0) {
      final h = media.runtime! ~/ 60;
      final m = media.runtime! % 60;
      if (h > 0 && m > 0) return '${h}h ${m}m';
      if (h > 0) return '${h}h';
      return '${m}m';
    }
    if (media.type == MediaType.tv &&
        media.numberOfSeasons != null &&
        media.numberOfSeasons! > 0) {
      final s = media.numberOfSeasons!;
      return s == 1 ? '1 Season' : '$s Seasons';
    }
    return null;
  }

  Widget _buildRatingBadge() {
    final color = AppTheme.getRatingColor(media.voteAverage);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXs,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: color),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              media.voteAverage.toStringAsFixed(1),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      color: AppTheme.surface,
      child: const Center(
        child: Icon(Icons.movie_outlined, size: 40, color: AppTheme.textMuted),
      ),
    );
  }
}
