import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/providers.dart';
import '../theme/app_theme.dart';

class WatchHistoryStats {
  final String icon;
  final String label;
  final String value;
  WatchHistoryStats({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class TasteProfileStatsCard extends ConsumerWidget {
  const TasteProfileStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(watchHistoryEntriesProvider);
    List<WatchHistoryStats> stats = [];

    try {
      final entries = entriesAsync.valueOrNull ?? [];
      final rated = entries.where((e) => e.isRated).toList();
      final avgRating = rated.isEmpty
          ? 0.0
          : rated.map((e) => e.userRating!).reduce((a, b) => a + b) /
                rated.length;
      stats = [
        WatchHistoryStats(
          icon: '🎬',
          label: 'Gesehen',
          value: '${entries.length}',
        ),
        WatchHistoryStats(
          icon: '⭐',
          label: 'Bewertet',
          value: '${rated.length}',
        ),
        WatchHistoryStats(
          icon: '📊',
          label: 'Ø Bewertung',
          value: rated.isEmpty ? '—' : avgRating.toStringAsFixed(1),
        ),
      ];
    } catch (_) {}

    return Container(
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
          Text(
            'Dein Filmprofil',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: stats
                .map(
                  (s) => Expanded(
                    child: Column(
                      children: [
                        Text(s.icon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          s.value,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          s.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
