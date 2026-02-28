import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../../data/models/streaming_provider.dart';
import '../../data/repositories/tmdb_repository.dart';
import '../theme/app_theme.dart';
import 'streaming_country_selector.dart';
import 'streaming_provider_chip.dart';
import 'streaming_provider_urls.dart';

/// Provider for streaming availability by media and country
final streamingAvailabilityProvider =
    FutureProvider.family<
      WatchProviderResult,
      ({int id, MediaType type, String region})
    >((ref, params) async {
      final tmdb = ref.watch(tmdbRepositoryProvider);
      return tmdb.getWatchProviders(
        params.id,
        params.type,
        region: params.region,
      );
    });

/// Widget showing where to stream a movie/series by country
/// Highlights user's selected streaming services
class StreamingAvailabilityWidget extends ConsumerStatefulWidget {
  final int mediaId;
  final MediaType mediaType;
  final String mediaTitle; // Title for search links
  final String initialCountry;
  final bool filterByUserServices; // Only show user's selected services

  const StreamingAvailabilityWidget({
    super.key,
    required this.mediaId,
    required this.mediaType,
    required this.mediaTitle,
    this.initialCountry = 'DE',
    this.filterByUserServices = true,
  });

  @override
  ConsumerState<StreamingAvailabilityWidget> createState() =>
      _StreamingAvailabilityWidgetState();
}

