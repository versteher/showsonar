/// Streaming provider information with TMDB integration
class StreamingProvider {
  final String id;
  final String name;
  final String logoPath;
  final int? tmdbId; // TMDB provider ID for API filtering
  final String? deepLink;
  final bool isPublicBroadcaster; // Public broadcasters like ARD, ZDF, Arte

  const StreamingProvider({
    required this.id,
    required this.name,
    required this.logoPath,
    this.tmdbId,
    this.deepLink,
    this.isPublicBroadcaster = false,
  });

  // ─── Global Major Platforms ─────────────────────────────────────
  static const netflix = StreamingProvider(
    id: 'netflix',
    name: 'Netflix',
    logoPath: 'assets/images/netflix_logo.png',
    tmdbId: 8,
  );

  static const disneyPlus = StreamingProvider(
    id: 'disney_plus',
    name: 'Disney+',
    logoPath: 'assets/images/disney_plus_logo.png',
    tmdbId: 337,
  );

  static const amazonPrime = StreamingProvider(
    id: 'amazon_prime',
    name: 'Amazon Prime',
    logoPath: 'assets/images/amazon_prime_logo.png',
    tmdbId: 9,
  );

  static const appleTv = StreamingProvider(
    id: 'apple_tv',
    name: 'Apple TV+',
    logoPath: 'assets/images/apple_tv_logo.png',
    tmdbId: 350,
  );

  static const paramountPlus = StreamingProvider(
    id: 'paramount_plus',
    name: 'Paramount+',
    logoPath: 'assets/images/paramount_plus_logo.png',
    tmdbId: 531,
  );

  static const crunchyroll = StreamingProvider(
    id: 'crunchyroll',
    name: 'Crunchyroll',
    logoPath: 'assets/images/crunchyroll_logo.png',
    tmdbId: 283,
  );

  static const hboMax = StreamingProvider(
    id: 'hbo_max',
    name: 'Max',
    logoPath: 'assets/images/hbo_max_logo.png',
    tmdbId: 1899,
  );

  static const mubi = StreamingProvider(
    id: 'mubi',
    name: 'MUBI',
    logoPath: 'assets/images/mubi_logo.png',
    tmdbId: 11,
  );

  // ─── US / North America ─────────────────────────────────────────
  static const hulu = StreamingProvider(
    id: 'hulu',
    name: 'Hulu',
    logoPath: 'assets/images/hulu_logo.png',
    tmdbId: 15,
  );

  static const peacock = StreamingProvider(
    id: 'peacock',
    name: 'Peacock',
    logoPath: 'assets/images/peacock_logo.png',
    tmdbId: 386,
  );

  static const fuboTv = StreamingProvider(
    id: 'fubo_tv',
    name: 'fuboTV',
    logoPath: 'assets/images/fubo_logo.png',
    tmdbId: 257,
  );

  static const crave = StreamingProvider(
    id: 'crave',
    name: 'Crave',
    logoPath: 'assets/images/crave_logo.png',
    tmdbId: 230,
  );

  // ─── UK ─────────────────────────────────────────────────────────
  static const britbox = StreamingProvider(
    id: 'britbox',
    name: 'BritBox',
    logoPath: 'assets/images/britbox_logo.png',
    tmdbId: 151,
  );

  // ─── Germany / DACH ─────────────────────────────────────────────
  static const rtlPlus = StreamingProvider(
    id: 'rtl_plus',
    name: 'RTL+',
    logoPath: 'assets/images/rtl_logo.png',
    tmdbId: 298,
  );

  static const joyn = StreamingProvider(
    id: 'joyn',
    name: 'Joyn',
    logoPath: 'assets/images/joyn_logo.png',
    tmdbId: 421,
  );

  static const wow = StreamingProvider(
    id: 'wow',
    name: 'WOW',
    logoPath: 'assets/images/wow_logo.png',
    tmdbId: 30,
  );

  static const magentaTv = StreamingProvider(
    id: 'magenta_tv',
    name: 'MagentaTV',
    logoPath: 'assets/images/magenta_logo.png',
    tmdbId: 178,
  );

