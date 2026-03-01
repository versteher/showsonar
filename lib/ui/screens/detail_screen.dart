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

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: detailsAsync.when(
            data: (media) => _buildContent(
              context,
              ref,
              media,
              similarAsync,
              watchEntryAsync,
            ),
            loading: () => const DetailLoadingState(),
            error: (_, _) =>
                DetailErrorState(mediaId: mediaId, mediaType: mediaType),
          ),
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
    final l10n = AppLocalizations.of(context)!;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // Backdrop app bar
        SliverAppBar(
          expandedHeight: 280,
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
            tooltip: l10n.semanticBackButton,
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (media.backdropPath != null)
                  Hero(
                    tag:
                        '${heroTagPrefix != null ? '${heroTagPrefix}_' : ''}poster_${media.type.name}_${media.id}',
                    flightShuttleBuilder:
                        (
                          flightContext,
                          animation,
                          flightDirection,
                          fromHeroContext,
                          toHeroContext,
                        ) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              final isPush =
                                  flightDirection == HeroFlightDirection.push;
                              final poster = isPush
                                  ? fromHeroContext.widget
                                  : toHeroContext.widget;
                              final backdrop = isPush
                                  ? toHeroContext.widget
                                  : fromHeroContext.widget;

                              // Curve the animation for a smoother feel
                              final curvedValue = Curves.easeInOut.transform(
                                animation.value,
                              );

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Opacity(
                                    opacity: isPush
                                        ? 1.0 - curvedValue
                                        : curvedValue,
                                    child: poster,
                                  ),
                                  Opacity(
                                    opacity: isPush
                                        ? curvedValue
                                        : 1.0 - curvedValue,
                                    child: backdrop,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                    child: Semantics(
                      label: l10n.semanticBackdropOf(media.title),
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
              ],
            ),
          ),
        ),

        // Always-visible: title + actions + personal rating
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMd,
              AppTheme.spacingMd,
              AppTheme.spacingMd,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailTitleSection(media: media, heroTagPrefix: heroTagPrefix),
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
                      _confirmRemoveFromHistory(context, ref, media),
                ),
                if (watchEntry != null) ...[
                  const SizedBox(height: AppTheme.spacingMd),
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
                ],
                const SizedBox(height: AppTheme.spacingMd),
              ],
            ),
          ),
        ),

        // Sticky tab bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabBarDelegate(
            TabBar(
              tabs: [
                Tab(text: l10n.detailTabAbout),
                Tab(text: l10n.detailTabCast),
                Tab(text: l10n.detailTabStreaming),
                Tab(text: l10n.detailTabSimilar),
              ],
              isScrollable: false,
              indicatorColor: AppTheme.primary,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textMuted,
              dividerColor: AppTheme.surfaceLight,
            ),
          ),
        ),
      ],
      body: TabBarView(
        children: [
          // --- About tab: overview, genres, AI insight, trailer ---
          ListView(
            key: const PageStorageKey('detail_about'),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            children: [
              _buildOverviewSection(context, media),
              const SizedBox(height: AppTheme.spacingLg),
              _buildGenresSection(context, media),
              const SizedBox(height: AppTheme.spacingLg),
              AiWhyWatchCard(media: media),
              const SizedBox(height: AppTheme.spacingLg),
              TrailerButton(mediaId: media.id, mediaType: media.type),
              const SizedBox(height: 80),
            ],
          ),

          // --- Cast & Crew tab ---
          ListView(
            key: const PageStorageKey('detail_cast'),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            children: [
              CastCrewSection(media: media),
              const SizedBox(height: 80),
            ],
          ),

          // --- Where to Watch tab ---
          ListView(
            key: const PageStorageKey('detail_streaming'),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            children: [
              StreamingAvailabilityWidget(
                mediaId: media.id,
                mediaType: media.type,
                mediaTitle: media.title,
              ),
              const SizedBox(height: 80),
            ],
          ),

          // --- Similar tab ---
          ListView(
            key: const PageStorageKey('detail_similar'),
            padding: const EdgeInsets.only(top: AppTheme.spacingMd, bottom: 80),
            children: [
              similarAsync.when(
                data: (items) => items.isNotEmpty
                    ? MediaSection(
                        title: media.type == MediaType.movie
                            ? l10n.detailSimilarMovies
                            : l10n.detailSimilarShows,
                        items: items,
                        onMediaTap: (similar, prefix) {
                          final typePath = similar.type == MediaType.movie
                              ? 'movie'
                              : 'tv';
                          context.pushReplacement(
                            '/$typePath/${similar.id}',
                            extra: {'heroTagPrefix': prefix},
                          );
                        },
                      )
                    : const SizedBox.shrink(),
                loading: () => MediaSection(
                  title: l10n.detailSimilarContent,
                  items: const [],
                  isLoading: true,
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
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

      ref.invalidate(watchHistoryEntryProvider(id: media.id, type: media.type));
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
      ref.invalidate(watchHistoryEntryProvider(id: media.id, type: media.type));
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

/// Keeps the TabBar pinned below the collapsing header in a NestedScrollView.
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(color: AppTheme.background, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}
