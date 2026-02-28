import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/providers/year_in_review_provider.dart';
import '../theme/app_theme.dart';

class Slide1Intro extends StatelessWidget {
  const Slide1Intro({required this.data, super.key});
  final YearInReviewData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingXl,
          80,
          AppTheme.spacingXl,
          120,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data.year}',
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 100)),
                height: 1,
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: AppTheme.spacingSm),

            Text(
              'Year in\nReview',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.15,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

            const SizedBox(height: AppTheme.spacingXl),

            Row(
              children: [
                StatPill(
                  label: 'Titles',
                  value: data.totalTitlesWatched.toString(),
                  color: AppTheme.primary,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                StatPill(
                  label: 'Hours',
                  value: data.totalHoursWatched.toString(),
                  color: AppTheme.secondary,
                ),
              ],
            ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

            const SizedBox(height: AppTheme.spacingMd),

            Row(
              children: [
                StatPill(
                  label: 'Movies',
                  value: data.totalMovies.toString(),
                  color: AppTheme.accent,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                StatPill(
                  label: 'Series',
                  value: data.totalSeries.toString(),
                  color: AppTheme.success,
                ),
              ],
            ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

            const SizedBox(height: AppTheme.spacingXl),

            Text(
              'Swipe to see your story →',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ).animate().fadeIn(delay: 1200.ms),
          ],
        ),
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
