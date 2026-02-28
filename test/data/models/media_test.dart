import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/models/streaming_provider.dart';

void main() {
  group('Media', () {
    final testMedia = Media(
      id: 550,
      title: 'Fight Club',
      originalTitle: 'Fight Club',
      overview: 'A ticking-Loss insomnia...',
      posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      backdropPath: '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
      voteAverage: 8.4,
      voteCount: 26500,
      releaseDate: DateTime(1999, 10, 15),
      genreIds: [18, 53, 35],
      type: MediaType.movie,
    );

    test('should create Media with all required fields', () {
      expect(testMedia.id, 550);
      expect(testMedia.title, 'Fight Club');
      expect(testMedia.type, MediaType.movie);
      expect(testMedia.voteAverage, 8.4);
    });

    test('fullPosterPath should return complete URL', () {
      expect(
        testMedia.fullPosterPath,
        'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      );
    });

    test(
      'fullPosterPath should return empty string when posterPath is null',
      () {
        const mediaWithoutPoster = Media(
          id: 123,
          title: 'Test',
          overview: 'Test',
          posterPath: null,
          voteAverage: 7.0,
          voteCount: 100,
          genreIds: [],
          type: MediaType.movie,
        );
        expect(mediaWithoutPoster.fullPosterPath, '');
      },
    );

    test('fullBackdropPath should return complete URL', () {
      expect(
        testMedia.fullBackdropPath,
        'https://image.tmdb.org/t/p/original/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
      );
    });

    test('year should return release year as string', () {
      expect(testMedia.year, '1999');
    });

    test('year should return Unknown when releaseDate is null', () {
      const mediaNoDate = Media(
        id: 123,
        title: 'Test',
        overview: 'Test',
        releaseDate: null,
        voteAverage: 7.0,
        voteCount: 100,
        genreIds: [],
        type: MediaType.movie,
      );
      expect(mediaNoDate.year, 'Unknown');
    });

    test('isHighlyRated should return true for rating >= 7.0', () {
      expect(testMedia.isHighlyRated, isTrue);

      final lowRatedMedia = testMedia.copyWith(voteAverage: 6.9);
      expect(lowRatedMedia.isHighlyRated, isFalse);

      final exactlySevenMedia = testMedia.copyWith(voteAverage: 7.0);
      expect(exactlySevenMedia.isHighlyRated, isTrue);
    });

    test('copyWith should create new instance with updated fields', () {
      final updated = testMedia.copyWith(
        title: 'Updated Title',
        voteAverage: 9.0,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.voteAverage, 9.0);
      expect(updated.id, testMedia.id);
      expect(updated.overview, testMedia.overview);
    });

    test('copyWith with availableOn should update streaming providers', () {
      final withProviders = testMedia.copyWith(
        availableOn: [StreamingProvider.netflix, StreamingProvider.amazonPrime],
      );

      expect(withProviders.availableOn.length, 2);
      expect(withProviders.availableOn, contains(StreamingProvider.netflix));
    });

    group('fromTmdbJson', () {
      test('should parse movie JSON correctly', () {
        final json = {
          'id': 550,
          'title': 'Fight Club',
          'original_title': 'Fight Club',
          'overview': 'A depressed man suffering...',
          'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
          'backdrop_path': '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
          'vote_average': 8.4,
          'vote_count': 26500,
          'release_date': '1999-10-15',
          'genre_ids': [18, 53, 35],
        };

        final media = Media.fromTmdbJson(json, MediaType.movie);

        expect(media.id, 550);
        expect(media.title, 'Fight Club');
        expect(media.originalTitle, 'Fight Club');
        expect(media.voteAverage, 8.4);
        expect(media.releaseDate, DateTime(1999, 10, 15));
        expect(media.genreIds, [18, 53, 35]);
        expect(media.type, MediaType.movie);
      });

      test('should parse TV series JSON correctly', () {
        final json = {
          'id': 1399,
          'name': 'Game of Thrones',
          'original_name': 'Game of Thrones',
          'overview': 'Seven noble families...',
          'poster_path': '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
          'backdrop_path': '/suopoADq0k8YZr4dQXcU6pToj6s.jpg',
          'vote_average': 8.4,
          'vote_count': 21000,
          'first_air_date': '2011-04-17',
          'genre_ids': [10765, 18, 10759],
        };

        final media = Media.fromTmdbJson(json, MediaType.tv);

        expect(media.id, 1399);
        expect(media.title, 'Game of Thrones');
        expect(media.releaseDate, DateTime(2011, 4, 17));
        expect(media.type, MediaType.tv);
      });

      test('should handle missing optional fields', () {
        final minimalJson = {'id': 123, 'title': 'Minimal Movie'};

        final media = Media.fromTmdbJson(minimalJson, MediaType.movie);

        expect(media.id, 123);
        expect(media.title, 'Minimal Movie');
        expect(media.overview, '');
        expect(media.posterPath, isNull);
        expect(media.voteAverage, 0.0);
        expect(media.genreIds, isEmpty);
      });

      test('should handle empty release_date', () {
        final json = {'id': 123, 'title': 'Test', 'release_date': ''};

        final media = Media.fromTmdbJson(json, MediaType.movie);
        expect(media.releaseDate, isNull);
      });
    });

    test('equality should be deep equality due to freezed', () {
      final media1 = testMedia;
      final media2 = testMedia.copyWith();
      final media3 = testMedia.copyWith(title: 'Different Title');

      expect(media1, equals(media2));
      expect(media1, isNot(equals(media3)));
    });
  });

  group('MediaType', () {
    test('displayName returns English fallback names', () {
      // displayName is now an English fallback; use localizedName(l10n) in widgets.
      expect(MediaType.movie.displayName, 'Movie');
      expect(MediaType.tv.displayName, 'TV Series');
    });

    test('tmdbPath should return correct API paths', () {
      expect(MediaType.movie.tmdbPath, 'movie');
      expect(MediaType.tv.tmdbPath, 'tv');
    });
  });
}
