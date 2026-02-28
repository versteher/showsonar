import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/providers/year_in_review_provider.dart';
import '../../data/models/genre.dart';
import '../theme/app_theme.dart';

class Slide2Genres extends StatelessWidget {
  const Slide2Genres({required this.data, super.key});
  final YearInReviewData data;

  static const _barColors = [
    AppTheme.primary,
    AppTheme.secondary,
    AppTheme.accent,
    AppTheme.success,
    AppTheme.warning,
  ];

  @override
  Widget build(BuildContext context) {
    final genres = data.topGenres;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingXl,
          80,
          AppTheme.spacingXl,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Top\nGenres',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
              ),
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),

            const SizedBox(height: AppTheme.spacingXl),

            if (genres.isEmpty)
              Text(
                'No genre data yet.',
                style: TextStyle(color: AppTheme.textMuted),
              )
            else
              ...genres.asMap().entries.map((mapEntry) {
                final i = mapEntry.key;
                final entry = mapEntry.value;
                final genreName = Genre.getNameById(entry.key);
                final maxVal = genres.first.value.toDouble();
                final fraction = entry.value / maxVal;
                final color = _barColors[i % _barColors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${i + 1}. $genreName',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${entry.value} ${entry.value == 1 ? 'title' : 'titles'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: fraction),
                          duration: Duration(milliseconds: 600 + i * 150),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: color.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 12,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 200 + i * 100),
                  duration: 400.ms,
                );
              }),
          ],
        ),
      ),
    );
  }
}
