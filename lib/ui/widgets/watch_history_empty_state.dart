import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Empty state displayed when the watch history list has no items to show.
///
/// [isCompletelyEmpty] distinguishes between a truly empty history and a
/// history that is non-empty but has no items matching the active filters.
class WatchHistoryEmptyState extends StatelessWidget {
  final bool isCompletelyEmpty;

  const WatchHistoryEmptyState({super.key, required this.isCompletelyEmpty});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
                isCompletelyEmpty
                    ? Icons.movie_filter_outlined
                    : Icons.filter_list_off,
                size: 80,
                color: AppTheme.textMuted.withValues(alpha: 0.5),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.08, 1.08),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            isCompletelyEmpty
                ? AppLocalizations.of(context)!.emptyHistory
                : AppLocalizations.of(context)!.emptyFilter,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            isCompletelyEmpty
                ? AppLocalizations.of(context)!.emptyHistorySubtitle
                : AppLocalizations.of(context)!.emptyFilterSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
