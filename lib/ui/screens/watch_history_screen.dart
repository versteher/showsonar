import 'package:neon_voyager/utils/app_haptics.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/providers.dart';
import '../../data/models/watch_history_entry.dart';
import '../../data/models/media.dart';
import '../../data/models/genre.dart';
import '../theme/app_theme.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/app_snack_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
                data: (entries) => _buildStatsHeader(entries),
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
              ),
            ),

            // Filter/Sort Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: _buildFilterBar(),
              ),
            ),

            // Content
            entriesAsync.when(
              data: (entries) {
                final filtered = _filterAndSort(entries);
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyState(entries.isEmpty),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildHistoryCard(filtered[index], index),
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

  Widget _buildStatsHeader(List<WatchHistoryEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final movies = entries.where((e) => e.mediaType == MediaType.movie).length;
    final series = entries.where((e) => e.mediaType == MediaType.tv).length;
    final rated = entries.where((e) => e.isRated).length;
    final avgRating = rated > 0
        ? entries
                  .where((e) => e.isRated)
                  .map((e) => e.userRating!)
                  .reduce((a, b) => a + b) /
              rated
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.2),
            AppTheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.movie_rounded,
            value: '$movies',
            label: AppLocalizations.of(context)!.statMovies,
          ),
          _StatItem(
            icon: Icons.tv_rounded,
            value: '$series',
            label: AppLocalizations.of(context)!.statSeries,
          ),
          _StatItem(
            icon: Icons.star_rounded,
            value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
            label: AppLocalizations.of(context)!.statAvgRating,
            color: AppTheme.getRatingColor(avgRating),
          ),
          _StatItem(
            icon: Icons.rate_review_rounded,
            value: '$rated',
            label: AppLocalizations.of(context)!.statRated,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Sort dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isDense: true,
                dropdownColor: AppTheme.surface,
                items: [
                  DropdownMenuItem(
                    value: 'date',
                    child: Text('📅 ${AppLocalizations.of(context)!.sortDate}'),
                  ),
                  DropdownMenuItem(
                    value: 'rating',
                    child: Text(
                      '⭐ ${AppLocalizations.of(context)!.sortMyRating}',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'imdb',
                    child: Text(
                      '🎬 ${AppLocalizations.of(context)!.sortImdbRating}',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'title',
                    child: Text(
                      '🔤 ${AppLocalizations.of(context)!.sortTitle}',
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _sortBy = value!),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Type filter chips
          _FilterChip(
            label: AppLocalizations.of(context)!.filterAll,
            isSelected: _filterType == null,
            onTap: () => setState(() => _filterType = null),
          ),
          _FilterChip(
            label: '🎬 ${AppLocalizations.of(context)!.filterMovies}',
            isSelected: _filterType == MediaType.movie,
            onTap: () => setState(() => _filterType = MediaType.movie),
          ),
          _FilterChip(
            label: '📺 ${AppLocalizations.of(context)!.filterSeries}',
            isSelected: _filterType == MediaType.tv,
            onTap: () => setState(() => _filterType = MediaType.tv),
          ),
          _FilterChip(
            label: '⭐ ${AppLocalizations.of(context)!.filterRated}',
            isSelected: _onlyRated,
            onTap: () => setState(() => _onlyRated = !_onlyRated),
          ),
        ],
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

  Widget _buildEmptyState(bool isCompletelyEmpty) {
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

  Widget _buildHistoryCard(WatchHistoryEntry entry, int index) {
    return Slidable(
          key: Key(entry.uniqueKey),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (context) {
                  AppHaptics.mediumImpact();
                  _showRatingDialog(entry);
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
                return await _confirmDelete(entry);
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
                          // Title and type
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
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
                                      ? AppLocalizations.of(context)!.statMovies
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
                                  style: Theme.of(context).textTheme.bodySmall,
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
                              style: Theme.of(context).textTheme.bodySmall
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppTheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.2)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
