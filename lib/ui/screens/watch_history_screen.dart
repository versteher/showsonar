import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../../data/models/watch_history_entry.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/watch_history_stats_header.dart';
import '../widgets/watch_history_filter_bar.dart';
import '../widgets/watch_history_card.dart';
import '../widgets/watch_history_empty_state.dart';

/// Watch history screen showing all watched content with personal ratings
class WatchHistoryScreen extends ConsumerStatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  ConsumerState<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends ConsumerState<WatchHistoryScreen> {
  String _sortBy = 'date'; // date, rating, imdb, title
  MediaType? _filterType;
  bool _onlyRated = false;

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(watchHistoryEntriesProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: AppTheme.background,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 24),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.myListTitle),
                  ],
                ),
                centerTitle: true,
              ),
            ),

            // Stats Header
            SliverToBoxAdapter(
              child: entriesAsync.when(
                data: (entries) =>
                    WatchHistoryStatsHeader(entries: entries),
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
              ),
            ),

            // Filter/Sort Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: WatchHistoryFilterBar(
                  sortBy: _sortBy,
                  filterType: _filterType,
                  onlyRated: _onlyRated,
                  onSortChanged: (value) => setState(() => _sortBy = value),
                  onFilterTypeChanged: (type) =>
                      setState(() => _filterType = type),
                  onOnlyRatedToggled: () =>
                      setState(() => _onlyRated = !_onlyRated),
                ),
              ),
            ),

            // Content
            entriesAsync.when(
              data: (entries) {
                final filtered = _filterAndSort(entries);
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: WatchHistoryEmptyState(
                      isCompletelyEmpty: entries.isEmpty,
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => WatchHistoryCard(
                        entry: filtered[index],
                        index: index,
                        onRatingTap: () =>
                            _showRatingDialog(filtered[index]),
                        onDeleteConfirm: () =>
                            _confirmDelete(filtered[index]),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.errorGeneric('$error'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<WatchHistoryEntry> _filterAndSort(List<WatchHistoryEntry> entries) {
    var filtered = entries.toList();

    // Apply filters
    if (_filterType != null) {
      filtered = filtered.where((e) => e.mediaType == _filterType).toList();
    }
    if (_onlyRated) {
      filtered = filtered.where((e) => e.isRated).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) {
          if (a.userRating == null && b.userRating == null) return 0;
          if (a.userRating == null) return 1;
          if (b.userRating == null) return -1;
          return b.userRating!.compareTo(a.userRating!);
        });
        break;
      case 'imdb':
        filtered.sort((a, b) {
          if (a.voteAverage == null && b.voteAverage == null) return 0;
          if (a.voteAverage == null) return 1;
          if (b.voteAverage == null) return -1;
          return b.voteAverage!.compareTo(a.voteAverage!);
        });
        break;
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'date':
      default:
        filtered.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    }

    return filtered;
  }

  Future<void> _showRatingDialog(WatchHistoryEntry entry) async {
    final result = await RatingDialog.show(
      context,
      title: entry.title,
      initialRating: entry.userRating,
      initialNotes: entry.notes,
      posterUrl: entry.posterPath != null
          ? 'https://image.tmdb.org/t/p/w200${entry.posterPath}'
          : null,
    );

    if (result != null) {
      final repo = ref.read(watchHistoryRepositoryProvider);
      await repo.init();

      final updated = entry.copyWith(
        userRating: result.rating,
        notes: result.notes,
      );
      await repo.updateEntry(updated);
      ref.invalidate(watchHistoryEntriesProvider);

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          AppLocalizations.of(
            context,
          )!.entryRated(entry.title, result.rating.toStringAsFixed(1)),
        );
      }
    }
  }

  Future<bool> _confirmDelete(WatchHistoryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(AppLocalizations.of(context)!.deleteEntry),
        content: Text(
          AppLocalizations.of(context)!.deleteEntryMessage(entry.title),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(AppLocalizations.of(context)!.detailCancel),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(AppLocalizations.of(context)!.detailRemove),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(watchHistoryRepositoryProvider);
      await repo.init();
      await repo.removeFromHistory(entry.mediaId, entry.mediaType);
      ref.invalidate(watchHistoryEntriesProvider);

      if (mounted) {
        AppSnackBar.showNeutral(
          context,
          AppLocalizations.of(context)!.entryRemoved(entry.title),
        );
      }
      return true;
    }
    return false;
  }
}
