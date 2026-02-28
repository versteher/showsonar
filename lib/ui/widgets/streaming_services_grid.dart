import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../../data/models/streaming_provider.dart';
import '../theme/app_theme.dart';
import 'app_snack_bar.dart';

class StreamingServicesGrid extends ConsumerWidget {
  final List<String> subscribedIds;
  final String countryCode;

  const StreamingServicesGrid({
    super.key,
    required this.subscribedIds,
    required this.countryCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countryProviders = StreamingProvider.getProvidersForCountry(
      countryCode,
    );
    return Wrap(
      spacing: AppTheme.spacingMd,
      runSpacing: AppTheme.spacingMd,
      children: countryProviders.asMap().entries.map((entry) {
        final index = entry.key;
        final provider = entry.value;
        final isSubscribed = subscribedIds.contains(provider.id);

        return GestureDetector(
              onTap: () async {
                final repo = ref.read(userPreferencesRepositoryProvider);
                await repo.init();

                if (isSubscribed) {
                  await repo.removeStreamingService(provider.id);
                } else {
                  await repo.addStreamingService(provider.id);
                }

                ref.invalidate(userPreferencesProvider);

                if (context.mounted) {
                  if (isSubscribed) {
                    AppSnackBar.showNeutral(
                      context,
                      AppLocalizations.of(
                        context,
                      )!.settingsRemoved(provider.name),
                    );
                  } else {
                    AppSnackBar.showSuccess(
                      context,
                      AppLocalizations.of(
                        context,
                      )!.settingsAdded(provider.name),
                    );
                  }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 100,
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: isSubscribed
                      ? AppTheme.primary.withValues(alpha: 0.2)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: isSubscribed
                        ? AppTheme.primary
                        : AppTheme.surfaceBorder,
                    width: isSubscribed ? 2 : 1,
                  ),
                  boxShadow: isSubscribed
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Icon(
                          _getProviderIcon(provider.id),
                          size: 36,
                          color: isSubscribed
                              ? AppTheme.primary
                              : AppTheme.textMuted,
                        ),
                        if (isSubscribed)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppTheme.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      provider.name.split(' ').first,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSubscribed
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSubscribed
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
            .animate(delay: Duration(milliseconds: index * 50))
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
      }).toList(),
    );
  }

  IconData _getProviderIcon(String providerId) {
    switch (providerId) {
      case 'netflix':
        return Icons.play_circle_filled;
      case 'disney_plus':
        return Icons.star_rounded;
      case 'amazon_prime':
        return Icons.shopping_bag_rounded;
      case 'hbo_max':
        return Icons.movie_filter_rounded;
      case 'apple_tv':
        return Icons.apple_rounded;
      case 'paramount_plus':
        return Icons.volcano_rounded;
      case 'wow':
        return Icons.flash_on_rounded;
      case 'rtl_plus':
        return Icons.tv_rounded;
      default:
        return Icons.tv_rounded;
    }
  }
}
