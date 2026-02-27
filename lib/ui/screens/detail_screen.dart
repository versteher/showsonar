import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../../data/models/genre.dart';
import '../../data/models/watch_history_entry.dart';
import '../../utils/app_haptics.dart';
import '../theme/app_theme.dart';
import '../widgets/media_section.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/streaming_availability_widget.dart';
import '../widgets/app_page_route.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/rt_scores_badge.dart';
import '../widgets/ai_why_watch_card.dart';
import '../widgets/trailer_button.dart';
import '../widgets/watchlist_button.dart';
import '../widgets/cast_crew_section.dart';

/// Detail screen for movie or TV series
class DetailScreen extends ConsumerWidget {
  final int mediaId;
  final MediaType mediaType;
  final String? heroTagPrefix;

  const DetailScreen({
    super.key,
    required this.mediaId,
    required this.mediaType,
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(
      mediaDetailsProvider((id: mediaId, type: mediaType)),
    );
    final similarAsync = ref.watch(
      similarContentProvider((id: mediaId, type: mediaType)),
    );
    final watchEntryAsync = ref.watch(
      watchHistoryEntryProvider((id: mediaId, type: mediaType)),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: detailsAsync.when(
          data: (media) =>
              _buildContent(context, ref, media, similarAsync, watchEntryAsync),
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(context, error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Media media,
    AsyncValue<List<Media>> similarAsync,
    AsyncValue<WatchHistoryEntry?> watchEntryAsync,
  ) {
    final watchEntry = watchEntryAsync.valueOrNull;
    final isWide = AppTheme.isTablet(context) || AppTheme.isDesktop(context);

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels < -100 &&
            notification.dragDetails != null) {
          if (ModalRoute.of(context)?.isCurrent == true) {
            AppHaptics.lightImpact();
            context.pop();
          }
          return true;
        }
        return false;
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Header with backdrop
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded, size: 18),
              ),
              tooltip: AppLocalizations.of(context)!.semanticBackButton,
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop Image
                  if (media.backdropPath != null)
                    Hero(
                      tag: isWide
                          ? 'backdrop_${media.type.name}_${media.id}'
                          : '${heroTagPrefix != null ? '${heroTagPrefix}_' : ''}poster_${media.type.name}_${media.id}',
                      child: Semantics(
                        label: AppLocalizations.of(
                          context,
                        )!.semanticBackdropOf(media.title),
                        image: true,
                        child: CachedNetworkImage(
                          imageUrl: media.fullBackdropPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // Gradient Overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black87,
                          AppTheme.background,
                        ],
                        stops: [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Watched badge
                  if (watchEntry != null)
                    Positioned(
                      top: 100,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Gesehen',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            if (watchEntry.isRated) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${watchEntry.userRating!.toStringAsFixed(1)} ⭐',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn().slideX(begin: 0.2, end: 0),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Poster + Actions + Streaming
                        SizedBox(
                          width: 280,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildPoster(context, media, isWide),
                              const SizedBox(height: AppTheme.spacingMd),
                              _buildActionButtons(
                                context,
                                ref,
                                media,
                                watchEntry,
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              if (watchEntry != null)
                                _buildPersonalRatingCard(
                                  context,
                                  ref,
                                  media,
                                  watchEntry,
                                ),
                              const SizedBox(height: AppTheme.spacingMd),
                              StreamingAvailabilityWidget(
                                mediaId: media.id,
                                mediaType: media.type,
                                mediaTitle: media.title,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingLg),
                        // Right Column: Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitleSection(context, ref, media),
                              const SizedBox(height: AppTheme.spacingLg),
                              _buildOverviewSection(context, media),
                              const SizedBox(height: AppTheme.spacingLg),
                              AiWhyWatchCard(media: media),
                              const SizedBox(height: AppTheme.spacingLg),
                              TrailerButton(
                                mediaId: media.id,
                                mediaType: media.type,
                              ),
                              const SizedBox(height: AppTheme.spacingLg),
                              _buildGenresSection(context, media),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Info
                        _buildTitleSection(context, ref, media),
                        const SizedBox(height: AppTheme.spacingLg),
                        // Actions
                        _buildActionButtons(context, ref, media, watchEntry),
                        _buildTrackEpisodesButton(context, media),
                        const SizedBox(height: AppTheme.spacingLg),
                        // Personal rating card (if watched)
                        if (watchEntry != null)
                          _buildPersonalRatingCard(
                            context,
                            ref,
                            media,
                            watchEntry,
                          ),
                        // Overview
                        _buildOverviewSection(context, media),
                        const SizedBox(height: AppTheme.spacingLg),
                        // AI Recommendation
                        AiWhyWatchCard(media: media),
                        const SizedBox(height: AppTheme.spacingLg),
                        // Trailer button
                        TrailerButton(mediaId: media.id, mediaType: media.type),
                        const SizedBox(height: AppTheme.spacingLg),
                        // Genres
                        _buildGenresSection(context, media),
                        const SizedBox(height: AppTheme.spacingLg),
                        // Streaming availability
                        StreamingAvailabilityWidget(
                          mediaId: media.id,
                          mediaType: media.type,
                          mediaTitle: media.title,
                        ),
                      ],
                    ),
            ),
          ),

          SliverToBoxAdapter(child: CastCrewSection(media: media)),

          // Similar Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacingLg),
              child: similarAsync.when(
                data: (items) => items.isNotEmpty
                    ? MediaSection(
                        title: media.type == MediaType.movie
                            ? AppLocalizations.of(context)!.detailSimilarMovies
                            : AppLocalizations.of(context)!.detailSimilarShows,
                        items: items,
                        onMediaTap: (similar, prefix) {
                          Navigator.of(context).pushReplacement(
                            AppPageRoute(
                              page: DetailScreen(
                                mediaId: similar.id,
                                mediaType: similar.type,
                                heroTagPrefix: prefix,
                              ),
                            ),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
                loading: () => MediaSection(
                  title: AppLocalizations.of(context)!.detailSimilarContent,
                  items: [],
                  isLoading: true,
                ),
                error: (error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingXl)),
        ],
      ),
    );
  }

  Widget _buildPoster(BuildContext context, Media media, bool isWide) {
    if (!isWide) return const SizedBox.shrink();

    final child = ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: media.posterPath != null
          ? CachedNetworkImage(
              imageUrl: media.fullPosterPath,
              fit: BoxFit.cover,
            )
          : Container(
              height: 420,
              color: AppTheme.surfaceLight,
              child: const Center(
                child: Icon(Icons.movie, size: 60, color: AppTheme.textMuted),
              ),
            ),
    );

    return Hero(
      tag:
          '${heroTagPrefix != null ? '${heroTagPrefix}_' : ''}poster_${media.type.name}_${media.id}',
      child: Material(type: MaterialType.transparency, child: child),
    );
  }

  Widget _buildTitleSection(BuildContext context, WidgetRef ref, Media media) {
    // Filter providers based on user preferences
    final userPrefs = ref.watch(userPreferencesProvider).valueOrNull;
    final userProviderIds = userPrefs?.tmdbProviderIds ?? [];

    final displayedProviders = media.providerData.where((p) {
      if (userProviderIds.isEmpty) return true;
      return userProviderIds.contains(p.id);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
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

        // Info Row
        Row(
          children: [
            // IMDB Rating
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

            // Year
            Text(media.year, style: Theme.of(context).textTheme.bodyMedium),

            const SizedBox(width: AppTheme.spacingMd),

            // Type
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

            // FSK Badge
            _buildFskBadge(context, media),
          ],
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

        // Rotten Tomatoes + Metacritic scores
        const SizedBox(height: AppTheme.spacingSm),
        RtScoresBadge(
          imdbId: media.imdbId,
          title: media.title,
          year: int.tryParse(media.year),
        ),

        // Provider Icons
        if (displayedProviders.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingMd),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: displayedProviders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                            errorBuilder: (context, error, stack) => const Icon(
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

  Widget _buildFskBadge(BuildContext context, Media media) {
    if (media.ageRating == null) return const SizedBox.shrink();

    final ageLevel = media.ageLevel;
    Color color;

    // Generalized color mapping based on age intensity
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
      // Unrated (100) or unknown
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

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    Media media,
    WatchHistoryEntry? watchEntry,
  ) {
    final isWatched = watchEntry != null;
    final isOnWatchlistAsync = ref.watch(
      isOnWatchlistProvider((id: media.id, type: media.type)),
    );
    final isOnWatchlist = isOnWatchlistAsync.valueOrNull ?? false;

    return Row(
      children: [
        // Watchlist Bookmark Button
        WatchlistButton(
          isOnWatchlist: isOnWatchlist,
          mediaTitle: media.title,
          onToggle: () async {
            final repo = ref.read(watchlistRepositoryProvider);
            await repo.init();

            if (isOnWatchlist) {
              await repo.removeFromWatchlist(media.id, media.type);
            } else {
              await repo.addMedia(media);
            }

            ref.invalidate(
              isOnWatchlistProvider((id: media.id, type: media.type)),
            );
            ref.invalidate(watchlistEntriesProvider);

            if (context.mounted) {
              AppSnackBar.showAccent(
                context,
                isOnWatchlist
                    ? AppLocalizations.of(
                        context,
                      )!.detailWatchlistRemoved(media.title)
                    : AppLocalizations.of(
                        context,
                      )!.detailWatchlistAdded(media.title),
                icon: isOnWatchlist
                    ? Icons.bookmark_remove_rounded
                    : Icons.bookmark_added_rounded,
              );
            }
          },
        ),

        const SizedBox(width: AppTheme.spacingSm),

        // Watch/Rate Button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () =>
                _showRatingAndMarkWatched(context, ref, media, watchEntry),
            style: ElevatedButton.styleFrom(
              backgroundColor: isWatched ? AppTheme.success : AppTheme.primary,
            ),
            icon: Icon(
              isWatched
                  ? Icons.edit_rounded
                  : Icons.check_circle_outline_rounded,
            ),
            label: Text(
              isWatched
                  ? AppLocalizations.of(context)!.detailChangeRating
                  : AppLocalizations.of(context)!.detailMarkWatched,
            ),
          ),
        ),

        if (isWatched) ...[
          const SizedBox(width: AppTheme.spacingSm),

          // Remove from history
          Semantics(
            button: true,
            label: AppLocalizations.of(
              context,
            )!.semanticDeleteFromHistory(media.title),
            child: OutlinedButton(
              onPressed: () => _confirmRemoveFromHistory(context, ref, media),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
              ),
              child: const Icon(Icons.delete_outline_rounded),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  /// Builds the "Track Episodes" button shown below the action row for TV series.
  Widget _buildTrackEpisodesButton(BuildContext context, Media media) {
    if (media.type != MediaType.tv) return const SizedBox.shrink();
    final seasons = media.numberOfSeasons;
    if (seasons == null || seasons == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacingSm),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push(
              '/tv/${media.id}/episodes',
              extra: {
                'seriesTitle': media.title,
                'numberOfSeasons': seasons,
                'posterPath': media.posterPath,
              },
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.accent,
            side: BorderSide(color: AppTheme.accent.withOpacity(0.6)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.format_list_numbered_rounded),
          label: Text(
            'Track Episodes  •  $seasons season${seasons == 1 ? '' : 's'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 250.ms, duration: 400.ms);
  }

  Widget _buildPersonalRatingCard(
    BuildContext context,
    WidgetRef ref,
    Media media,
    WatchHistoryEntry entry,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.15),
            AppTheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.detailMyRating,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                entry.watchedAgo,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),

          Row(
            children: [
              // Personal rating
              if (entry.isRated) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getRatingColor(
                      entry.userRating!,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.getRatingColor(
                        entry.userRating!,
                      ).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (i) {
                        final starValue = (i + 1) * 2;
                        return Icon(
                          starValue <= entry.userRating!
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 18,
                          color: AppTheme.getRatingColor(entry.userRating!),
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        entry.userRating!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getRatingColor(entry.userRating!),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: () =>
                      _showRatingAndMarkWatched(context, ref, media, entry),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_outline_rounded,
                          color: AppTheme.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.detailRateNow,
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Notes
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms);
  }

  Future<void> _showRatingAndMarkWatched(
    BuildContext context,
    WidgetRef ref,
    Media media,
    WatchHistoryEntry? existingEntry,
  ) async {
    final result = await RatingDialog.show(
      context,
      title: media.title,
      initialRating: existingEntry?.userRating,
      initialNotes: existingEntry?.notes,
      posterUrl: media.posterPath != null
          ? 'https://image.tmdb.org/t/p/w200${media.posterPath}'
          : null,
    );

    if (result != null) {
      final repo = ref.read(watchHistoryRepositoryProvider);
      await repo.init();

      if (existingEntry != null) {
        // Update existing entry
        final updated = existingEntry.copyWith(
          userRating: result.rating,
          notes: result.notes,
        );
        await repo.updateEntry(updated);
      } else {
        // Add new entry
        final entry = WatchHistoryEntry(
          mediaId: media.id,
          mediaType: media.type,
          title: media.title,
          posterPath: media.posterPath,
          voteAverage: media.voteAverage,
          watchedAt: DateTime.now(),
          userRating: result.rating,
          notes: result.notes,
        );
        await repo.addToHistory(entry);

        // Show success animation for first-time rating
        if (context.mounted) {
          _showSuccessAnimation(context);
        }
      }

      ref.invalidate(
        watchHistoryEntryProvider((id: media.id, type: media.type)),
      );
    }
  }

  void _showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        return Center(
          child: Lottie.asset(
            'assets/animations/success.json',
            width: 250,
            height: 250,
            repeat: false,
          ),
        );
      },
    );
  }

  Future<void> _confirmRemoveFromHistory(
    BuildContext context,
    WidgetRef ref,
    Media media,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(AppLocalizations.of(context)!.detailRemoveHistoryTitle),
        content: Text(
          AppLocalizations.of(context)!.detailRemoveHistoryContent(media.title),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(AppLocalizations.of(context)!.detailCancel),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(AppLocalizations.of(context)!.detailRemove),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(watchHistoryRepositoryProvider);
      await repo.init();
      await repo.removeFromHistory(media.id, media.type);

      // Refresh providers
      ref.invalidate(
        watchHistoryEntryProvider((id: media.id, type: media.type)),
      );
      ref.invalidate(watchHistoryEntriesProvider);

      if (context.mounted) {
        AppSnackBar.showNeutral(
          context,
          AppLocalizations.of(context)!.detailHistoryRemoved(media.title),
        );
      }
    }
  }

  Widget _buildOverviewSection(BuildContext context, Media media) {
    if (media.overview.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.detailPlot,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          media.overview,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildGenresSection(BuildContext context, Media media) {
    if (media.genreIds.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.detailGenres,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: media.genreIds.map((id) {
            final genreName = Genre.getNameById(id);
            return Chip(
              label: Text(genreName),
              backgroundColor: AppTheme.surfaceLight,
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          backgroundColor: AppTheme.background,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(color: AppTheme.surface),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 28,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(
                  4,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Fehler beim Laden',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Details konnten nicht geladen werden',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Zurück'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.replace('/$mediaType/$mediaId');
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Erneut versuchen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
