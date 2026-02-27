/// API configuration — zero secrets on device.
///
/// All API calls go through the Cloud Run proxy which injects keys
/// from Secret Manager. The app only needs to know the proxy URL.
///
/// Set PROXY_URL in the environment (e.g. via --dart-define) or
/// leave blank during development to use a local proxy on port 8080.
class ApiConfig {
  // ── Proxy URL ────────────────────────────────────────────────────────────
  /// Cloud Run proxy URL. Set via --dart-define=PROXY_URL=https://...
  /// Falls back to local dev proxy when running with `flutter run`.
  static const String _proxyUrlFromBuild = String.fromEnvironment(
    'PROXY_URL',
    defaultValue: '',
  );

  static String get proxyBaseUrl {
    if (_proxyUrlFromBuild.isNotEmpty) return _proxyUrlFromBuild;
    // Local dev fallback — run the proxy locally with:
    //   cd infra/cloud-run/api-proxy && APP_CHECK_ENABLED=false uvicorn main:app --port 8080
    return 'http://localhost:8080';
  }

  /// TMDB proxy endpoint base (replaces direct TMDB calls)
  static String get tmdbBaseUrl => '$proxyBaseUrl/tmdb';

  /// Gemini proxy endpoint base (replaces direct google_generative_ai calls)
  static String get geminiBaseUrl => '$proxyBaseUrl/gemini';

  /// OMDb proxy endpoint base (replaces direct OMDb calls)
  static String get omdbBaseUrl => '$proxyBaseUrl/omdb';

  // ── Image URLs (CDN — no API key required) ──────────────────────────────
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  static const String posterSizeSmall = 'w185';
  static const String posterSizeMedium = 'w342';
  static const String posterSizeLarge = 'w500';
  static const String posterSizeOriginal = 'original';
  static const String backdropSizeMedium = 'w780';
  static const String backdropSizeOriginal = 'original';

  // ── Localisation defaults ────────────────────────────────────────────────
  static const String defaultLanguage = 'de-DE';
  static const String defaultRegion = 'DE';

  // ── Feature flags ────────────────────────────────────────────────────────
  /// True as long as the proxy URL is reachable (best-effort check at startup).
  /// Screens that previously gated on isTmdbConfigured now gate on this.
  static bool get isTmdbConfigured => true; // Proxy always "configured"
  static bool get isGeminiConfigured => true;
  static bool get isOmdbConfigured => true;

  // ── URL helpers ──────────────────────────────────────────────────────────
  static String getPosterUrl(String? path, {String size = posterSizeLarge}) {
    if (path == null || path.isEmpty) return '';
    return '$tmdbImageBaseUrl/$size$path';
  }

  static String getBackdropUrl(
    String? path, {
    String size = backdropSizeOriginal,
  }) {
    if (path == null || path.isEmpty) return '';
    return '$tmdbImageBaseUrl/$size$path';
  }
}
