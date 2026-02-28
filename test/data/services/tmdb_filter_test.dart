import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/repositories/tmdb_repository.dart';
import 'package:stream_scout/data/services/tmdb_api_client.dart';

// Manual MockDio that captures requests
class MockDio implements Dio {
  final List<RequestOptions> requests = [];

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    requests.add(
      RequestOptions(
        path: path,
        data: data,
        queryParameters: queryParameters,
        method: 'GET',
      ),
    );

    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: '{"results": []}' as T,
      statusCode: 200,
    );
  }

  // Implement other required members with dummy implementations
  @override
  BaseOptions options = BaseOptions();

  @override
  HttpClientAdapter httpClientAdapter = HttpClientAdapter();

  @override
  Transformer transformer = BackgroundTransformer();

  @override
  Interceptors get interceptors => Interceptors();

  @override
  void close({bool force = false}) {}

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async => throw UnimplementedError();

  @override
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
    dynamic fileAccessMode, // Added matching parameter
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async =>
      throw UnimplementedError();

  @override
  Future<Response<T>> head<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> request<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => throw UnimplementedError();

  // URI methods
  @override
  Future<Response<T>> getUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> headUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> deleteUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> patchUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> postUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> putUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => throw UnimplementedError();

  @override
  Future<Response<T>> requestUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => throw UnimplementedError();

  @override
  Future<Response> downloadUri(
    Uri uri,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
    dynamic fileAccessMode,
  }) async => throw UnimplementedError();

  @override
  Dio clone({
    HttpClientAdapter? httpClientAdapter,
    Interceptors? interceptors,
    BaseOptions? options,
    Transformer? transformer,
  }) {
    return MockDio();
  }
}

void main() {
  late MockDio mockDio;
  late ITmdbRepository tmdbService;

  setUp(() {
    mockDio = MockDio();
    tmdbService = TmdbRepository(TmdbApiClient(dio: mockDio));
  });

  group('ITmdbRepository Age Filtering', () {
    test('discoverMovies adds correct FSK parameters for age 12', () async {
      await tmdbService.discoverMovies(maxAgeRating: 12);

      expect(mockDio.requests.length, 1);
      final request = mockDio.requests.first;

      expect(request.path, '/discover/movie');
      expect(
        request.queryParameters,
        containsPair('certification_country', 'DE'),
      );
      expect(request.queryParameters, containsPair('certification.lte', '12'));
    });

    test('discoverMovies adds correct FSK parameters for age 6', () async {
      mockDio.requests.clear();
      await tmdbService.discoverMovies(maxAgeRating: 6);

      expect(mockDio.requests.length, 1);
      final request = mockDio.requests.first;

      expect(request.path, '/discover/movie');
      expect(
        request.queryParameters,
        containsPair('certification_country', 'DE'),
      );
      expect(request.queryParameters, containsPair('certification.lte', '6'));
    });

    test('discoverMovies DOES NOT add FSK parameters for age 18', () async {
      mockDio.requests.clear();
      await tmdbService.discoverMovies(maxAgeRating: 18);

      expect(mockDio.requests.length, 1);
      final request = mockDio.requests.first;

      expect(request.path, '/discover/movie');
      expect(
        request.queryParameters,
        isNot(containsPair('certification_country', 'DE')),
      );
    });

    test('getUpcomingMovies adds correct FSK parameters for age 12', () async {
      mockDio.requests.clear();
      await tmdbService.getUpcomingMovies(maxAgeRating: 12);

      expect(mockDio.requests.length, 1);
      final request = mockDio.requests.first;

      expect(request.path, '/discover/movie');
      expect(
        request.queryParameters,
        containsPair('certification_country', 'DE'),
      );
      expect(request.queryParameters, containsPair('certification.lte', '12'));
    });

    test(
      'discoverMovies adds correct FSK parameters for age 0 (FSK 0)',
      () async {
        mockDio.requests.clear();
        await tmdbService.discoverMovies(maxAgeRating: 0);

        expect(mockDio.requests.length, 1);
        final request = mockDio.requests.first;

        expect(request.path, '/discover/movie');
        expect(
          request.queryParameters,
          containsPair('certification_country', 'DE'),
        );
        expect(request.queryParameters, containsPair('certification.lte', '0'));
      },
    );

    test(
      'discoverMovies adds correct US parameters for age 12 (PG-13)',
      () async {
        mockDio.requests.clear();
        await tmdbService.discoverMovies(maxAgeRating: 12, watchRegion: 'US');

        expect(mockDio.requests.length, 1);
        final request = mockDio.requests.first;

        expect(request.path, '/discover/movie');
        expect(
          request.queryParameters,
          containsPair('certification_country', 'US'),
        );
        // US 12 -> PG-13
        expect(
          request.queryParameters,
          containsPair('certification.lte', 'PG-13'),
        );
      },
    );
  });

  group('ITmdbRepository TV Age Filtering', () {
    test('discoverTvSeries excludes adult genres for age 6', () async {
      mockDio.requests.clear();
      await tmdbService.discoverTvSeries(maxAgeRating: 6);

      expect(mockDio.requests.length, 1);
      final request = mockDio.requests.first;

      expect(request.path, '/discover/tv');
      // Should include safe genres
      expect(
        request.queryParameters,
        containsPair('with_genres', '10762|10751|16'),
      );
      // Should exclude adult/intense genres
      expect(
        request.queryParameters,
        containsPair('without_genres', '10768,18,80,27,99'),
      );
    });

    test('discoverTvSeries excludes specific genres for age 12', () async {
      mockDio.requests.clear();
      await tmdbService.discoverTvSeries(maxAgeRating: 12);

      expect(mockDio.requests.length, 1);
      final request = mockDio.requests.first;

      expect(request.path, '/discover/tv');
      // Should exclude harsher genres but less restrictive than age 6
      expect(
        request.queryParameters,
        containsPair('without_genres', '10768,80,27'),
      );
      // Should NOT enforce "only safe genres" (with_genres)
      expect(request.queryParameters, isNot(contains('with_genres')));
    });

    test('discoverTvSeries does not apply age filter for age 16+', () async {
      mockDio.requests.clear();
      await tmdbService.discoverTvSeries(maxAgeRating: 16);

      expect(mockDio.requests.length, 1);
      final request = mockDio.requests.first;

      expect(request.path, '/discover/tv');
      expect(request.queryParameters, isNot(contains('without_genres')));
      expect(request.queryParameters, isNot(contains('with_genres')));
    });

    // Test distinct logic for count method as well
    test('discoverTvSeriesWithCount applies age 6 filter', () async {
      mockDio.requests.clear();
      await tmdbService.discoverTvSeriesWithCount(maxAgeRating: 6);

      expect(mockDio.requests.length, 1);
      final request = mockDio.requests.first;

      expect(
        request.queryParameters,
        containsPair('without_genres', '10768,18,80,27,99'),
      );
    });
  });
}
