import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:stream_scout/data/services/tmdb_api_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late TmdbApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = MockDio();
    apiClient = TmdbApiClient(dio: mockDio);
  });

  group('TmdbApiClient', () {
    test('get() successful request', () async {
      when(
        () => mockDio.get(
          '/test-path',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/test-path'),
          statusCode: 200,
          data: jsonEncode({'result': 'success'}),
        ),
      );

      final result = await apiClient.get('/test-path');
      expect(result['result'], 'success');
    });

    test('get() throws TmdbException on DioException', () async {
      when(
        () => mockDio.get(
          '/test-path',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/test-path'),
          message: 'Network error',
        ),
      );

      expect(() => apiClient.get('/test-path'), throwsA(isA<TmdbException>()));
    });

    test('searchMulti passes correct params', () async {
      when(
        () => mockDio.get(
          '/search/multi',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/search/multi'),
          statusCode: 200,
          data: jsonEncode({'results': []}),
        ),
      );

      await apiClient.searchMulti('test query', page: 2, includeAdult: true);

      verify(
        () => mockDio.get(
          '/search/multi',
          queryParameters: {
            'query': 'test query',
            'page': 2,
            'include_adult': true,
          },
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('getTrending passes correct params', () async {
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: jsonEncode({'results': []}),
        ),
      );

      await apiClient.getTrending('movie', 'day');

      verify(
        () => mockDio.get(
          '/trending/movie/day',
          queryParameters: {'page': 1},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('getPopular passes correct params', () async {
      when(
        () => mockDio.get(
          '/movie/popular',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/movie/popular'),
          statusCode: 200,
          data: jsonEncode({'results': []}),
        ),
      );

      await apiClient.getPopular('movie', 3, 'US');

      verify(
        () => mockDio.get(
          '/movie/popular',
          queryParameters: {'page': 3, 'region': 'US'},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('getMovieDetails passes correct params', () async {
      when(
        () => mockDio.get(
          '/movie/1234',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/movie/1234'),
          statusCode: 200,
          data: jsonEncode({'id': 1234}),
        ),
      );

      await apiClient.getMovieDetails(1234);

      verify(
        () => mockDio.get(
          '/movie/1234',
          queryParameters: {
            'append_to_response':
                'credits,videos,recommendations,watch/providers,release_dates',
          },
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('discoverMovies passes query parameters correctly', () async {
      when(
        () => mockDio.get(
          '/discover/movie',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/discover/movie'),
          statusCode: 200,
          data: jsonEncode({'results': []}),
        ),
      );

      final params = {'sort_by': 'popularity.desc', 'page': 1};
      await apiClient.discoverMovies(params);

      verify(
        () => mockDio.get(
          '/discover/movie',
          queryParameters: params,
          options: any(named: 'options'),
        ),
      ).called(1);
    });
  });
}
