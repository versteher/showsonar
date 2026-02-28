import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:stream_scout/l10n/app_localizations.dart';

import '../../config/providers.dart';
import '../../data/models/genre.dart';
import '../../data/models/media.dart';
import '../../data/models/watch_history_entry.dart';
import '../../utils/app_haptics.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_why_watch_card.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/cast_crew_section.dart';
import '../widgets/media_section.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/streaming_availability_widget.dart';
import '../widgets/trailer_button.dart';
import 'detail_action_row.dart';
import 'detail_personal_rating_card.dart';
import 'detail_states.dart';
import 'detail_title_section.dart';

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
      mediaDetailsProvider(id: mediaId, type: mediaType),
    );
    final similarAsync = ref.watch(
      similarContentProvider(id: mediaId, type: mediaType),
    );
    final watchEntryAsync = ref.watch(
      watchHistoryEntryProvider(id: mediaId, type: mediaType),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: detailsAsync.when(
          data: (media) =>
              _buildContent(context, ref, media, similarAsync, watchEntryAsync),
          loading: () => const DetailLoadingState(),
          error: (_, _) =>
              DetailErrorState(mediaId: mediaId, mediaType: mediaType),
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 280,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildPoster(media, isWide),
                              const SizedBox(height: AppTheme.spacingMd),
                              DetailActionRow(
                                media: media,
                                watchEntry: watchEntry,
                                onShowRating: () => _showRatingAndMarkWatched(
                                  context,
                                  ref,
                                  media,
                                  watchEntry,
                                ),
                                onConfirmRemove: () =>
                                    _confirmRemoveFromHistory(
                                      context,
                                      ref,
                                      media,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              if (watchEntry != null)
                                DetailPersonalRatingCard(
                                  media: media,
                                  entry: watchEntry,
                                  onRatingTapped: () =>
                                      _showRatingAndMarkWatched(
                                        context,
                                        ref,
                                        media,
                                        watchEntry,
                                      ),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DetailTitleSection(
                                media: media,
                                heroTagPrefix: heroTagPrefix,
                              ),
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
                        DetailTitleSection(
                          media: media,
                          heroTagPrefix: heroTagPrefix,
                        ),
                        const SizedBox(height: AppTheme.spacingLg),
                        DetailActionRow(
                          media: media,
                          watchEntry: watchEntry,
                          onShowRating: () => _showRatingAndMarkWatched(
                            context,
                            ref,
                            media,
                            watchEntry,
                          ),
                          onConfirmRemove: () =>
                              _confirmRemoveFromHistory(context, ref, media),
                        ),
                        const SizedBox(height: AppTheme.spacingLg),
                        if (watchEntry != null)
                          DetailPersonalRatingCard(
                            media: media,
                            entry: watchEntry,
                            onRatingTapped: () => _showRatingAndMarkWatched(
                              context,
                              ref,
                              media,
                              watchEntry,
                            ),
                          ),
                        _buildOverviewSection(context, media),
                        const SizedBox(height: AppTheme.spacingLg),
                        AiWhyWatchCard(media: media),
                        const SizedBox(height: AppTheme.spacingLg),
                        TrailerButton(mediaId: media.id, mediaType: media.type),
                        const SizedBox(height: AppTheme.spacingLg),
                        _buildGenresSection(context, media),
                        const SizedBox(height: AppTheme.spacingLg),
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacingLg),
              child: similarAsync.when(
                data: (items) => items.isNotEmpty
                    ? MediaSection(
                        title: media.type == MediaType.movie
                            ? AppLocalizations.of(
                                context,
                              )!.detailSimilarMovies
                            : AppLocalizations.of(
                                context,
                              )!.detailSimilarShows,
                        items: items,
                        onMediaTap: (similar, prefix) {
                          final typePath =
                              similar.type == MediaType.movie ? 'movie' : 'tv';
                          context.pushReplacement(
                            '/$typePath/${similar.id}',
                            extra: {'heroTagPrefix': prefix},
                          );
                        },
                      )
                    : const SizedBox.shrink(),
                loading: () => MediaSection(
                  title:
                      AppLocalizations.of(context)!.detailSimilarContent,
                  items: [],
                  isLoading: true,
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingXl)),
        ],
      ),
    );
  }

  Widget _buildPoster(Media media, bool isWide) {
    if (!isWide) return const SizedBox.shrink();

    final child = ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: media.posterPath != null
          ? CachedNetworkImage(imageUrl: media.fullPosterPath, fit: BoxFit.cover)
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(height: 1.6),
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
        await repo.updateEntry(
          existingEntry.copyWith(
            userRating: result.rating,
            notes: result.notes,
          ),
        );
      } else {
        await repo.addToHistory(
          WatchHistoryEntry(
            mediaId: media.id,
            mediaType: media.type,
            title: media.title,
            posterPath: media.posterPath,
            voteAverage: media.voteAverage,
            watchedAt: DateTime.now(),
            userRating: result.rating,
            notes: result.notes,
          ),
        );
        if (context.mounted) {
          _showSuccessAnimation(context);
        }
      }

      ref.invalidate(
        watchHistoryEntryProvider(id: media.id, type: media.type),
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
          if (context.mounted) context.pop();
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
          AppLocalizations.of(
            context,
          )!.detailRemoveHistoryContent(media.title),
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
      ref.invalidate(
        watchHistoryEntryProvider(id: media.id, type: media.type),
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
}
