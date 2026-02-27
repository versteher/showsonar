/// Maps numeric age limits to regional certification strings (e.g. FSK, MPAA)
class AgeRatingMapper {
  /// Returns the TMDB certification string for a given max age and region.
  static String? getCertification(String region, int maxAge) {
    if (maxAge >= 18) return null; // No restriction effectively

    switch (region.toUpperCase()) {
      case 'DE':
        return _getDECertification(maxAge);
      case 'US':
        return _getUSCertification(maxAge);
      case 'GB':
        return _getGBCertification(maxAge);
      default:
        // Default to FSK-like logic if unknown, or maybe US?
        // Let's fallback to DE for now as it's the primary market, or just return raw age
        return _getDECertification(maxAge);
    }
  }

  /// Maps internal age limit to FSK (DE) certification
  static String _getDECertification(int age) {
    if (age < 6) return '0';
    if (age < 12) return '6';
    if (age < 16) return '12';
    if (age < 18) return '16';
    return '18';
  }

  /// Maps internal age limit to MPAA (US) certification
  /// US Ratings: G (0), PG (~6-9), PG-13 (12-13), R (17), NC-17 (18)
  static String _getUSCertification(int age) {
    if (age < 6) return 'G';
    if (age < 12) return 'PG';
    if (age < 16) return 'PG-13';
    if (age < 18) return 'R';
    return 'NC-17';
  }

  /// Maps internal age limit to BBFC (GB) certification
  /// U (0), PG (~8), 12A/12 (12), 15 (15), 18 (18)
  static String _getGBCertification(int age) {
    if (age < 8) return 'U';
    if (age < 12) return 'PG';
    if (age < 15) return '12';
    if (age < 18) return '15';
    return '18';
  }

  /// Parses a certification string back to a numeric age level for client-side filtering
  static int getAgeLevel(String? region, String? certification) {
    if (certification == null || certification.isEmpty) return 100; // Unrated

    // Normalize
    final cert = certification.trim().toUpperCase();
    final reg = region?.toUpperCase() ?? 'DE'; // Default to DE parsing

    switch (reg) {
      case 'US':
        return _parseUS(cert);
      case 'GB':
        return _parseGB(cert);
      case 'DE':
      default:
        return _parseDE(cert);
    }
  }

  static int _parseDE(String cert) {
    // "FSK 12", "12", etc.
    final clean = cert.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 100;
  }

  static int _parseUS(String cert) {
    switch (cert) {
      case 'G':
        return 0;
      case 'PG':
        return 6;
      case 'PG-13':
        return 12;
      case 'R':
        return 16;
      case 'NC-17':
        return 18;
      case 'NR':
      case 'UNRATED':
        return 100;
      default:
        return 100;
    }
  }

  static int _parseGB(String cert) {
    switch (cert) {
      case 'U':
        return 0;
      case 'PG':
        return 8;
      case '12':
      case '12A':
        return 12;
      case '15':
        return 15;
      case '18':
      case 'R18':
        return 18;
      default:
        return 100;
    }
  }
}
