import 'package:stream_scout/utils/app_haptics.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../data/models/watch_history_entry.dart';
import '../../data/models/media.dart';
import '../../data/models/genre.dart';
import '../theme/app_theme.dart';

/// A slidable card representing a single watch history entry.
///
/// Swipe right to edit the rating, swipe left to delete.
class WatchHistoryCard extends StatelessWidget {
  final WatchHistoryEntry entry;
  final int index;

  /// Called when the user triggers the "edit rating" action.
  final VoidCallback onRatingTap;

  /// Called when the user confirms deletion. Should return `true` if the
  /// entry was deleted, `false` if the user cancelled.
  final Future<bool> Function() onDeleteConfirm;

  const WatchHistoryCard({
    super.key,
    required this.entry,
    required this.index,
    required this.onRatingTap,
    required this.onDeleteConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
          key: Key(entry.uniqueKey),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (context) {
                  AppHaptics.mediumImpact();
                  onRatingTap();
                },
                backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                foregroundColor: AppTheme.primary,
                icon: Icons.edit_rounded,
                label: AppLocalizations.of(context)!.detailChangeRating,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            dismissible: DismissiblePane(
              onDismissed: () {},
              confirmDismiss: () async {
                AppHaptics.heavyImpact();
                return await onDeleteConfirm();
              },
            ),
            children: [
              SlidableAction(
                onPressed: (context) {
                  AppHaptics.heavyImpact();
                  final slidable = Slidable.of(context);
                  slidable?.dismiss(
                    ResizeRequest(const Duration(milliseconds: 300), () {}),
                  );
                },
                backgroundColor: AppTheme.error.withValues(alpha: 0.2),
                foregroundColor: AppTheme.error,
                icon: Icons.delete_outline_rounded,
                label: AppLocalizations.of(context)!.detailRemove,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () {
              AppHaptics.lightImpact();
              context.push('/${entry.mediaType.name}/${entry.mediaId}');
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  // Poster
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusMedium),
                      bottomLeft: Radius.circular(AppTheme.radiusMedium),
                    ),
                    child: entry.posterPath != null
                        ? CachedNetworkImage(
                            imageUrl:
                                'https://image.tmdb.org/t/p/w200${entry.posterPath}',
                            width: 80,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 80,
                              height: 120,
                              color: AppTheme.surfaceLight,
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 120,
                            color: AppTheme.surfaceLight,
                            child: const Icon(
                              Icons.movie,
                              color: AppTheme.textMuted,
                            ),
                          ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and type badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.mediaType == MediaType.movie
                                      ? AppLocalizations.of(
                                          context,
                                        )!.statMovies
                                      : AppLocalizations.of(
                                          context,
                                        )!.statSeries,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Ratings row
                          Row(
                            children: [
                              // Personal rating
                              if (entry.isRated) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getRatingColor(
                                      entry.userRating!,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppTheme.getRatingColor(
                                        entry.userRating!,
                                      ).withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: AppTheme.getRatingColor(
                                          entry.userRating!,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        entry.userRating!.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppTheme.getRatingColor(
                                            entry.userRating!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],

                              // IMDB rating
                              if (entry.voteAverage != null &&
                                  entry.voteAverage! > 0) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'IMDB',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      entry.voteAverage!.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.getRatingColor(
                                          entry.voteAverage!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                              ],

                              // Watched date
                              Expanded(
                                child: Text(
                                  entry.watchedAgo,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),

                          // Notes preview
                          if (entry.notes != null &&
                              entry.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              entry.notes!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.textMuted,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          // Genres
                          if (entry.genreIds.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              children: entry.genreIds.take(3).map((id) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    Genre.getNameById(id),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
