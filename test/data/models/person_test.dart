import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/models/person.dart';

void main() {
  group('Person Models', () {
    test('CastMember fromTmdbJson parses correctly', () {
      final json = {
        'id': 123,
        'name': 'Actor Name',
        'character': 'Character Name',
        'profile_path': '/path.jpg',
      };
      final cast = CastMember.fromTmdbJson(json);
      expect(cast.id, 123);
      expect(cast.name, 'Actor Name');
      expect(cast.character, 'Character Name');
      expect(cast.profilePath, '/path.jpg');
    });

    test('CrewMember fromTmdbJson parses correctly', () {
      final json = {
        'id': 456,
        'name': 'Director Name',
        'job': 'Director',
        'department': 'Directing',
        'profile_path': '/crew.jpg',
      };
      final crew = CrewMember.fromTmdbJson(json);
      expect(crew.id, 456);
      expect(crew.name, 'Director Name');
      expect(crew.job, 'Director');
      expect(crew.department, 'Directing');
    });

    test('Person fromTmdbJson parses correctly', () {
      final json = {
        'id': 789,
        'name': 'Person Name',
        'biography': 'Bio',
        'birthday': '1990-01-01',
        'place_of_birth': 'City',
        'known_for_department': 'Acting',
        'profile_path': '/person.jpg',
      };
      final person = Person.fromTmdbJson(json);
      expect(person.id, 789);
      expect(person.name, 'Person Name');
      expect(person.biography, 'Bio');
      expect(person.birthday, '1990-01-01');
      expect(person.placeOfBirth, 'City');
      expect(person.knownForDepartment, 'Acting');
    });
  });
}
