import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'watchlist_screen.dart';

class WatchlistSortBar extends StatelessWidget {
  final WatchlistSort currentSort;
  final ValueChanged<WatchlistSort> onSortChanged;

  const WatchlistSortBar({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: 8,
        ),
        itemCount: WatchlistSort.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sort = WatchlistSort.values[index];
          final isSelected = sort == currentSort;
          return GestureDetector(
            onTap: () => onSortChanged(sort),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.2)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.surfaceBorder,
                ),
              ),
              child: Text(
                sort.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryLight
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
