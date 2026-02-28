import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';

import '../../data/models/media.dart';
import '../../data/models/watch_history_entry.dart';
import '../theme/app_theme.dart';

class DetailPersonalRatingCard extends StatelessWidget {
  const DetailPersonalRatingCard({
    super.key,
    required this.media,
    required this.entry,
    required this.onRatingTapped,
  });

  final Media media;
  final WatchHistoryEntry entry;
  final VoidCallback onRatingTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
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
          Row(
            children: [
              const Icon(Icons.person_rounded, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.detailMyRating,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                entry.watchedAgo,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingSm),

          Row(
            children: [
              if (entry.isRated) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getRatingColor(
                      entry.userRating!,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.getRatingColor(
                        entry.userRating!,
                      ).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (i) {
                        final starValue = (i + 1) * 2;
                        return Icon(
                          starValue <= entry.userRating!
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 18,
                          color: AppTheme.getRatingColor(entry.userRating!),
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        entry.userRating!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getRatingColor(entry.userRating!),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: onRatingTapped,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_outline_rounded,
                          color: AppTheme.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.detailRateNow,
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.notes!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms);
  }
}
