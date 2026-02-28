import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/ui/theme/app_theme.dart';

/// Displays overall watch progress across all seasons of a TV series.
class EpisodeTrackingProgressHeader extends ConsumerWidget {
  final int tvId;
  final int numberOfSeasons;
  final Set<String> watchedKeys;

  const EpisodeTrackingProgressHeader({
    super.key,
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
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
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
              backgroundColor: Colors.white.withValues(alpha: 0.1),
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
