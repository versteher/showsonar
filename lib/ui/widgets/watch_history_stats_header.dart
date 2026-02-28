import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import '../../data/models/media.dart';
import '../../data/models/watch_history_entry.dart';
import '../theme/app_theme.dart';

/// Stats header for the watch history screen showing totals and average rating.
class WatchHistoryStatsHeader extends StatelessWidget {
  final List<WatchHistoryEntry> entries;

  const WatchHistoryStatsHeader({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final movies =
        entries.where((e) => e.mediaType == MediaType.movie).length;
    final series = entries.where((e) => e.mediaType == MediaType.tv).length;
    final rated = entries.where((e) => e.isRated).length;
    final avgRating = rated > 0
        ? entries
                  .where((e) => e.isRated)
                  .map((e) => e.userRating!)
                  .reduce((a, b) => a + b) /
              rated
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.2),
            AppTheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.movie_rounded,
            value: '$movies',
            label: AppLocalizations.of(context)!.statMovies,
          ),
          _StatItem(
            icon: Icons.tv_rounded,
            value: '$series',
            label: AppLocalizations.of(context)!.statSeries,
          ),
          _StatItem(
            icon: Icons.star_rounded,
            value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
            label: AppLocalizations.of(context)!.statAvgRating,
            color: AppTheme.getRatingColor(avgRating),
          ),
          _StatItem(
            icon: Icons.rate_review_rounded,
            value: '$rated',
            label: AppLocalizations.of(context)!.statRated,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppTheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
