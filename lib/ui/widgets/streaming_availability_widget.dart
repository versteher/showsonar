import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../../data/models/streaming_provider.dart';
import '../../data/repositories/tmdb_repository.dart';
import '../theme/app_theme.dart';

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

/// Map of TMDB provider IDs to their search URL templates.
/// {title} will be replaced with the URL-encoded media title.
/// Covers the top providers from 20+ worldwide regions.
/// For providers not listed here, the widget falls back to the TMDB/JustWatch link.
const _providerSearchUrls = <int, String>{
  // ─── Global Major Platforms ───────────────────────────────────────
  8: 'https://www.netflix.com/search?q={title}', // Netflix
  175: 'https://www.netflix.com/search?q={title}', // Netflix Kids
  1796: 'https://www.netflix.com/search?q={title}', // Netflix Standard with Ads
  9: 'https://www.amazon.com/s?k={title}&i=instant-video', // Amazon Prime Video (DE)
  10: 'https://www.amazon.com/s?k={title}&i=instant-video', // Amazon Video
  119:
      'https://www.amazon.com/s?k={title}&i=instant-video', // Amazon Prime Video (Global)
  337: 'https://www.disneyplus.com/search/{title}', // Disney Plus
  2: 'https://tv.apple.com/search?term={title}', // Apple TV Store
  350: 'https://tv.apple.com/search?term={title}', // Apple TV+
  3: 'https://play.google.com/store/search?q={title}&c=movies', // Google Play Movies
  192: 'https://www.youtube.com/results?search_query={title}', // YouTube
  188:
      'https://www.youtube.com/results?search_query={title}', // YouTube Premium
  531: 'https://www.paramountplus.com/search/?q={title}', // Paramount Plus
  582:
      'https://www.paramountplus.com/search/?q={title}', // Paramount+ Amazon Channel
  283: 'https://www.crunchyroll.com/search?q={title}', // Crunchyroll
  1899: 'https://www.max.com/search?q={title}', // Max (HBO Max)
  384: 'https://www.max.com/search?q={title}', // HBO Max (alternate ID)
  1825: 'https://www.max.com/search?q={title}', // HBO Max Amazon Channel
  11: 'https://mubi.com/films?q={title}', // MUBI
  100: 'https://guidedoc.tv/search?q={title}', // GuideDoc
  35: 'https://rakuten.tv/de/search?q={title}', // Rakuten TV
  // ─── US / North America ───────────────────────────────────────────
  15: 'https://www.hulu.com/search?q={title}', // Hulu
  386: 'https://www.peacocktv.com/search?q={title}', // Peacock Premium
  257: 'https://www.fubo.tv/search?q={title}', // fuboTV
  207: 'https://therokuchannel.roku.com/search/{title}', // The Roku Channel
  526: 'https://www.amcplus.com/search?q={title}', // AMC+
  230: 'https://www.crave.ca/search?q={title}', // Crave (Canada)
  212: 'https://www.hoopladigital.com/search?q={title}', // Hoopla (US/CA)
  // ─── UK / Ireland ─────────────────────────────────────────────────
  151: 'https://www.britbox.com/search?q={title}', // BritBox
  // ─── Australia / New Zealand ──────────────────────────────────────
  134: 'https://www.foxtel.com.au/now/search.html?q={title}', // Foxtel Now (AU)
  // ─── Germany / DACH ───────────────────────────────────────────────
  421: 'https://www.joyn.de/suche?q={title}', // Joyn
  298: 'https://www.rtl-plus.de/suche?q={title}', // RTL+
  178: 'https://www.magentatv.de/suche?q={title}', // MagentaTV
  30: 'https://www.wow.sky.de/suche/{title}', // WOW (Sky DE)
  29: 'https://www.sky.de/suche/{title}', // Sky Go (DE)
  20: 'https://www.maxdome.de/suche/{title}', // maxdome Store
  613: 'https://www.freenet-video.de/suche?q={title}', // freenet Video
  177: 'https://www.chili.com/de/search?q={title}', // Chili
  // German Public Broadcasters (free)
  234: 'https://www.arte.tv/de/search/?q={title}', // ARTE
  354: 'https://www.arte.tv/de/search/?q={title}', // ARTE (alternate ID)
  219: 'https://www.ardmediathek.de/suche/{title}', // ARD Mediathek
  36: 'https://www.zdf.de/suche?q={title}', // ZDF Mediathek (Legacy)
  537: 'https://www.zdf.de/suche?q={title}', // ZDF Mediathek
  // Switzerland
  150: 'https://www.blueplus.ch/de/search?q={title}', // blue TV (CH)
  691: 'https://www.playsuisse.ch/search?q={title}', // Play Suisse (CH)
  222: 'https://www.srf.ch/play/tv/suche?q={title}', // SRF Play (CH)
  210: 'https://www.sky.ch/de/search?q={title}', // Sky (CH)
  // ─── France ───────────────────────────────────────────────────────
  381: 'https://www.canalplus.com/recherche/?q={title}', // Canal+
  // ─── Spain ────────────────────────────────────────────────────────
  63: 'https://www.filmin.es/search?q={title}', // Filmin
  2241: 'https://ver.movistarplus.es/busqueda?q={title}', // Movistar Plus+
  149:
      'https://ver.movistarplus.es/busqueda?q={title}', // Movistar Plus+ Ficción Total
  // ─── Nordics (SE, NO, DK, FI) ────────────────────────────────────
  76: 'https://viaplay.com/search?q={title}', // Viaplay
  1773: 'https://www.skyshowtime.com/search?q={title}', // SkyShowtime
  620: 'https://www.dr.dk/drtv/soeg?q={title}', // DR TV (Denmark)
  // ─── Netherlands / Belgium ────────────────────────────────────────
  72: 'https://www.videoland.com/search?q={title}', // Videoland (NL)
  71: 'https://www.pathe-thuis.nl/search?q={title}', // Pathé Thuis (NL)
  297: 'https://www.ziggogo.tv/search?q={title}', // Ziggo TV (NL)
  // ─── Latin America (BR, MX, AR, CO, CL) ──────────────────────────
  167: 'https://www.clarovideo.com/buscar?q={title}', // Claro video
  339: 'https://www.movistartv.com/buscar?q={title}', // MovistarTV (AR)
  47: 'https://www.looke.com.br/search?q={title}', // Looke (BR)
  // ─── Japan ────────────────────────────────────────────────────────
  84: 'https://video.unext.jp/search?query={title}', // U-NEXT
  // ─── South Korea ──────────────────────────────────────────────────
  356: 'https://www.wavve.com/search?searchWord={title}', // wavve
  97: 'https://watcha.com/search?query={title}', // Watcha
  // ─── India ────────────────────────────────────────────────────────
  2336: 'https://www.hotstar.com/in/search?q={title}', // JioHotstar
  232: 'https://www.zee5.com/search?q={title}', // Zee5
  // ─── Turkey ───────────────────────────────────────────────────────
  342: 'https://puhutv.com/ara?q={title}', // puhutv
  // ─── Russia ────────────────────────────────────────────────────────
  115: 'https://okko.tv/search?query={title}', // Okko
  116: 'https://www.amediateka.ru/search?q={title}', // Amediateka
  // ─── Finland ───────────────────────────────────────────────────────
  323: 'https://areena.yle.fi/haku?q={title}', // Yle Areena
  338: 'https://www.ruutu.fi/haku?q={title}', // Ruutu
  // ─── Southeast Asia ────────────────────────────────────────────────
  158: 'https://www.viu.com/ott/search?q={title}', // Viu
  160: 'https://www.iflix.com/search?q={title}', // iflix
  159: 'https://www.catchplay.com/search?q={title}', // Catchplay
  // ─── Africa ───────────────────────────────────────────────────────
  55: 'https://www.showmax.com/search?q={title}', // ShowMax (ZA)
  // ─── Apple TV Channels (various sub-providers) ────────────────────
  1852: 'https://tv.apple.com/search?term={title}', // Britbox Apple TV
  1853: 'https://tv.apple.com/search?term={title}', // Paramount Plus Apple TV
  1854: 'https://tv.apple.com/search?term={title}', // AMC Plus Apple TV
  1855: 'https://tv.apple.com/search?term={title}', // Starz Apple TV
  // ─── Amazon Channels (various sub-providers) ──────────────────────
  528:
      'https://www.amazon.com/s?k={title}&i=instant-video', // AMC+ Amazon Channel
  1968:
      'https://www.amazon.com/s?k={title}&i=instant-video', // Crunchyroll Amazon
  583:
      'https://www.amazon.com/s?k={title}&i=instant-video', // MGM+ Amazon Channel
  // ─── Roku Channels (various sub-providers) ────────────────────────
  633: 'https://therokuchannel.roku.com/search/{title}', // Paramount+ Roku
  634: 'https://therokuchannel.roku.com/search/{title}', // Starz Roku
  635: 'https://therokuchannel.roku.com/search/{title}', // AMC+ Roku
  636: 'https://therokuchannel.roku.com/search/{title}', // MGM Plus Roku
};

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

  static const _countries = [
    {'code': 'DE', 'name': 'Deutschland', 'flag': '🇩🇪'},
    {'code': 'AT', 'name': 'Österreich', 'flag': '🇦🇹'},
    {'code': 'CH', 'name': 'Schweiz', 'flag': '🇨🇭'},
    {'code': 'DK', 'name': 'Dänemark', 'flag': '🇩🇰'},
    {'code': 'US', 'name': 'USA', 'flag': '🇺🇸'},
    {'code': 'GB', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': 'FR', 'name': 'Frankreich', 'flag': '🇫🇷'},
    {'code': 'ES', 'name': 'Spanien', 'flag': '🇪🇸'},
    {'code': 'IT', 'name': 'Italien', 'flag': '🇮🇹'},
    {'code': 'NL', 'name': 'Niederlande', 'flag': '🇳🇱'},
    {'code': 'SE', 'name': 'Schweden', 'flag': '🇸🇪'},
    {'code': 'NO', 'name': 'Norwegen', 'flag': '🇳🇴'},
  ];

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
            _buildCountrySelector(),
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

  Widget _buildCountrySelector() {
    final country = _countries.firstWhere((c) => c['code'] == _selectedCountry);

    return PopupMenuButton<String>(
      initialValue: _selectedCountry,
      onSelected: (code) => setState(() => _selectedCountry = code),
      itemBuilder: (context) => _countries
          .map(
            (c) => PopupMenuItem(
              value: c['code'],
              child: Row(
                children: [
                  Text(c['flag']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(c['name']!),
                  if (c['code'] == _selectedCountry) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: AppTheme.primary, size: 18),
                  ],
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(country['flag']!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              country['code']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
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
              .map((p) => _buildProviderChip(p, isUserService, justWatchLink))
              .toList(),
        ),
      ],
    );
  }

  /// Get the direct search URL for a provider, or fallback to JustWatch
  String? _getProviderUrl(int providerId, String? fallbackUrl) {
    final searchUrlTemplate = _providerSearchUrls[providerId];
    if (searchUrlTemplate != null) {
      final encodedTitle = Uri.encodeComponent(widget.mediaTitle);
      return searchUrlTemplate.replaceAll('{title}', encodedTitle);
    }
    return fallbackUrl;
  }

  Widget _buildProviderChip(
    WatchProvider provider,
    bool isUserService,
    String? justWatchLink,
  ) {
    final providerUrl = _getProviderUrl(provider.providerId, justWatchLink);

    return GestureDetector(
      onTap: providerUrl != null ? () => _launchUrl(providerUrl) : null,
      child: MouseRegion(
        cursor: providerUrl != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isUserService
                ? AppTheme.success.withValues(alpha: 0.1)
                : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUserService
                  ? AppTheme.success.withValues(alpha: 0.5)
                  : AppTheme.surfaceBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.logoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: provider.fullLogoUrl,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 24,
                      height: 24,
                      color: AppTheme.surface,
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.play_circle,
                      size: 24,
                      color: AppTheme.textMuted,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.play_circle,
                  size: 24,
                  color: AppTheme.textMuted,
                ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  provider.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isUserService
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (justWatchLink != null) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.open_in_new,
                  size: 12,
                  color: AppTheme.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
    return _countries.firstWhere((c) => c['code'] == code)['name'] ?? code;
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Ignore launch errors
    }
  }
}