  // German Public Broadcasters
  static const ardMediathek = StreamingProvider(
    id: 'ard_mediathek',
    name: 'ARD',
    logoPath: 'assets/images/ard_logo.png',
    tmdbId: 219,
    isPublicBroadcaster: true,
  );

  static const zdfMediathek = StreamingProvider(
    id: 'zdf_mediathek',
    name: 'ZDF',
    logoPath: 'assets/images/zdf_logo.png',
    tmdbId: 537,
    isPublicBroadcaster: true,
  );

  static const arte = StreamingProvider(
    id: 'arte',
    name: 'Arte',
    logoPath: 'assets/images/arte_logo.png',
    tmdbId: 234,
    isPublicBroadcaster: true,
  );

  // Switzerland
  static const srfPlay = StreamingProvider(
    id: 'srf_play',
    name: 'SRF Play',
    logoPath: 'assets/images/srf_logo.png',
    tmdbId: 222,
    isPublicBroadcaster: true,
  );

  static const playsuisse = StreamingProvider(
    id: 'play_suisse',
    name: 'Play Suisse',
    logoPath: 'assets/images/playsuisse_logo.png',
    tmdbId: 691,
    isPublicBroadcaster: true,
  );

  // Denmark
  static const drTv = StreamingProvider(
    id: 'dr_tv',
    name: 'DR TV',
    logoPath: 'assets/images/dr_logo.png',
    tmdbId: 620,
    isPublicBroadcaster: true,
  );

  // ─── France ─────────────────────────────────────────────────────
  static const canalPlus = StreamingProvider(
    id: 'canal_plus',
    name: 'Canal+',
    logoPath: 'assets/images/canal_plus_logo.png',
    tmdbId: 381,
  );

  // ─── Spain ──────────────────────────────────────────────────────
  static const movistarPlus = StreamingProvider(
    id: 'movistar_plus',
    name: 'Movistar+',
    logoPath: 'assets/images/movistar_logo.png',
    tmdbId: 2241,
  );

  static const filmin = StreamingProvider(
    id: 'filmin',
    name: 'Filmin',
    logoPath: 'assets/images/filmin_logo.png',
    tmdbId: 63,
  );

  // ─── Nordics ────────────────────────────────────────────────────
  static const viaplay = StreamingProvider(
    id: 'viaplay',
    name: 'Viaplay',
    logoPath: 'assets/images/viaplay_logo.png',
    tmdbId: 76,
  );

  static const skyShowtime = StreamingProvider(
    id: 'skyshowtime',
    name: 'SkyShowtime',
    logoPath: 'assets/images/skyshowtime_logo.png',
    tmdbId: 1773,
  );

  // ─── Netherlands ────────────────────────────────────────────────
  static const videoland = StreamingProvider(
    id: 'videoland',
    name: 'Videoland',
    logoPath: 'assets/images/videoland_logo.png',
    tmdbId: 72,
  );

  // ─── Finland ────────────────────────────────────────────────────
  static const yleAreena = StreamingProvider(
    id: 'yle_areena',
    name: 'Yle Areena',
    logoPath: 'assets/images/yle_logo.png',
    tmdbId: 323,
    isPublicBroadcaster: true,
  );

  // ─── Australia ──────────────────────────────────────────────────
  static const foxtelNow = StreamingProvider(
    id: 'foxtel_now',
    name: 'Foxtel Now',
    logoPath: 'assets/images/foxtel_logo.png',
    tmdbId: 134,
  );

  // ─── Africa ─────────────────────────────────────────────────────
  static const showmax = StreamingProvider(
    id: 'showmax',
    name: 'ShowMax',
    logoPath: 'assets/images/showmax_logo.png',
    tmdbId: 55,
  );

  // ─── Latin America ──────────────────────────────────────────────
  static const claroVideo = StreamingProvider(
    id: 'claro_video',
    name: 'Claro video',
    logoPath: 'assets/images/claro_logo.png',
    tmdbId: 167,
  );

  // ─── Japan ──────────────────────────────────────────────────────
  static const uNext = StreamingProvider(
    id: 'u_next',
    name: 'U-NEXT',
    logoPath: 'assets/images/unext_logo.png',
    tmdbId: 84,
  );

