// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:neon_voyager/data/models/media.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: .env not found. Ensure TMDB_API_KEY is available.');
  }

  final apiKey = dotenv.env['TMDB_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('ERROR: TMDB_API_KEY is missing.');
    return;
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {'api_key': apiKey},
    ),
  );

  print('\n--- TEST 6: Age Rating 0 (DE) ---');
  await _fetchAndParse(dio, {
    'sort_by': 'popularity.desc',
    'region': 'DE',
    'certification_country': 'DE',
    'certification.lte': '0',
  }, MediaType.movie);

  print('\n--- TEST 7: Age Rating 6 (DE) ---');
  await _fetchAndParse(dio, {
    'sort_by': 'popularity.desc',
    'region': 'DE',
    'certification_country': 'DE',
    'certification.lte': '6',
  }, MediaType.movie);
}

Future<void> _fetchAndParse(
  Dio dio,
  Map<String, dynamic> params,
  MediaType type,
) async {
  try {
    print('Request: /discover/${type.tmdbPath}');
    print('Params: $params');
    final response = await dio.get(
      '/discover/${type.tmdbPath}',
      queryParameters: params,
    );
    final results = response.data['results'] as List;
    print('Results Count: ${results.length}');
  } catch (e) {
    print('Error: $e');
  }
}
