import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/tv_episode.dart';

void main() {
  group('TvEpisode', () {
    group('fromTmdbJson', () {
      test('parses all fields correctly', () {
        final json = {
          'episode_number': 3,
          'season_number': 2,
          'name': 'The Long Night',
          'overview': 'An epic battle.',
          'air_date': '2019-04-28',
          'runtime': 82,
          'still_path': '/still.jpg',
          'vote_average': 9.1,
          'vote_count': 12345,
        };

        final ep = TvEpisode.fromTmdbJson(json);

        expect(ep.episodeNumber, 3);
        expect(ep.seasonNumber, 2);
        expect(ep.name, 'The Long Night');
        expect(ep.overview, 'An epic battle.');
        expect(ep.airDate, DateTime(2019, 4, 28));
        expect(ep.runtime, 82);
        expect(ep.stillPath, '/still.jpg');
        expect(ep.voteAverage, 9.1);
        expect(ep.voteCount, 12345);
      });

      test('handles missing nullable fields', () {
        final json = {'episode_number': 1, 'season_number': 1, 'name': 'Pilot'};

        final ep = TvEpisode.fromTmdbJson(json);

        expect(ep.episodeNumber, 1);
        expect(ep.airDate, isNull);
        expect(ep.runtime, isNull);
        expect(ep.stillPath, isNull);
        expect(ep.voteAverage, 0.0);
      });

      test('handles null air_date gracefully', () {
        final json = {
          'episode_number': 1,
          'season_number': 1,
          'name': 'Pilot',
          'air_date': null,
        };

        final ep = TvEpisode.fromTmdbJson(json);
        expect(ep.airDate, isNull);
      });

      test('handles empty air_date string gracefully', () {
        final json = {
          'episode_number': 1,
          'season_number': 1,
          'name': 'Pilot',
          'air_date': '',
        };

        final ep = TvEpisode.fromTmdbJson(json);
        expect(ep.airDate, isNull);
      });
    });

    group('hasAired', () {
      test('returns true for past air date', () {
        final ep = TvEpisode(
          episodeNumber: 1,
          seasonNumber: 1,
          name: 'Pilot',
          airDate: DateTime(2020, 1, 1), // well in the past
        );
        expect(ep.hasAired, isTrue);
      });

      test('returns false for future air date', () {
        final ep = TvEpisode(
          episodeNumber: 1,
          seasonNumber: 1,
          name: 'Future Episode',
          airDate: DateTime(2099, 12, 31), // far in the future
        );
        expect(ep.hasAired, isFalse);
      });

      test('returns false when airDate is null', () {
        const ep = TvEpisode(
          episodeNumber: 1,
          seasonNumber: 1,
          name: 'Unknown Airdate',
        );
        expect(ep.hasAired, isFalse);
      });
    });

    group('daysUntilAir', () {
      test('returns negative for past episodes', () {
        final ep = TvEpisode(
          episodeNumber: 1,
          seasonNumber: 1,
          name: 'Old Episode',
          airDate: DateTime.now().subtract(const Duration(days: 10)),
        );
        expect(ep.daysUntilAir, isNegative);
      });

      test('returns positive for future episodes', () {
        final ep = TvEpisode(
          episodeNumber: 1,
          seasonNumber: 1,
          name: 'Future Episode',
          airDate: DateTime.now().add(const Duration(days: 7)),
        );
        expect(ep.daysUntilAir, greaterThan(0));
      });

      test('returns -999 when airDate is null', () {
        const ep = TvEpisode(
          episodeNumber: 1,
          seasonNumber: 1,
          name: 'No Date',
        );
        expect(ep.daysUntilAir, -999);
      });
    });

    group('fullStillPath', () {
      test('returns full URL when stillPath present', () {
        const ep = TvEpisode(
          episodeNumber: 1,
          seasonNumber: 1,
          name: 'Ep',
          stillPath: '/still.jpg',
        );
        expect(ep.fullStillPath, 'https://image.tmdb.org/t/p/w300/still.jpg');
      });

      test('returns empty string when stillPath is null', () {
        const ep = TvEpisode(episodeNumber: 1, seasonNumber: 1, name: 'Ep');
        expect(ep.fullStillPath, '');
      });
    });
  });
}
