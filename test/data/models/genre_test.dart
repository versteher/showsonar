import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/data/models/genre.dart';

void main() {
  group('Genre', () {
    test('movieGenres should contain common movie genres', () {
      expect(Genre.movieGenres.length, 19);

      // Check some common genres exist
      expect(Genre.movieGenres.any((g) => g.id == 28), isTrue); // Action
      expect(Genre.movieGenres.any((g) => g.id == 35), isTrue); // Comedy
      expect(Genre.movieGenres.any((g) => g.id == 18), isTrue); // Drama
      expect(Genre.movieGenres.any((g) => g.id == 878), isTrue); // Sci-Fi
    });

    test('tvGenres should contain common TV genres', () {
      expect(Genre.tvGenres.length, 16);

      // Check some TV-specific genres exist
      expect(
        Genre.tvGenres.any((g) => g.id == 10759),
        isTrue,
      ); // Action & Adventure
      expect(
        Genre.tvGenres.any((g) => g.id == 10765),
        isTrue,
      ); // Sci-Fi & Fantasy
    });

    test('fromId should return correct genre for movie genres', () {
      final action = Genre.fromId(28);
      expect(action, isNotNull);
      expect(action!.name, 'Action');

      final comedy = Genre.fromId(35);
      expect(comedy, isNotNull);
      expect(comedy!.name, 'Komödie');
    });

    test('fromId should return correct genre for TV genres', () {
      final sciFiFantasy = Genre.fromId(10765);
      expect(sciFiFantasy, isNotNull);
      expect(sciFiFantasy!.name, 'Sci-Fi & Fantasy');
    });

    test('fromId should return null for unknown id', () {
      expect(Genre.fromId(99999), isNull);
      expect(Genre.fromId(0), isNull);
      expect(Genre.fromId(-1), isNull);
    });

    test('getNameById should return genre name', () {
      expect(Genre.getNameById(28), 'Action');
      expect(Genre.getNameById(35), 'Komödie');
      expect(Genre.getNameById(18), 'Drama');
    });

    test('getNameById should return Unbekannt for unknown id', () {
      expect(Genre.getNameById(99999), 'Unbekannt');
    });

    test('genre names should be in German', () {
      // Check German translations
      expect(Genre.getNameById(35), 'Komödie'); // Comedy
      expect(Genre.getNameById(12), 'Abenteuer'); // Adventure
      expect(Genre.getNameById(10751), 'Familie'); // Family
      expect(Genre.getNameById(27), 'Horror'); // Horror
      expect(Genre.getNameById(10749), 'Liebesfilm'); // Romance
      expect(Genre.getNameById(10752), 'Kriegsfilm'); // War
    });

    test('equality should be based on id', () {
      const genre1 = Genre(id: 28, name: 'Action');
      const genre2 = Genre(id: 28, name: 'Different Name');
      const genre3 = Genre(id: 35, name: 'Action');

      expect(genre1, equals(genre2));
      expect(genre1, isNot(equals(genre3)));
    });

    test('toString should return readable format', () {
      const genre = Genre(id: 28, name: 'Action');
      expect(genre.toString(), 'Genre(id: 28, name: Action)');
    });
  });
}
