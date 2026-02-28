import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/services/omdb_service.dart';
import '../../ui/theme/app_theme.dart';

// ============================================================
// Provider
// ============================================================

final _omdbServiceProvider = Provider<OmdbService>((_) => OmdbService());

/// Fetches OMDb/RT ratings for a given IMDb ID or title+year
final omdbRatingsProvider =
    FutureProvider.family<
      OmdbRatings?,
      ({String? imdbId, String title, int? year})
    >((ref, params) async {
      final svc = ref.watch(_omdbServiceProvider);
      if (params.imdbId != null && params.imdbId!.isNotEmpty) {
        return svc.fetchByImdbId(params.imdbId!);
      }
      // Fallback: search by title
      return svc.fetchByTitle(params.title, year: params.year);
    });

// ============================================================
// Widget
// ============================================================

/// Displays Rotten Tomatoes Tomatometer and Metacritic badges.
/// Shows nothing when OMDb is unconfigured or no data is found.
class RtScoresBadge extends ConsumerWidget {
  final String? imdbId;
  final String title;
  final int? year;

  const RtScoresBadge({
    super.key,
    required this.imdbId,
    required this.title,
    this.year,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsAsync = ref.watch(
      omdbRatingsProvider((imdbId: imdbId, title: title, year: year)),
    );

    return ratingsAsync.when(
      data: (ratings) {
        if (ratings == null || !ratings.hasAnyRating) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ratings.hasTomatometer) ...[
              _RtBadge(
                icon: '🍅',
                label: ratings.tomatometer!,
                color: _tomatometerColor(ratings.tomatometerInt),
              ),
              const SizedBox(width: 8),
            ],
            if (ratings.metacritic != null) ...[
              _RtBadge(
                icon: 'M',
                label: ratings.metacritic!,
                color: _metacriticColor(ratings.metacritic),
                iconIsText: true,
              ),
            ],
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Color _tomatometerColor(int? score) {
    if (score == null) return AppTheme.textMuted;
    if (score >= 75) return const Color(0xFFFF4500); // Red (certified fresh)
    if (score >= 60) return const Color(0xFFFF8C00); // Orange (fresh)
    return const Color(0xFF6B9A17); // Green-gray (rotten)
  }

  Color _metacriticColor(String? value) {
    if (value == null) return AppTheme.textMuted;
    final score = int.tryParse(value.split('/').first.trim());
    if (score == null) return AppTheme.textMuted;
    if (score >= 75) return const Color(0xFF66CC33);
    if (score >= 50) return const Color(0xFFFFCC33);
    return const Color(0xFFFF0000);
  }
}

class _RtBadge extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final bool iconIsText;

  const _RtBadge({
    required this.icon,
    required this.label,
    required this.color,
    this.iconIsText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconIsText
              ? Text(
                  icon,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                )
              : Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
