import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/models/tv_episode.dart';
import 'package:stream_scout/data/models/tv_season.dart';
import 'package:stream_scout/data/repositories/episode_tracking_repository.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';

// Re-export the helper so callers don't need to import the providers file.
export 'package:stream_scout/config/providers.dart'
    show tvSeasonProvider, nextUnwatchedInSeason;

/// Expansion tile showing a single season's episodes and watch progress.
class SeasonExpansionTile extends ConsumerWidget {
  final int tvId;
  final int seasonNumber;
  final Set<String> watchedKeys;
  final void Function(TvEpisode ep, bool watched) onToggle;

  const SeasonExpansionTile({
    super.key,
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
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
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
                            color: Colors.white.withValues(alpha: 0.5),
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
                          color: AppTheme.warning.withValues(alpha: 0.9),
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
// Individual episode row (private — only used by SeasonExpansionTile)
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
                ? AppTheme.accent.withValues(alpha: 0.08)
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
                        : Colors.white.withValues(alpha: 0.5),
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
                          color: Colors.white.withValues(alpha: 0.35),
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
                        : Colors.white.withValues(alpha: 0.3),
                    size: 22,
                    semanticLabel: isWatched ? 'Watched' : 'Not watched',
                  ),
                )
              else
                Icon(
                  Icons.lock_clock_outlined,
                  color: Colors.white.withValues(alpha: 0.2),
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
