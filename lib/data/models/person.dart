import 'package:freezed_annotation/freezed_annotation.dart';
import 'media.dart';

part 'person.freezed.dart';

@freezed
class CastMember with _$CastMember {
  const CastMember._();

  const factory CastMember({
    required int id,
    required String name,
    required String character,
    String? profilePath,
  }) = _CastMember;

  String get fullProfilePath =>
      profilePath != null ? 'https://image.tmdb.org/t/p/w185$profilePath' : '';

  factory CastMember.fromTmdbJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int,
      name: json['name'] as String,
      character: json['character'] as String,
      profilePath: json['profile_path'] as String?,
    );
  }
}

@freezed
class CrewMember with _$CrewMember {
  const CrewMember._();

  const factory CrewMember({
    required int id,
    required String name,
    required String job,
    required String department,
    String? profilePath,
  }) = _CrewMember;

  String get fullProfilePath =>
      profilePath != null ? 'https://image.tmdb.org/t/p/w185$profilePath' : '';

  factory CrewMember.fromTmdbJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id'] as int,
      name: json['name'] as String,
      job: json['job'] as String? ?? '',
      department: json['department'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }
}

@freezed
class Person with _$Person {
  const Person._();

  const factory Person({
    required int id,
    required String name,
    String? biography,
    String? birthday,
    String? deathday,
    String? placeOfBirth,
    String? profilePath,
    required String knownForDepartment,
  }) = _Person;

  String get fullProfilePath =>
      profilePath != null ? 'https://image.tmdb.org/t/p/h632$profilePath' : '';

  factory Person.fromTmdbJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      name: json['name'] as String,
      biography: json['biography'] as String?,
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      profilePath: json['profile_path'] as String?,
      knownForDepartment: json['known_for_department'] as String? ?? '',
    );
  }
}

@freezed
class PersonCredit with _$PersonCredit {
  const PersonCredit._();

  const factory PersonCredit({
    required Media media,
    // For cast roles
    String? character,
    // For crew roles
    String? job,
    String? department,
  }) = _PersonCredit;

  bool get isCast => character != null;
  bool get isCrew => job != null;

  factory PersonCredit.fromTmdbJson(Map<String, dynamic> json) {
    final isMovie = json['media_type'] == 'movie';
    final type = isMovie ? MediaType.movie : MediaType.tv;
    final media = Media.fromTmdbJson(json, type);

    return PersonCredit(
      media: media,
      character: json['character'] as String?,
      job: json['job'] as String?,
      department: json['department'] as String?,
    );
  }
}