  // ─── South Korea ────────────────────────────────────────────────
  static const wavve = StreamingProvider(
    id: 'wavve',
    name: 'wavve',
    logoPath: 'assets/images/wavve_logo.png',
    tmdbId: 356,
  );

  static const watcha = StreamingProvider(
    id: 'watcha',
    name: 'Watcha',
    logoPath: 'assets/images/watcha_logo.png',
    tmdbId: 97,
  );

  // ─── India ──────────────────────────────────────────────────────
  static const jioHotstar = StreamingProvider(
    id: 'jio_hotstar',
    name: 'JioHotstar',
    logoPath: 'assets/images/hotstar_logo.png',
    tmdbId: 2336,
  );

  static const zee5 = StreamingProvider(
    id: 'zee5',
    name: 'Zee5',
    logoPath: 'assets/images/zee5_logo.png',
    tmdbId: 232,
  );

  // ─── Southeast Asia ─────────────────────────────────────────────
  static const viu = StreamingProvider(
    id: 'viu',
    name: 'Viu',
    logoPath: 'assets/images/viu_logo.png',
    tmdbId: 158,
  );

  static const iflix = StreamingProvider(
    id: 'iflix',
    name: 'iflix',
    logoPath: 'assets/images/iflix_logo.png',
    tmdbId: 160,
  );

  // ─── Turkey ─────────────────────────────────────────────────────
  static const puhutv = StreamingProvider(
    id: 'puhutv',
    name: 'puhutv',
    logoPath: 'assets/images/puhutv_logo.png',
    tmdbId: 342,
  );

  // ─── Russia ─────────────────────────────────────────────────────
  static const okko = StreamingProvider(
    id: 'okko',
    name: 'Okko',
    logoPath: 'assets/images/okko_logo.png',
    tmdbId: 115,
  );

  // =====================================================================
  // Provider Lists
  // =====================================================================

  /// Global platforms available virtually everywhere
  static const List<StreamingProvider> globalProviders = [
    netflix,
    disneyPlus,
    amazonPrime,
    appleTv,
  ];

  /// All providers combined (for lookup purposes)
  static List<StreamingProvider> get allProviders => [
    // Global
    netflix, disneyPlus, amazonPrime, appleTv,
    paramountPlus, crunchyroll, hboMax, mubi,
    // US/NA
    hulu, peacock, fuboTv, crave,
    // UK
    britbox,
    // DACH
    rtlPlus, joyn, wow, magentaTv,
    ardMediathek, zdfMediathek, arte,
    srfPlay, playsuisse,
    // France
    canalPlus,
    // Spain
    movistarPlus, filmin,
    // Nordics
    viaplay, skyShowtime, drTv, yleAreena,
    // Netherlands
    videoland,
    // Australia
    foxtelNow,
    // Africa
    showmax,
    // Latin America
    claroVideo,
    // Japan
    uNext,
    // South Korea
    wavve, watcha,
    // India
    jioHotstar, zee5,
    // SEA
    viu, iflix,
    // Turkey
    puhutv,
    // Russia
    okko,
  ];

  /// Country-to-providers mapping: returns the providers most relevant
  /// to the given country code. Global platforms (Netflix, Disney+, Amazon,
  /// Apple TV+) are always included first.
  static List<StreamingProvider> getProvidersForCountry(String countryCode) {
    final regional = _countryProviders[countryCode.toUpperCase()];
    if (regional == null) {
      // Unknown country → just show global platforms + some popular ones
      return [...globalProviders, paramountPlus, hboMax, crunchyroll];
    }

    // Combine global + regional, remove duplicates
    final result = <StreamingProvider>[...globalProviders];
    for (final p in regional) {
      if (!result.contains(p)) result.add(p);
    }
    return result;
  }

