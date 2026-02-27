import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../../data/models/streaming_provider.dart';
import '../theme/app_theme.dart';

/// Horizontal scrollable bar for quick streaming service selection
/// Tap any chip to toggle it on/off – changes persist automatically
class StreamingFilterBar extends ConsumerWidget {
  final Function(List<String> selectedServices)? onFilterChanged;

  const StreamingFilterBar({super.key, this.onFilterChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferencesProvider);

    return prefsAsync.when(
      data: (prefs) =>
          _buildFilterBar(context, ref, prefs.subscribedServiceIds),
      loading: () => const SizedBox(height: 48),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    WidgetRef ref,
    List<String> selectedServices,
  ) {
    final prefs = ref.watch(userPreferencesProvider).valueOrNull;
    final allProviders = StreamingProvider.getProvidersForCountry(
      prefs?.countryCode ?? 'US',
    );

    final countsAsync = ref.watch(providerCountsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Row(
            children: [
              const Icon(
                Icons.filter_alt_rounded,
                size: 16,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.filterStreaming,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: AppTheme.textMuted),
              ),
              if (selectedServices.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${selectedServices.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            itemCount: allProviders.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final provider = allProviders[index];
              final isSelected = selectedServices.contains(provider.id);
              final count = countsAsync.when(
                data: (counts) => counts[provider.id],
                loading: () => null,
                error: (error, stackTrace) => null,
              );

              return _ToggleChip(
                provider: provider,
                isSelected: isSelected,
                count: count,
                onTap: () => _toggleService(
                  ref,
                  context,
                  provider,
                  isSelected,
                  selectedServices,
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Future<void> _toggleService(
    WidgetRef ref,
    BuildContext context,
    StreamingProvider provider,
    bool wasSelected,
    List<String> currentServices,
  ) async {
    final repo = ref.read(userPreferencesRepositoryProvider);
    await repo.init();

    if (wasSelected) {
      await repo.removeStreamingService(provider.id);
    } else {
      await repo.addStreamingService(provider.id);
    }

    // Refresh all data
    ref.invalidate(userPreferencesProvider);
    ref.invalidate(trendingProvider);
    ref.invalidate(popularMoviesProvider);
    ref.invalidate(popularTvSeriesProvider);
    ref.invalidate(topRatedMoviesProvider);
    ref.invalidate(topRatedTvSeriesProvider);
    ref.invalidate(upcomingMoviesProvider);
    ref.invalidate(upcomingTvProvider);
    ref.invalidate(upcomingProvider);
    // Also clear per-card streaming availability so logos update immediately
    ref.invalidate(mediaAvailabilityProvider);

    final updatedServices = wasSelected
        ? (currentServices.where((id) => id != provider.id).toList())
        : [...currentServices, provider.id];
    onFilterChanged?.call(updatedServices);
  }
}

/// A single streaming service toggle chip
class _ToggleChip extends StatelessWidget {
  final StreamingProvider provider;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.provider,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.surfaceBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: AppTheme.primary)
                    : Text(
                        provider.name.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              provider.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white70 : AppTheme.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
