import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

/// Rotten Tomatoes / OMDb rating data
class OmdbRatings {
  /// Rotten Tomatoes Tomatometer (critics) — e.g. "94%"
  final String? tomatometer;

  /// Rotten Tomatoes Audience Score — e.g. "88%"
  final String? audienceScore;

  /// Metacritic score — e.g. "74/100"
  final String? metacritic;

  const OmdbRatings({this.tomatometer, this.audienceScore, this.metacritic});

  bool get hasTomatometer => tomatometer != null;
  bool get hasAudienceScore => audienceScore != null;
  bool get hasAnyRating =>
      hasTomatometer || hasAudienceScore || metacritic != null;

  /// Parse tomatometer percent integer (e.g. 94 from "94%")
  int? get tomatometerInt {
    final s = tomatometer?.replaceAll('%', '').trim();
    return s != null ? int.tryParse(s) : null;
  }

  /// Parse audience score percent integer
  int? get audienceScoreInt {
    final s = audienceScore?.replaceAll('%', '').trim();
    return s != null ? int.tryParse(s) : null;
  }
}

/// Service to fetch Rotten Tomatoes scores & Metacritic via OMDb API.
/// All calls go through the Cloud Run proxy — no API key on device.
class OmdbService {
  /// Fetch rating data by IMDb ID (e.g. "tt1375666")
  Future<OmdbRatings?> fetchByImdbId(String imdbId) async {
    if (!ApiConfig.isOmdbConfigured) return null;
    if (imdbId.isEmpty) return null;

    try {
      // Proxy at /omdb injects the apikey — we just pass the query params
      final uri = Uri.parse(
        ApiConfig.omdbBaseUrl,
      ).replace(queryParameters: {'i': imdbId});
      final response = await http.get(uri).timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['Response'] == 'False') return null;

      final ratings =
          (data['Ratings'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
          [];

      String? tomatometer;
      String? audienceScore;
      String? metacritic;

      for (final r in ratings) {
        final source = r['Source'] as String? ?? '';
        final value = r['Value'] as String? ?? '';
        if (source == 'Rotten Tomatoes') {
          tomatometer = value;
        } else if (source == 'Metacritic') {
          metacritic = value;
        }
      }

      final extVotes = data['tomatoUserMeter'] as String?;
      if (extVotes != null && extVotes != 'N/A') {
        audienceScore = '$extVotes%';
      }

      return OmdbRatings(
        tomatometer: tomatometer?.isNotEmpty == true ? tomatometer : null,
        audienceScore: audienceScore,
        metacritic: metacritic?.isNotEmpty == true ? metacritic : null,
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch by title + year (fallback when imdbId is not available)
  Future<OmdbRatings?> fetchByTitle(String title, {int? year}) async {
    if (!ApiConfig.isOmdbConfigured) return null;

    try {
      final queryParams = <String, String>{'t': title};
      if (year != null) queryParams['y'] = year.toString();

      final uri = Uri.parse(
        ApiConfig.omdbBaseUrl,
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['Response'] == 'False') return null;

      final ratings =
          (data['Ratings'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
          [];
      String? tomatometer;
      String? metacritic;

      for (final r in ratings) {
        final source = r['Source'] as String? ?? '';
        final value = r['Value'] as String? ?? '';
        if (source == 'Rotten Tomatoes') {
          tomatometer = value;
        } else if (source == 'Metacritic') {
          metacritic = value;
        }
      }

      return OmdbRatings(
        tomatometer: tomatometer?.isNotEmpty == true ? tomatometer : null,
        metacritic: metacritic?.isNotEmpty == true ? metacritic : null,
      );
    } catch (e) {
      return null;
    }
  }
}
