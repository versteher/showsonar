import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_scout/data/repositories/tmdb_repository.dart';
import 'package:stream_scout/data/services/tmdb_api_client.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/exceptions/tmdb_exception.dart';

class MockTmdbApiClient extends Mock implements TmdbApiClient {}

class MockITmdbRepository extends Mock implements ITmdbRepository {}

void main() {
  late MockTmdbApiClient mockApiClient;
  late ITmdbRepository repository;

  setUp(() {
    mockApiClient = MockTmdbApiClient();
    repository = TmdbRepository(mockApiClient);
  });

  group('TmdbRepository', () {
    group('searchMulti', () {
      test('should return empty list for empty query', () async {
        final result = await repository.searchMulti('');
        expect(result, isEmpty);
      });

      test('should parse movie and tv results correctly', () async {
        when(
          () => mockApiClient.searchMulti(
            any(),
            page: any(named: 'page'),
            includeAdult: any(named: 'includeAdult'),
          ),
        ).thenAnswer(
          (_) async => {
            'results': [
              {
                'id': 550,
                'title': 'Fight Club',
                'media_type': 'movie',
                'overview': 'Test',
                'vote_average': 8.4,
                'vote_count': 26000,
                'genre_ids': [18, 53],
              },
              {
                'id': 1399,
                'name': 'Game of Thrones',
                'media_type': 'tv',
                'overview': 'Test',
                'vote_average': 8.4,
                'vote_count': 21000,
                'genre_ids': [18, 10765],
              },
              {'id': 123, 'name': 'Some Person', 'media_type': 'person'},
            ],
          },
        );

        final result = await repository.searchMulti('test');

        expect(result.length, 2);
        expect(result[0].type, MediaType.movie);
        expect(result[0].title, 'Fight Club');
        expect(result[1].type, MediaType.tv);
        expect(result[1].title, 'Game of Thrones');
      });

      test('should throw TmdbException on API error', () async {
        when(
          () => mockApiClient.searchMulti(
            any(),
            page: any(named: 'page'),
            includeAdult: any(named: 'includeAdult'),
          ),
        ).thenThrow(const TmdbException('Network error'));

        expect(
          () => repository.searchMulti('test'),
          throwsA(isA<TmdbException>()),
        );
      });

      test('should include adult content when maxAgeRating is 21+', () async {
        when(
          () => mockApiClient.searchMulti(
            any(),
            page: any(named: 'page'),
            includeAdult: any(named: 'includeAdult'),
          ),
        ).thenAnswer((_) async => {'results': []});

        await repository.searchMulti('test', maxAgeRating: 21);

        verify(
          () => mockApiClient.searchMulti('test', page: 1, includeAdult: true),
        ).called(1);
      });
    });

    group('getTrending', () {
      test(
        'should fetch trending all by default and cache the result',
        () async {
          when(() => mockApiClient.getTrending('all', 'week')).thenAnswer(
            (_) async => {
              'results': [
                {
                  'id': 550,
                  'title': 'Test Movie',
                  'media_type': 'movie',
                  'overview': 'Test',
                  'vote_average': 8.0,
                  'vote_count': 1000,
                  'genre_ids': [28],
                },
              ],
            },
          );

          final result1 = await repository.getTrending();
          final result2 = await repository.getTrending();

          expect(result1.length, 1);
          expect(result1, result2); // From cache
          verify(() => mockApiClient.getTrending('all', 'week')).called(1);
        },
      );
    });

    group('getMovieDetails', () {
      test('should fetch movie details', () async {
        when(() => mockApiClient.getMovieDetails(550)).thenAnswer(
          (_) async => {
            'id': 550,
            'title': 'Fight Club',
            'overview': 'A very good movie',
            'vote_average': 8.4,
            'vote_count': 26000,
            'genre_ids': [18],
            'genres': [
              {'id': 18, 'name': 'Drama'},
            ],
          },
        );

        final result = await repository.getMovieDetails(550);
        expect(result.id, 550);
        expect(result.type, MediaType.movie);
      });
    });

    group('getWatchProviders', () {
      test('should return providers for given region', () async {
        when(() => mockApiClient.getWatchProviders('movie', 550)).thenAnswer(
          (_) async => {
            'results': {
              'DE': {
                'flatrate': [
                  {
                    'provider_id': 8,
                    'provider_name': 'Netflix',
                    'logo_path': '/netflix.png',
                  },
                ],
                'buy': [
                  {
                    'provider_id': 2,
                    'provider_name': 'Apple TV',
                    'logo_path': '/apple.png',
                  },
                ],
              },
            },
          },
        );

        final result = await repository.getWatchProviders(
          550,
          MediaType.movie,
          region: 'DE',
        );

        expect(result.flatrate, isNotEmpty);
        expect(result.flatrate.first.name, 'Netflix');
        expect(result.buy, isNotEmpty);
        expect(result.hasStreamingOptions, isTrue);
        expect(result.hasAnyOptions, isTrue);
      });
    });

    group('getTrailerUrl', () {
      test('should return null when ApiClient throws TmdbException', () async {
        when(
          () => mockApiClient.get(any()),
        ).thenThrow(const TmdbException('Failed'));

        final result = await repository.getTrailerUrl(550, MediaType.movie);
        expect(result, isNull);
      });
    });
  });
}
