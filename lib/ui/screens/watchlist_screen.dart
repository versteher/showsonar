import 'package:neon_voyager/utils/app_haptics.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/providers.dart';
import '../../data/models/watchlist_entry.dart';
import '../../data/models/watch_history_entry.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/rating_dialog.dart';
import 'watchlist_card.dart';
import 'watchlist_sort_bar.dart';

/// Sort options for the watchlist
enum WatchlistSort {
  recentlyAdded('Neueste zuerst'),
  highestRated('Beste Bewertung'),
  alphabetical('A–Z');

  final String label;
  const WatchlistSort(this.label);
}

/// Watchlist screen showing saved want-to-watch items
class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(watchlistEntriesProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) return _buildEmptyState(context);
          return _buildList(context, ref, entries);
        },
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppTheme.textMuted,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.watchlistError,
                style: const TextStyle(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(watchlistEntriesProvider),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(AppLocalizations.of(context)!.errorRetry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                ).createShader(bounds),
                child: const Icon(
                  Icons.bookmark_border_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.08, 1.08),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.watchlistEmpty,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              AppLocalizations.of(context)!.watchlistEmptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<WatchlistEntry> entries,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Local sort state
        final sortNotifier = ValueNotifier<WatchlistSort>(
          WatchlistSort.recentlyAdded,
        );
        return ValueListenableBuilder<WatchlistSort>(
          valueListenable: sortNotifier,
          builder: (context, currentSort, _) {
            // Apply sort
            final sorted = List<WatchlistEntry>.from(entries);
            switch (currentSort) {
              case WatchlistSort.recentlyAdded:
                sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
              case WatchlistSort.highestRated:
                sorted.sort(
                  (a, b) => (b.voteAverage ?? 0).compareTo(a.voteAverage ?? 0),
                );
              case WatchlistSort.alphabetical:
                sorted.sort((a, b) => a.title.compareTo(b.title));
            }

            return Column(
              children: [
                WatchlistSortBar(
                  currentSort: currentSort,
                  onSortChanged: (sort) => sortNotifier.value = sort,
                ),

                // Sorted list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final entry = sorted[index];
                      return Slidable(
                        key: Key(entry.uniqueKey),
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                AppHaptics.mediumImpact();
                                final result = await RatingDialog.show(
                                  context,
                                  title: entry.title,
                                  posterUrl: entry.posterPath != null
                                      ? 'https://image.tmdb.org/t/p/w200${entry.posterPath}'
                                      : null,
                                );

                                if (result != null) {
                                  final historyRepo = ref.read(
                                    watchHistoryRepositoryProvider,
                                  );
                                  await historyRepo.init();

                                  final newEntry = WatchHistoryEntry(
                                    mediaId: entry.mediaId,
                                    mediaType: entry.mediaType,
                                    title: entry.title,
                                    posterPath: entry.posterPath,
                                    voteAverage: entry.voteAverage,
                                    watchedAt: DateTime.now(),
                                    userRating: result.rating,
                                    notes: result.notes,
                                  );
                                  await historyRepo.addToHistory(newEntry);

                                  // Also remove it from watchlist automatically
                                  final repo = ref.read(
                                    watchlistRepositoryProvider,
                                  );
                                  await repo.init();
                                  await repo.removeFromWatchlist(
                                    entry.mediaId,
                                    entry.mediaType,
                                  );
                                  ref.invalidate(watchlistEntriesProvider);
                                  ref.invalidate(watchHistoryEntriesProvider);

                                  if (context.mounted) {
                                    AppSnackBar.showSuccess(
                                      context,
                                      AppLocalizations.of(context)!.entryRated(
                                        entry.title,
                                        result.rating.toStringAsFixed(1),
                                      ),
                                    );
                                  }
                                }
                              },
                              backgroundColor: AppTheme.success.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: AppTheme.success,
                              icon: Icons.check_circle_outline_rounded,
                              label: AppLocalizations.of(
                                context,
                              )!.detailMarkWatched,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
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
                              var undoPressed = false;
                              AppSnackBar.showWithUndo(
                                context,
                                AppLocalizations.of(
                                  context,
                                )!.entryRemoved(entry.title),
                                onUndo: () {
                                  undoPressed = true;
                                },
                              );
                              // Wait for snackbar to close (4s duration + extra buffer)
                              await Future.delayed(
                                const Duration(milliseconds: 4500),
                              );
                              if (!undoPressed) {
                                final repo = ref.read(
                                  watchlistRepositoryProvider,
                                );
                                await repo.init();
                                await repo.removeFromWatchlist(
                                  entry.mediaId,
                                  entry.mediaType,
                                );
                                ref.invalidate(watchlistEntriesProvider);
                              }
                              return !undoPressed;
                            },
                          ),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                AppHaptics.heavyImpact();
                                final slidable = Slidable.of(context);
                                slidable?.dismiss(
                                  ResizeRequest(
                                    const Duration(milliseconds: 300),
                                    () {},
                                  ),
                                );
                              },
                              backgroundColor: AppTheme.error.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: AppTheme.error,
                              icon: Icons.delete_outline_rounded,
                              label: AppLocalizations.of(context)!.detailRemove,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                          ],
                        ),
                        child: WatchlistCard(
                          entry: entry,
                          onTap: () {
                            AppHaptics.lightImpact();
                            context.push(
                              '/${entry.mediaType.name}/${entry.mediaId}',
                              extra: {'heroTagPrefix': 'watchlist'},
                            );
                          },
                        ),
                      ).animate().fadeIn(
                        duration: 300.ms,
                        delay: Duration(milliseconds: index * 50),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: AppTheme.surfaceLight,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          height: 90,
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      ),
    );
  }
}