  /// Country → regional providers (on top of globalProviders)
  static const Map<String, List<StreamingProvider>> _countryProviders = {
    // ─── Americas ─────────────────────────────────────────────────
    'US': [paramountPlus, hboMax, hulu, peacock, fuboTv, crunchyroll],
    'CA': [paramountPlus, crave, crunchyroll, hboMax],
    'MX': [paramountPlus, hboMax, crunchyroll, claroVideo],
    'BR': [paramountPlus, hboMax, claroVideo, crunchyroll],
    'AR': [paramountPlus, hboMax, crunchyroll],
    'CO': [paramountPlus, hboMax, claroVideo],
    'CL': [paramountPlus, hboMax, crunchyroll],
    'PE': [paramountPlus, hboMax],
    'EC': [paramountPlus],
    'VE': [paramountPlus, hboMax],
    'UY': [paramountPlus, hboMax],

    // ─── UK / Ireland ─────────────────────────────────────────────
    'GB': [paramountPlus, crunchyroll, britbox, hboMax],
    'IE': [paramountPlus, britbox],

    // ─── Germany / Austria / Switzerland ──────────────────────────
    'DE': [
      paramountPlus,
      hboMax,
      crunchyroll,
      rtlPlus,
      joyn,
      wow,
      magentaTv,
      ardMediathek,
      zdfMediathek,
      arte,
    ],
    'AT': [
      paramountPlus,
      hboMax,
      crunchyroll,
      rtlPlus,
      joyn,
      wow,
      ardMediathek,
      zdfMediathek,
      arte,
    ],
    'CH': [paramountPlus, crunchyroll, srfPlay, playsuisse, arte],

    // ─── France ───────────────────────────────────────────────────
    'FR': [paramountPlus, canalPlus, crunchyroll, arte, hboMax],

    // ─── Spain ────────────────────────────────────────────────────
    'ES': [paramountPlus, hboMax, movistarPlus, filmin, crunchyroll],

    // ─── Italy ────────────────────────────────────────────────────
    'IT': [paramountPlus, crunchyroll, hboMax],

    // ─── Portugal ─────────────────────────────────────────────────
    'PT': [paramountPlus, hboMax],

    // ─── Netherlands / Belgium ────────────────────────────────────
    'NL': [paramountPlus, viaplay, videoland, hboMax, skyShowtime],
    'BE': [paramountPlus, viaplay, hboMax, skyShowtime],

    // ─── Nordics ──────────────────────────────────────────────────
    'SE': [paramountPlus, viaplay, skyShowtime, crunchyroll],
    'NO': [paramountPlus, viaplay, skyShowtime],
    'DK': [paramountPlus, viaplay, skyShowtime, drTv],
    'FI': [paramountPlus, viaplay, skyShowtime, yleAreena],

    // ─── Eastern Europe ───────────────────────────────────────────
    'PL': [paramountPlus, skyShowtime, hboMax],
    'CZ': [paramountPlus, skyShowtime, hboMax],
    'HU': [paramountPlus, skyShowtime, hboMax],
    'RO': [paramountPlus, skyShowtime, hboMax],
    'BG': [paramountPlus],
    'HR': [paramountPlus],
    'SK': [paramountPlus, skyShowtime],

    // ─── Turkey ───────────────────────────────────────────────────
    'TR': [puhutv, crunchyroll, mubi],

    // ─── Russia ───────────────────────────────────────────────────
    'RU': [okko],

    // ─── Australia / NZ ───────────────────────────────────────────
    'AU': [paramountPlus, foxtelNow, britbox, crunchyroll],
    'NZ': [paramountPlus, crunchyroll],

    // ─── Japan ────────────────────────────────────────────────────
    'JP': [hulu, uNext, crunchyroll],

    // ─── South Korea ──────────────────────────────────────────────
    'KR': [wavve, watcha, crunchyroll],

    // ─── India ────────────────────────────────────────────────────
    'IN': [jioHotstar, zee5, crunchyroll, paramountPlus],

    // ─── Southeast Asia ───────────────────────────────────────────
    'SG': [paramountPlus, viu],
    'MY': [viu, iflix],
    'ID': [viu, iflix],
    'TH': [viu, iflix],
    'PH': [viu, iflix],
    'TW': [paramountPlus, crunchyroll],
    'HK': [paramountPlus, viu],

    // ─── Middle East ──────────────────────────────────────────────
    'AE': [paramountPlus, zee5],
    'SA': [paramountPlus, zee5],
    'IL': [paramountPlus],
    'QA': [zee5],
    'KW': [zee5],
    'JO': [zee5],
    'LB': [zee5],
    'BH': [zee5],
    'EG': [paramountPlus, zee5],

    // ─── Africa ───────────────────────────────────────────────────
    'ZA': [showmax, paramountPlus],
    'NG': [showmax],
    'KE': [showmax],
  };

