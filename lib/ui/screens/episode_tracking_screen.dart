import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/ui/theme/app_theme.dart';
import 'package:neon_voyager/ui/widgets/episode_tracking_progress_header.dart';
import 'package:neon_voyager/ui/widgets/season_expansion_tile.dart';

/// Full-screen episode tracking UI for a TV series.
/// Shows season-by-season progress with per-episode checkboxes,
/// future episode countdowns, and an overall completion bar.
class EpisodeTrackingScreen extends ConsumerWidget {
  final int tvId;
  final String seriesTitle;
  final int numberOfSeasons;
  final String? posterPath;

  const EpisodeTrackingScreen({
    super.key,
    required this.tvId,
    required this.seriesTitle,
    required this.numberOfSeasons,
    this.posterPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedAsync = ref.watch(watchedEpisodesProvider(tvId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: watchedAsync.when(
              data: (watchedKeys) => _buildContent(context, ref, watchedKeys),
              loading: () => const Padding(
                padding: EdgeInsets.all(64),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Failed to load tracking data: $e',
                  style: const TextStyle(color: AppTheme.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      backgroundColor: AppTheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          seriesTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (posterPath != null)
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.surface],
                ).createShader(bounds),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w780$posterPath',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.surface],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Set<String> watchedKeys,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total progress across all seasons
          EpisodeTrackingProgressHeader(
            tvId: tvId,
            numberOfSeasons: numberOfSeasons,
            watchedKeys: watchedKeys,
          ),
          const SizedBox(height: 16),
          // Season list
          ...List.generate(
            numberOfSeasons,
            (i) => SeasonExpansionTile(
              tvId: tvId,
              seasonNumber: i + 1,
              watchedKeys: watchedKeys,
              onToggle: (ep, watched) async {
                HapticFeedback.mediumImpact();
                final repo = ref.read(episodeTrackingRepositoryProvider);
                if (watched) {
                  await repo.markEpisodeWatched(
                    tvId,
                    ep.seasonNumber,
                    ep.episodeNumber,
                  );
                } else {
                  await repo.unmarkEpisodeWatched(
                    tvId,
                    ep.seasonNumber,
                    ep.episodeNumber,
                  );
                }
                ref.invalidate(watchedEpisodesProvider(tvId));
              },
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