class _StreamingAvailabilityWidgetState
    extends ConsumerState<StreamingAvailabilityWidget> {
  late String _selectedCountry;
  bool _showAllProviders = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry;
  }

  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(
      streamingAvailabilityProvider((
        id: widget.mediaId,
        type: widget.mediaType,
        region: _selectedCountry,
      )),
    );
    final userPrefsAsync = ref.watch(userPreferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with country selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.streamingAvailable,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            StreamingCountrySelector(
              selectedCountry: _selectedCountry,
              onCountryChanged: (code) =>
                  setState(() => _selectedCountry = code),
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Providers
        providersAsync.when(
          data: (result) => userPrefsAsync.when(
            data: (prefs) =>
                _buildProvidersContent(result, prefs.subscribedServiceIds),
            loading: () => _buildProvidersContent(result, []),
            error: (error, stackTrace) => _buildProvidersContent(result, []),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingLg),
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          ),
          error: (error, stackTrace) =>
              _buildEmptyState(AppLocalizations.of(context)!.streamingError),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms);
  }

  Widget _buildProvidersContent(
    WatchProviderResult result,
    List<String> userServiceIds,
  ) {
    // Get TMDB IDs of user's selected services
    final userTmdbIds = StreamingProvider.getTmdbIds(userServiceIds);

    // Always separate user's services from others
    final userFlatrate = result.flatrate
        .where((p) => userTmdbIds.contains(p.providerId))
        .toList();
    final otherFlatrate = result.flatrate
        .where((p) => !userTmdbIds.contains(p.providerId))
        .toList();

    final userRent = result.rent
        .where((p) => userTmdbIds.contains(p.providerId))
        .toList();
    final otherRent = result.rent
        .where((p) => !userTmdbIds.contains(p.providerId))
        .toList();

    final userBuy = result.buy
        .where((p) => userTmdbIds.contains(p.providerId))
        .toList();
    final otherBuy = result.buy
        .where((p) => !userTmdbIds.contains(p.providerId))
        .toList();

    final hasUserOptions =
        userFlatrate.isNotEmpty || userRent.isNotEmpty || userBuy.isNotEmpty;
    final hasOtherOptions =
        otherFlatrate.isNotEmpty || otherRent.isNotEmpty || otherBuy.isNotEmpty;
    final hasAnyOptions = result.hasAnyOptions;

    if (!hasAnyOptions) {
      return _buildEmptyState(
        AppLocalizations.of(
          context,
        )!.streamingNotAvailable(_getCountryName(_selectedCountry)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User's streaming services first (always show if available)
        if (userFlatrate.isNotEmpty) ...[
          _buildProviderSection(
            icon: Icons.check_circle_rounded,
            label: AppLocalizations.of(context)!.streamingYourServices,
            color: AppTheme.success,
            providers: userFlatrate,
            isUserService: true,
            justWatchLink: result.link,
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],

        // Show "not on your services" message if no user options
        if (!hasUserOptions && hasAnyOptions) ...[
          _buildNotOnUserServicesCard(otherFlatrate.length),
          const SizedBox(height: AppTheme.spacingMd),
        ],

        // User's Rent options
        if (userRent.isNotEmpty) ...[
          _buildProviderSection(
            icon: Icons.access_time_rounded,
            label: AppLocalizations.of(context)!.streamingRentYours,
            color: AppTheme.warning,
            providers: userRent,
            isUserService: true,
            justWatchLink: result.link,
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],

        // User's Buy options
        if (userBuy.isNotEmpty) ...[
          _buildProviderSection(
            icon: Icons.shopping_cart_rounded,
            label: AppLocalizations.of(context)!.streamingBuyYours,
            color: AppTheme.secondary,
            providers: userBuy,
            isUserService: true,
            justWatchLink: result.link,
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],

        // Other options (only if _showAllProviders)
        if (_showAllProviders && hasOtherOptions) ...[
          const Divider(color: AppTheme.surfaceBorder),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            AppLocalizations.of(context)!.streamingMoreOptions,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),

          if (otherFlatrate.isNotEmpty) ...[
            _buildProviderSection(
              icon: Icons.play_circle_outline,
              label: AppLocalizations.of(context)!.streamingStreaming,
              color: AppTheme.textMuted,
              providers: otherFlatrate,
              isUserService: false,
              justWatchLink: result.link,
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],

          if (otherRent.isNotEmpty) ...[
            _buildProviderSection(
              icon: Icons.access_time_rounded,
              label: AppLocalizations.of(context)!.streamingRent,
              color: AppTheme.textMuted,
              providers: otherRent,
              isUserService: false,
              justWatchLink: result.link,
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],

          if (otherBuy.isNotEmpty) ...[
            _buildProviderSection(
              icon: Icons.shopping_cart_rounded,
              label: AppLocalizations.of(context)!.streamingBuy,
              color: AppTheme.textMuted,
              providers: otherBuy,
              isUserService: false,
              justWatchLink: result.link,
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
        ],

        // Toggle to show all providers (only if there are other options)
        if (hasOtherOptions)
          GestureDetector(
            onTap: () => setState(() => _showAllProviders = !_showAllProviders),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showAllProviders
                        ? Icons.filter_list_off
                        : Icons.filter_list,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showAllProviders
                        ? AppLocalizations.of(context)!.streamingShowLess
                        : AppLocalizations.of(context)!.streamingShowMore,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // JustWatch link
        if (result.link != null) ...[
          const SizedBox(height: AppTheme.spacingSm),
          GestureDetector(
            onTap: () => _launchUrl(result.link!),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.streamingPoweredBy,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotOnUserServicesCard(int otherProvidersCount) {
    final hasOtherOptions = otherProvidersCount > 0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.warning, size: 20),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  hasOtherOptions
                      ? AppLocalizations.of(context)!.streamingNotOnYours
                      : AppLocalizations.of(context)!.streamingNoData,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.warning),
                ),
              ),
              if (hasOtherOptions)
                TextButton(
                  onPressed: () => setState(() => _showAllProviders = true),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.streamingOthers(otherProvidersCount),
                  ),
                ),
            ],
          ),
          if (!hasOtherOptions) ...[
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              AppLocalizations.of(context)!.streamingDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProviderSection({
    required IconData icon,
    required String label,
    required Color color,
    required List<WatchProvider> providers,
    bool isUserService = false,
    String? justWatchLink,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (isUserService) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AppLocalizations.of(context)!.streamingSubscription,
                  style: TextStyle(fontSize: 9, color: AppTheme.success),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: providers
              .map(
                (p) => StreamingProviderChip(
                  provider: p,
                  isUserService: isUserService,
                  onTap: _resolveProviderUrl(p.providerId, justWatchLink) != null
                      ? () => _launchUrl(
                          _resolveProviderUrl(p.providerId, justWatchLink)!)
                      : null,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  /// Get the direct search URL for a provider, or fallback to JustWatch
  String? _resolveProviderUrl(int providerId, String? fallbackUrl) {
    final searchUrlTemplate = providerSearchUrls[providerId];
    if (searchUrlTemplate != null) {
      final encodedTitle = Uri.encodeComponent(widget.mediaTitle);
      return searchUrlTemplate.replaceAll('{title}', encodedTitle);
    }
    return fallbackUrl;
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.textMuted),
          const SizedBox(width: AppTheme.spacingMd),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  String _getCountryName(String code) {
    return streamingCountries.firstWhere(
          (c) => c['code'] == code,
        )['name'] ??
        code;
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Ignore launch errors
    }
  }
}
