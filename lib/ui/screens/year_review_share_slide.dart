import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/providers/year_in_review_provider.dart';
import '../../data/models/genre.dart';
import '../theme/app_theme.dart';

class Slide5Share extends StatelessWidget {
  const Slide5Share({required this.data, required this.year, super.key});
  final YearInReviewData data;
  final int year;

  String _buildShareText() {
    final lines = <String>[
      '🎬 My $year in Review',
      '',
      '🍿 ${data.totalTitlesWatched} titles watched (${data.totalMovies} movies, ${data.totalSeries} series)',
      '⏱ ${data.totalHoursWatched} hours of screen time',
      if (data.topGenres.isNotEmpty)
        '🎭 Top genre: ${Genre.getNameById(data.topGenres.first.key)}',
      if (data.ratedCount > 0)
        '⭐ Average rating: ${data.averageUserRating.toStringAsFixed(1)}/10',
      if (data.topRated.isNotEmpty) '🏆 Favourite: ${data.topRated.first.title}',
      '',
      '#StreamScout #MovieYear$year',
    ];
    return lines.join('\n');
  }

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
          children: [
            Text(
                  "That's a Wrap!",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 60)),
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: AppTheme.spacingXl),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A3E), Color(0xFF0F0F1A)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    emoji: '🍿',
                    text: '${data.totalTitlesWatched} titles watched',
                  ),
                  _SummaryRow(
                    emoji: '⏱',
                    text: '${data.totalHoursWatched}h of screen time',
                  ),
                  _SummaryRow(
                    emoji: '🎭',
                    text: 'Top genre: ${data.topGenreName}',
                  ),
                  if (data.ratedCount > 0)
                    _SummaryRow(
                      emoji: '⭐',
                      text:
                          'Avg rating: ${data.averageUserRating.toStringAsFixed(1)}/10',
                    ),
                  if (data.topRated.isNotEmpty)
                    _SummaryRow(
                      emoji: '🏆',
                      text: 'Fave: ${data.topRated.first.title}',
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

            const SizedBox(height: AppTheme.spacingXl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final text = _buildShareText();
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Copied to clipboard!'),
                          ],
                        ),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy Summary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.emoji, required this.text});
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
