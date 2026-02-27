import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/tv_season.dart';
import 'package:neon_voyager/data/models/tv_episode.dart';
import 'package:neon_voyager/data/repositories/episode_tracking_repository.dart';
import 'package:neon_voyager/ui/theme/app_theme.dart';

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
                  errorBuilder: (_, __, ___) => const SizedBox(),
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
          _OverallProgressHeader(
            tvId: tvId,
            numberOfSeasons: numberOfSeasons,
            watchedKeys: watchedKeys,
          ),
          const SizedBox(height: 16),
          // Season list
          ...List.generate(
            numberOfSeasons,
            (i) => _SeasonExpansionTile(
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

// ---------------------------------------------------------------------------
// Overall progress header widget
// ---------------------------------------------------------------------------

class _OverallProgressHeader extends ConsumerWidget {
  final int tvId;
  final int numberOfSeasons;
  final Set<String> watchedKeys;

  const _OverallProgressHeader({
    required this.tvId,
    required this.numberOfSeasons,
    required this.watchedKeys,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Count total aired episodes across all seasons
    int totalAired = 0;
    for (int s = 1; s <= numberOfSeasons; s++) {
      final seasonAsync = ref.watch(
        tvSeasonProvider((tvId: tvId, seasonNumber: s)),
      );
      seasonAsync.whenData((season) => totalAired += season.airedEpisodeCount);
    }

    final watched = watchedKeys.length;
    final fraction = totalAired == 0 ? 0.0 : watched / totalAired;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$watched${totalAired > 0 ? ' / $totalAired' : ''} episodes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                fraction >= 1.0 ? AppTheme.success : AppTheme.accent,
              ),
              minHeight: 8,
            ),
          ),
          if (fraction >= 1.0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Series complete!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Season expansion tile
// ---------------------------------------------------------------------------

class _SeasonExpansionTile extends ConsumerWidget {
  final int tvId;
  final int seasonNumber;
  final Set<String> watchedKeys;
  final void Function(TvEpisode ep, bool watched) onToggle;

  const _SeasonExpansionTile({
    required this.tvId,
    required this.seasonNumber,
    required this.watchedKeys,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonAsync = ref.watch(
      tvSeasonProvider((tvId: tvId, seasonNumber: seasonNumber)),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: seasonAsync.when(
        data: (season) => _buildSeasonTile(context, season),
        loading: () => Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accent,
              ),
            ),
          ),
        ),
        error: (e, _) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSeasonTile(BuildContext context, TvSeason season) {
    final airedEps = season.episodes.where((e) => e.hasAired).toList();
    final watchedInSeason = airedEps
        .where(
          (e) => watchedKeys.contains(
            EpisodeTrackingRepository.episodeKey(
              e.seasonNumber,
              e.episodeNumber,
            ),
          ),
        )
        .length;
    final fraction = airedEps.isEmpty ? 0.0 : watchedInSeason / airedEps.length;

    final nextUnwatched = nextUnwatchedInSeason(season, watchedKeys);
    final nextAiring = season.nextUnaired;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction.clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                fraction >= 1.0
                                    ? AppTheme.success
                                    : AppTheme.accent,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$watchedInSeason/${airedEps.length}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (nextAiring != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _nextAirText(nextAiring),
                        style: TextStyle(
                          color: AppTheme.warning.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          children: [
            const Divider(color: Colors.white12, height: 1),
            ...season.episodes.map(
              (ep) => _EpisodeRow(
                episode: ep,
                isWatched: watchedKeys.contains(
                  EpisodeTrackingRepository.episodeKey(
                    ep.seasonNumber,
                    ep.episodeNumber,
                  ),
                ),
                isNextUnwatched:
                    nextUnwatched != null &&
                    ep.episodeNumber == nextUnwatched.episodeNumber,
                onToggle: (watched) => onToggle(ep, watched),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nextAirText(TvEpisode ep) {
    final days = ep.daysUntilAir;
    if (days == 0) return 'Ep ${ep.episodeNumber} airs today!';
    if (days == 1) return 'Ep ${ep.episodeNumber} airs tomorrow';
    return 'Ep ${ep.episodeNumber} airs in $days days';
  }
}

// ---------------------------------------------------------------------------
// Individual episode row
// ---------------------------------------------------------------------------

class _EpisodeRow extends StatelessWidget {
  final TvEpisode episode;
  final bool isWatched;
  final bool isNextUnwatched;
  final void Function(bool watched) onToggle;

  const _EpisodeRow({
    required this.episode,
    required this.isWatched,
    required this.isNextUnwatched,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isFuture = !episode.hasAired;

    return Semantics(
      label:
          '${episode.name}, episode ${episode.episodeNumber}, season ${episode.seasonNumber}. ${isWatched ? 'Watched' : 'Not watched'}.',
      child: InkWell(
        onTap: isFuture ? null : () => onToggle(!isWatched),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isNextUnwatched
                ? AppTheme.accent.withOpacity(0.08)
                : Colors.transparent,
            border: isNextUnwatched
                ? Border(left: BorderSide(color: AppTheme.accent, width: 3))
                : null,
          ),
          child: Row(
            children: [
              // Episode number
              SizedBox(
                width: 36,
                child: Text(
                  '${episode.episodeNumber}',
                  style: TextStyle(
                    color: isFuture
                        ? Colors.white24
                        : Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              // Episode name + air date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.name,
                      style: TextStyle(
                        color: isFuture ? Colors.white24 : Colors.white,
                        fontSize: 13,
                        fontWeight: isNextUnwatched
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isFuture && episode.airDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(episode.airDate!),
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (!isFuture && episode.runtime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${episode.runtime} min',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Watched indicator / future lock
              if (!isFuture)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isWatched
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    key: ValueKey(isWatched),
                    color: isWatched
                        ? AppTheme.success
                        : Colors.white.withOpacity(0.3),
                    size: 22,
                    semanticLabel: isWatched ? 'Watched' : 'Not watched',
                  ),
                )
              else
                Icon(
                  Icons.lock_clock_outlined,
                  color: Colors.white.withOpacity(0.2),
                  size: 20,
                  semanticLabel: 'Not yet aired',
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
