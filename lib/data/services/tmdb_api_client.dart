import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

// Conditional import: dart:io is not available on web.
// The _configureDioForNative helper is only called when !kIsWeb.
import 'tmdb_api_client_native.dart'
    if (dart.library.html) 'tmdb_api_client_web.dart'
    as platform;

/// Exception for TMDB API errors
class TmdbException implements Exception {
  final String message;

  const TmdbException(this.message);

  @override
  String toString() => 'TmdbException: $message';
}

/// A pure HTTP client for interacting with the TMDB API.
/// It receives parameters relevant to TMDB and returns raw JSON data
/// without parsing into domain models.
class TmdbApiClient {
  Dio? _dioInstance;

  /// Creates a TmdbApiClient with optional Dio injection for testing
  TmdbApiClient({Dio? dio}) : _dioInstance = dio;

  /// Lazy initialization of Dio to ensure ApiConfig is read after build-time defines
  Dio get _dio {
    if (_dioInstance == null) {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.tmdbBaseUrl, // -> Cloud Run proxy /tmdb/*
          queryParameters: {'language': ApiConfig.defaultLanguage},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      // On native platforms (macOS, iOS, Android), bypass the system proxy
      // to avoid network content filter issues. On web, use the default
      // browser adapter.
      platform.configureDio(dio);
      _dioInstance = dio;
    }
    return _dioInstance!;
  }

  /// Sends a raw GET request to the TMDB API and returns the parsed JSON data.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.plain),
      );
      final body = response.data as String;
      try {
        return jsonDecode(body);
      } catch (e) {
        debugPrint('TMDB JSON parse error for $path: $e');
        debugPrint(
          'Response body (first 500 chars): ${body.length > 500 ? body.substring(0, 500) : body}',
        );
        throw TmdbException('Invalid JSON response from proxy: $e');
      }
    } on DioException catch (e) {
      debugPrint(
        'TMDB API Error (${e.requestOptions.uri}): [${e.type}] ${e.message ?? "(no message)"}',
      );
      if (e.response != null) {
        debugPrint(
          'TMDB API Response Status: ${e.response?.statusCode}, Data: ${e.response?.data}',
        );
      }
      if (e.error != null) {
        debugPrint('TMDB API Underlying error: ${e.error}');
      }
      throw TmdbException('Request failed: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> searchMulti(
    String query, {
    int page = 1,
    bool includeAdult = false,
  }) async {
    return await get(
      '/search/multi',
      queryParameters: {
        'query': query,
        'page': page,
        'include_adult': includeAdult,
      },
    );
  }

  Future<Map<String, dynamic>> searchMovies(
    String query, {
    int page = 1,
    bool includeAdult = false,
  }) async {
    return await get(
      '/search/movie',
      queryParameters: {
        'query': query,
        'page': page,
        'include_adult': includeAdult,
      },
    );
  }

  Future<Map<String, dynamic>> searchTvSeries(
    String query, {
    int page = 1,
    bool includeAdult = false,
  }) async {
    return await get(
      '/search/tv',
      queryParameters: {
        'query': query,
        'page': page,
        'include_adult': includeAdult,
      },
    );
  }

  Future<Map<String, dynamic>> getTrending(
    String mediaPath,
    String timeWindow, {
    int page = 1,
  }) async {
    return await get(
      '/trending/$mediaPath/$timeWindow',
      queryParameters: {'page': page},
    );
  }

  Future<Map<String, dynamic>> getPopular(
    String mediaPath,
    int page,
    String? region,
  ) async {
    final params = <String, dynamic>{'page': page};
    if (region != null) params['region'] = region;
    return await get('/$mediaPath/popular', queryParameters: params);
  }

  Future<Map<String, dynamic>> getTopRated(
    String mediaPath,
    int page,
    String? region,
  ) async {
    final params = <String, dynamic>{'page': page};
    if (region != null) params['region'] = region;
    return await get('/$mediaPath/top_rated', queryParameters: params);
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    return await get(
      '/movie/$movieId',
      queryParameters: {
        'append_to_response':
            'credits,videos,recommendations,watch/providers,release_dates',
      },
    );
  }

  Future<Map<String, dynamic>> getTvDetails(int tvId) async {
    return await get(
      '/tv/$tvId',
      queryParameters: {
        'append_to_response':
            'credits,videos,recommendations,watch/providers,content_ratings',
      },
    );
  }

  Future<Map<String, dynamic>> getSimilar(String mediaPath, int mediaId) async {
    return await get('/$mediaPath/$mediaId/similar');
  }

  Future<Map<String, dynamic>> getRecommendations(
    String mediaPath,
    int mediaId,
  ) async {
    return await get('/$mediaPath/$mediaId/recommendations');
  }

  Future<Map<String, dynamic>> discoverMovies(
    Map<String, dynamic> queryParams,
  ) async {
    return await get('/discover/movie', queryParameters: queryParams);
  }

  Future<Map<String, dynamic>> discoverTvSeries(
    Map<String, dynamic> queryParams,
  ) async {
    return await get('/discover/tv', queryParameters: queryParams);
  }

  Future<Map<String, dynamic>> getWatchProviders(
    String mediaPath,
    int mediaId,
  ) async {
    return await get('/$mediaPath/$mediaId/watch/providers');
  }

  Future<Map<String, dynamic>> getPersonDetails(int personId) async {
    return await get('/person/$personId');
  }

  Future<Map<String, dynamic>> getPersonCredits(int personId) async {
    return await get('/person/$personId/combined_credits');
  }

  Future<Map<String, dynamic>> getTvSeasonDetails(
    int tvId,
    int seasonNumber,
  ) async {
    return await get('/tv/$tvId/season/$seasonNumber');
  }

  Future<Map<String, dynamic>> getList(int listId) async {
    return await get('/list/$listId');
  }
}
