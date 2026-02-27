import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/models/media.dart';

void main() {
  group('Media FSK Parsing', () {
    test('Correctly parses FSK 12 from movie release_dates', () {
      final json = {
        'id': 1,
        'title': 'Test Movie',
        'overview': 'Overview',
        'release_date': '2023-01-01',
        'vote_average': 8.0,
        'vote_count': 100,
        'genre_ids': [12, 14],
        'release_dates': {
          'results': [
            {
              'iso_3166_1': 'US',
              'release_dates': [
                {'certification': 'PG-13'},
              ],
            },
            {
              'iso_3166_1': 'DE',
              'release_dates': [
                {'certification': '12'},
              ],
            },
          ],
        },
      };

      final media = Media.fromTmdbJson(json, MediaType.movie);
      expect(media.ageRating, '12');
      expect(media.fskLevel, 12);
    });

    test('Correctly parses FSK 16 from TV show content_ratings', () {
      final json = {
        'id': 2,
        'name': 'Test Show',
        'overview': 'Overview',
        'first_air_date': '2023-01-01',
        'vote_average': 8.5,
        'vote_count': 200,
        'genre_ids': [18],
        'content_ratings': {
          'results': [
            {'iso_3166_1': 'US', 'rating': 'TV-MA'},
            {'iso_3166_1': 'DE', 'rating': '16'},
          ],
        },
      };

      final media = Media.fromTmdbJson(json, MediaType.tv);
      expect(media.ageRating, '16');
      expect(media.fskLevel, 16);
    });

    test('Handles missing FSK gracefully', () {
      final json = {
        'id': 3,
        'title': 'Unknown Movie',
        'overview': 'Overview',
        'release_date': '2023-01-01',
        'vote_average': 7.0,
        'vote_count': 50,
        'genre_ids': [],
      };

      final media = Media.fromTmdbJson(json, MediaType.movie);
      expect(media.ageRating, null);
      expect(media.fskLevel, 0);
    });

    test('Handles textual FSK gracefully', () {
      final json = {
        'id': 4,
        'title': 'Weird Rating Movie',
        'overview': 'Overview',
        'release_date': '2023-01-01',
        'vote_average': 7.0,
        'vote_count': 50,
        'genre_ids': [],
        'release_dates': {
          'results': [
            {
              'iso_3166_1': 'DE',
              'release_dates': [
                {'certification': 'FSK 18'},
              ],
            },
          ],
        },
      };

      final media = Media.fromTmdbJson(json, MediaType.movie);
      expect(media.ageRating, 'FSK 18');
      expect(media.fskLevel, 18);
    });
  });
}
