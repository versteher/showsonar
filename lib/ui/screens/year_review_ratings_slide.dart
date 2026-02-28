import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/providers/year_in_review_provider.dart';
import '../theme/app_theme.dart';

class Slide4Ratings extends StatelessWidget {
  const Slide4Ratings({required this.data, super.key});
  final YearInReviewData data;

  @override
  Widget build(BuildContext context) {
    final avg = data.averageUserRating;
    final rated = data.ratedCount;
    final totalWatched = data.totalTitlesWatched;
    final ratedPct =
        totalWatched > 0 ? (rated / totalWatched * 100).round() : 0;

    final sentiment = avg >= 8
        ? ('You loved almost everything! 🌟', AppTheme.success)
        : avg >= 6
        ? ('You had a solid year 👍', AppTheme.primary)
        : avg >= 4
        ? ('Mixed bag — quality was hit-or-miss 🎲', AppTheme.warning)
        : ('Tough crowd — very selective! 🎯', AppTheme.error);

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
              'Your Ratings',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),

            const SizedBox(height: AppTheme.spacingXl),

            if (rated > 0) ...[
              Center(
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: avg),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [AppTheme.warning, AppTheme.secondary],
                              ).createShader(
                                const Rect.fromLTWH(0, 0, 120, 80),
                              ),
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 200.ms),
                    const Text(
                      'average rating',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),
              StarBar(rating: avg),
              const SizedBox(height: AppTheme.spacingXl),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sentiment.$2.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: sentiment.$2.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    sentiment.$1,
                    style: TextStyle(
                      color: sentiment.$2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              Center(
                child: Text(
                  'You rated $rated of $totalWatched titles ($ratedPct%)',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ).animate().fadeIn(delay: 800.ms),
              ),
            ] else
              Center(
                child: Text(
                  'No ratings yet for ${data.year}',
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StarBar extends StatelessWidget {
  const StarBar({required this.rating, super.key});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final fullStars = (rating / 2).floor();
    final halfStar = ((rating / 2) - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final isFullStar = i < fullStars;
        final isHalfStar = !isFullStar && i == fullStars && halfStar;
        return Icon(
          isFullStar
              ? Icons.star_rounded
              : isHalfStar
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          color: AppTheme.warning,
          size: 36,
        );
      }),
    );
  }
}
