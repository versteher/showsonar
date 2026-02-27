import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../../config/providers/statistics_provider.dart';
import '../../widgets/branded_loading_indicator.dart';
import 'stat_card.dart';

class WatchStatisticsView extends ConsumerWidget {
  const WatchStatisticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats.totalRatedItems == 0 &&
            stats.totalMoviesWatched == 0 &&
            stats.totalSeriesWatched == 0) {
          return const Center(
            child: Text(
              'No watch history yet',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(statisticsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Year in Review Banner
                GestureDetector(
                  onTap: () => context.push('/year-in-review'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF4F46E5), Color(0xFFEC4899)],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Row(
                      children: [
                        const Text('🎬', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${DateTime.now().year} Year in Review',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'Your personalized Wrapped-style recap',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                // Top Stats Row
                _buildTopStatsRow(context, stats),
                const SizedBox(height: AppTheme.spacingXl),

                // Genre Pie Chart
                if (stats.genreFrequency.isNotEmpty) ...[
                  Text(
                    'Genre Distribution',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  SizedBox(
                    height: 250,
                    child: _buildGenrePieChart(stats.genreFrequency, context),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],

                // Monthly Activity Bar Chart
                if (stats.monthlyActivity.isNotEmpty) ...[
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  SizedBox(
                    height: 200,
                    child: _buildActivityBarChart(
                      stats.monthlyActivity,
                      context,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],

                // Ratings Comparison
                Text(
                  'Ratings Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                _buildRatingsComparison(context, stats),
                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: BrandedLoadingIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Could not load statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(statisticsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatsRow(BuildContext context, dynamic stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppTheme.spacingMd,
          mainAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: 1.5,
          children: [
            StatCard(
              title: 'Movies',
              value: stats.totalMoviesWatched.toString(),
              icon: Icons.movie_creation_rounded,
              color: AppTheme.primary,
            ),
            StatCard(
              title: 'Series',
              value: stats.totalSeriesWatched.toString(),
              icon: Icons.tv_rounded,
              color: AppTheme.secondary,
            ),
            StatCard(
              title: 'Hours Spent',
              value: stats.totalHoursSpent.toString(),
              icon: Icons.access_time_filled_rounded,
              color: AppTheme.success,
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenrePieChart(Map<int, int> genreFreq, BuildContext context) {
    // Sort genres by frequency and take top 5
    final sortedEntries = genreFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = sortedEntries.take(5).toList();

    // We map TMDB genre IDs to basic strings for a local fallback representation
    // To be perfect, we would use the Genre mapping logic. Using basic colors.
    final genericColors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.success,
      AppTheme.warning,
      const Color(0xFFE91E63),
    ];

    if (topEntries.isEmpty) return const SizedBox.shrink();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: List.generate(topEntries.length, (i) {
          final entry = topEntries[i];
          return PieChartSectionData(
            color: genericColors[i % genericColors.length],
            value: entry.value.toDouble(),
            title: '${entry.value}',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActivityBarChart(
    Map<String, int> monthlyActivity,
    BuildContext context,
  ) {
    if (monthlyActivity.isEmpty) return const SizedBox.shrink();

    // Convert to sorted list
    final sortedKeys = monthlyActivity.keys.toList()..sort();

    double maxY = 0;
    for (var count in monthlyActivity.values) {
      if (count > maxY) maxY = count.toDouble();
    }
    maxY = maxY < 5 ? 5 : maxY + 2; // Small buffer

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedKeys.length) {
                  // E.g '2023-11' -> '11'
                  final key = sortedKeys[value.toInt()];
                  final month = key.substring(5, 7);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      month,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value % 2 == 0) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(sortedKeys.length, (i) {
          final count = monthlyActivity[sortedKeys[i]]!;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: AppTheme.primary,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRatingsComparison(BuildContext context, dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          _buildRatingBar(
            context,
            'Your Average',
            stats.averageUserRating,
            AppTheme.primary,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildRatingBar(
            context,
            'Community Avg',
            stats.averageCommunityRating,
            AppTheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(
    BuildContext context,
    String label,
    double rating,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: rating / 10,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        SizedBox(
          width: 35,
          child: Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
