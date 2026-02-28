import 'package:flutter/material.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';

/// Horizontal filter/sort bar for the watch history screen.
class WatchHistoryFilterBar extends StatelessWidget {
  final String sortBy;
  final MediaType? filterType;
  final bool onlyRated;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<MediaType?> onFilterTypeChanged;
  final VoidCallback onOnlyRatedToggled;

  const WatchHistoryFilterBar({
    super.key,
    required this.sortBy,
    required this.filterType,
    required this.onlyRated,
    required this.onSortChanged,
    required this.onFilterTypeChanged,
    required this.onOnlyRatedToggled,
  });

  @override
  Widget build(BuildContext context) {
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
                value: sortBy,
                isDense: true,
                dropdownColor: AppTheme.surface,
                items: [
                  DropdownMenuItem(
                    value: 'date',
                    child: Text(
                      '📅 ${AppLocalizations.of(context)!.sortDate}',
                    ),
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
                onChanged: (value) => onSortChanged(value!),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Type filter chips
          _FilterChip(
            label: AppLocalizations.of(context)!.filterAll,
            isSelected: filterType == null,
            onTap: () => onFilterTypeChanged(null),
          ),
          _FilterChip(
            label: '🎬 ${AppLocalizations.of(context)!.filterMovies}',
            isSelected: filterType == MediaType.movie,
            onTap: () => onFilterTypeChanged(MediaType.movie),
          ),
          _FilterChip(
            label: '📺 ${AppLocalizations.of(context)!.filterSeries}',
            isSelected: filterType == MediaType.tv,
            onTap: () => onFilterTypeChanged(MediaType.tv),
          ),
          _FilterChip(
            label: '⭐ ${AppLocalizations.of(context)!.filterRated}',
            isSelected: onlyRated,
            onTap: onOnlyRatedToggled,
          ),
        ],
      ),
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