  /// Legacy list kept for backwards compatibility
  static const List<StreamingProvider> commercialProviders = [
    netflix,
    disneyPlus,
    amazonPrime,
    hboMax,
    appleTv,
  ];

  /// Public broadcasters (free)
  static const List<StreamingProvider> publicBroadcasters = [
    ardMediathek,
    zdfMediathek,
    arte,
    srfPlay,
    drTv,
  ];

  /// Get provider by internal ID
  static StreamingProvider? fromId(String id) {
    try {
      return allProviders.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Map of TMDB provider variant IDs → canonical internal provider ID.
  /// Needed because TMDB uses multiple IDs for the same service
  /// (e.g. Netflix Kids=175, Netflix with Ads=1796 all map to netflix).
  static const Map<int, String> _tmdbIdToProviderId = {
    // Netflix variants
    8: 'netflix',
    175: 'netflix', // Netflix Kids
    1796: 'netflix', // Netflix Standard with Ads
    // Amazon variants
    9: 'amazon_prime', // Amazon Prime Video (DE)
    10: 'amazon_prime', // Amazon Video
    119: 'amazon_prime', // Amazon Prime Video (Global)
    // HBO Max / Max variants
    1899: 'hbo_max', // Max
    384: 'hbo_max', // HBO Max alternate ID
    1825: 'hbo_max', // HBO Max Amazon Channel
    // Paramount+ variants
    531: 'paramount_plus',
    582: 'paramount_plus', // Paramount+ Amazon Channel
    // Crunchyroll variants
    283: 'crunchyroll',
    1968: 'crunchyroll', // Crunchyroll Amazon channel
    // Apple TV+ variants
    350: 'apple_tv',
    2: 'apple_tv', // Apple TV Store
    // Disney+
    337: 'disney_plus',
    // ZDF variants
    537: 'zdf_mediathek',
    36: 'zdf_mediathek', // ZDF Mediathek legacy
    // Arte variants
    234: 'arte',
    354: 'arte', // Arte alternate ID
  };

  /// Get provider by TMDB ID. Handles known variant IDs for the same service
  /// (e.g. Netflix Kids, Netflix with Ads → netflix).
  static StreamingProvider? fromTmdbId(int tmdbId) {
    // First check the variant map for fast lookup
    final providerId = _tmdbIdToProviderId[tmdbId];
    if (providerId != null) return fromId(providerId);

    // Fallback: linear search through all providers by tmdbId
    try {
      return allProviders.firstWhere((p) => p.tmdbId == tmdbId);
    } catch (_) {
      return null;
    }
  }

  /// Get TMDB IDs for a list of provider IDs, including all known variant IDs.
  /// For example, selecting "netflix" returns [8, 175, 1796] so the TMDB
  /// discover API finds content on Netflix Kids and Netflix with Ads too.
  static List<int> getTmdbIds(List<String> providerIds) {
    final result = <int>{};
    for (final id in providerIds) {
      final provider = fromId(id);
      if (provider?.tmdbId != null) result.add(provider!.tmdbId!);
    }
    // Also include all variant IDs that map to one of the selected providers
    for (final entry in _tmdbIdToProviderId.entries) {
      if (providerIds.contains(entry.value)) {
        result.add(entry.key);
      }
    }
    return result.toList();
  }

  /// Get the default subscribed provider IDs for a country
  static List<String> getDefaultServiceIds(String countryCode) {
    final providers = getProvidersForCountry(countryCode);
    // Return the first 4 providers as default subscriptions
    return providers.take(4).map((p) => p.id).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamingProvider &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'StreamingProvider(id: $id, name: $name, tmdbId: $tmdbId)';
}
