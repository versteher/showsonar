// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'person.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CastMember {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get character => throw _privateConstructorUsedError;
  String? get profilePath => throw _privateConstructorUsedError;

  /// Create a copy of CastMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CastMemberCopyWith<CastMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CastMemberCopyWith<$Res> {
  factory $CastMemberCopyWith(
    CastMember value,
    $Res Function(CastMember) then,
  ) = _$CastMemberCopyWithImpl<$Res, CastMember>;
  @useResult
  $Res call({int id, String name, String character, String? profilePath});
}

/// @nodoc
class _$CastMemberCopyWithImpl<$Res, $Val extends CastMember>
    implements $CastMemberCopyWith<$Res> {
  _$CastMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CastMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? character = null,
    Object? profilePath = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            character: null == character
                ? _value.character
                : character // ignore: cast_nullable_to_non_nullable
                      as String,
            profilePath: freezed == profilePath
                ? _value.profilePath
                : profilePath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CastMemberImplCopyWith<$Res>
    implements $CastMemberCopyWith<$Res> {
  factory _$$CastMemberImplCopyWith(
    _$CastMemberImpl value,
    $Res Function(_$CastMemberImpl) then,
  ) = __$$CastMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String character, String? profilePath});
}

/// @nodoc
class __$$CastMemberImplCopyWithImpl<$Res>
    extends _$CastMemberCopyWithImpl<$Res, _$CastMemberImpl>
    implements _$$CastMemberImplCopyWith<$Res> {
  __$$CastMemberImplCopyWithImpl(
    _$CastMemberImpl _value,
    $Res Function(_$CastMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CastMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? character = null,
    Object? profilePath = freezed,
  }) {
    return _then(
      _$CastMemberImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        character: null == character
            ? _value.character
            : character // ignore: cast_nullable_to_non_nullable
                  as String,
        profilePath: freezed == profilePath
            ? _value.profilePath
            : profilePath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$CastMemberImpl extends _CastMember {
  const _$CastMemberImpl({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  }) : super._();

  @override
  final int id;
  @override
  final String name;
  @override
  final String character;
  @override
  final String? profilePath;

  @override
  String toString() {
    return 'CastMember(id: $id, name: $name, character: $character, profilePath: $profilePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CastMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.character, character) ||
                other.character == character) &&
            (identical(other.profilePath, profilePath) ||
                other.profilePath == profilePath));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, character, profilePath);

  /// Create a copy of CastMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CastMemberImplCopyWith<_$CastMemberImpl> get copyWith =>
      __$$CastMemberImplCopyWithImpl<_$CastMemberImpl>(this, _$identity);
}

abstract class _CastMember extends CastMember {
  const factory _CastMember({
    required final int id,
    required final String name,
    required final String character,
    final String? profilePath,
  }) = _$CastMemberImpl;
  const _CastMember._() : super._();

  @override
  int get id;
  @override
  String get name;
  @override
  String get character;
  @override
  String? get profilePath;

  /// Create a copy of CastMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CastMemberImplCopyWith<_$CastMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CrewMember {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get job => throw _privateConstructorUsedError;
  String get department => throw _privateConstructorUsedError;
  String? get profilePath => throw _privateConstructorUsedError;

  /// Create a copy of CrewMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrewMemberCopyWith<CrewMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrewMemberCopyWith<$Res> {
  factory $CrewMemberCopyWith(
    CrewMember value,
    $Res Function(CrewMember) then,
  ) = _$CrewMemberCopyWithImpl<$Res, CrewMember>;
  @useResult
  $Res call({
    int id,
    String name,
    String job,
    String department,
    String? profilePath,
  });
}

/// @nodoc
class _$CrewMemberCopyWithImpl<$Res, $Val extends CrewMember>
    implements $CrewMemberCopyWith<$Res> {
  _$CrewMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrewMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? job = null,
    Object? department = null,
    Object? profilePath = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            job: null == job
                ? _value.job
                : job // ignore: cast_nullable_to_non_nullable
                      as String,
            department: null == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String,
            profilePath: freezed == profilePath
                ? _value.profilePath
                : profilePath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrewMemberImplCopyWith<$Res>
    implements $CrewMemberCopyWith<$Res> {
  factory _$$CrewMemberImplCopyWith(
    _$CrewMemberImpl value,
    $Res Function(_$CrewMemberImpl) then,
  ) = __$$CrewMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String job,
    String department,
    String? profilePath,
  });
}

/// @nodoc
class __$$CrewMemberImplCopyWithImpl<$Res>
    extends _$CrewMemberCopyWithImpl<$Res, _$CrewMemberImpl>
    implements _$$CrewMemberImplCopyWith<$Res> {
  __$$CrewMemberImplCopyWithImpl(
    _$CrewMemberImpl _value,
    $Res Function(_$CrewMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrewMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? job = null,
    Object? department = null,
    Object? profilePath = freezed,
  }) {
    return _then(
      _$CrewMemberImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        job: null == job
            ? _value.job
            : job // ignore: cast_nullable_to_non_nullable
                  as String,
        department: null == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String,
        profilePath: freezed == profilePath
            ? _value.profilePath
            : profilePath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$CrewMemberImpl extends _CrewMember {
  const _$CrewMemberImpl({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  }) : super._();

  @override
  final int id;
  @override
  final String name;
  @override
  final String job;
  @override
  final String department;
  @override
  final String? profilePath;

  @override
  String toString() {
    return 'CrewMember(id: $id, name: $name, job: $job, department: $department, profilePath: $profilePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrewMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.job, job) || other.job == job) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.profilePath, profilePath) ||
                other.profilePath == profilePath));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, job, department, profilePath);

  /// Create a copy of CrewMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrewMemberImplCopyWith<_$CrewMemberImpl> get copyWith =>
      __$$CrewMemberImplCopyWithImpl<_$CrewMemberImpl>(this, _$identity);
}

abstract class _CrewMember extends CrewMember {
  const factory _CrewMember({
    required final int id,
    required final String name,
    required final String job,
    required final String department,
    final String? profilePath,
  }) = _$CrewMemberImpl;
  const _CrewMember._() : super._();

  @override
  int get id;
  @override
  String get name;
  @override
  String get job;
  @override
  String get department;
  @override
  String? get profilePath;

  /// Create a copy of CrewMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrewMemberImplCopyWith<_$CrewMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Person {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get biography => throw _privateConstructorUsedError;
  String? get birthday => throw _privateConstructorUsedError;
  String? get deathday => throw _privateConstructorUsedError;
  String? get placeOfBirth => throw _privateConstructorUsedError;
  String? get profilePath => throw _privateConstructorUsedError;
  String get knownForDepartment => throw _privateConstructorUsedError;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonCopyWith<Person> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonCopyWith<$Res> {
  factory $PersonCopyWith(Person value, $Res Function(Person) then) =
      _$PersonCopyWithImpl<$Res, Person>;
  @useResult
  $Res call({
    int id,
    String name,
    String? biography,
    String? birthday,
    String? deathday,
    String? placeOfBirth,
    String? profilePath,
    String knownForDepartment,
  });
}

/// @nodoc
class _$PersonCopyWithImpl<$Res, $Val extends Person>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? biography = freezed,
    Object? birthday = freezed,
    Object? deathday = freezed,
    Object? placeOfBirth = freezed,
    Object? profilePath = freezed,
    Object? knownForDepartment = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            biography: freezed == biography
                ? _value.biography
                : biography // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthday: freezed == birthday
                ? _value.birthday
                : birthday // ignore: cast_nullable_to_non_nullable
                      as String?,
            deathday: freezed == deathday
                ? _value.deathday
                : deathday // ignore: cast_nullable_to_non_nullable
                      as String?,
            placeOfBirth: freezed == placeOfBirth
                ? _value.placeOfBirth
                : placeOfBirth // ignore: cast_nullable_to_non_nullable
                      as String?,
            profilePath: freezed == profilePath
                ? _value.profilePath
                : profilePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            knownForDepartment: null == knownForDepartment
                ? _value.knownForDepartment
                : knownForDepartment // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PersonImplCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$$PersonImplCopyWith(
    _$PersonImpl value,
    $Res Function(_$PersonImpl) then,
  ) = __$$PersonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String? biography,
    String? birthday,
    String? deathday,
    String? placeOfBirth,
    String? profilePath,
    String knownForDepartment,
  });
}

/// @nodoc
class __$$PersonImplCopyWithImpl<$Res>
    extends _$PersonCopyWithImpl<$Res, _$PersonImpl>
    implements _$$PersonImplCopyWith<$Res> {
  __$$PersonImplCopyWithImpl(
    _$PersonImpl _value,
    $Res Function(_$PersonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? biography = freezed,
    Object? birthday = freezed,
    Object? deathday = freezed,
    Object? placeOfBirth = freezed,
    Object? profilePath = freezed,
    Object? knownForDepartment = null,
  }) {
    return _then(
      _$PersonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        biography: freezed == biography
            ? _value.biography
            : biography // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthday: freezed == birthday
            ? _value.birthday
            : birthday // ignore: cast_nullable_to_non_nullable
                  as String?,
        deathday: freezed == deathday
            ? _value.deathday
            : deathday // ignore: cast_nullable_to_non_nullable
                  as String?,
        placeOfBirth: freezed == placeOfBirth
            ? _value.placeOfBirth
            : placeOfBirth // ignore: cast_nullable_to_non_nullable
                  as String?,
        profilePath: freezed == profilePath
            ? _value.profilePath
            : profilePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        knownForDepartment: null == knownForDepartment
            ? _value.knownForDepartment
            : knownForDepartment // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PersonImpl extends _Person {
  const _$PersonImpl({
    required this.id,
    required this.name,
    this.biography,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    this.profilePath,
    required this.knownForDepartment,
  }) : super._();

  @override
  final int id;
  @override
  final String name;
  @override
  final String? biography;
  @override
  final String? birthday;
  @override
  final String? deathday;
  @override
  final String? placeOfBirth;
  @override
  final String? profilePath;
  @override
  final String knownForDepartment;

  @override
  String toString() {
    return 'Person(id: $id, name: $name, biography: $biography, birthday: $birthday, deathday: $deathday, placeOfBirth: $placeOfBirth, profilePath: $profilePath, knownForDepartment: $knownForDepartment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.biography, biography) ||
                other.biography == biography) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.deathday, deathday) ||
                other.deathday == deathday) &&
            (identical(other.placeOfBirth, placeOfBirth) ||
                other.placeOfBirth == placeOfBirth) &&
            (identical(other.profilePath, profilePath) ||
                other.profilePath == profilePath) &&
            (identical(other.knownForDepartment, knownForDepartment) ||
                other.knownForDepartment == knownForDepartment));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    biography,
    birthday,
    deathday,
    placeOfBirth,
    profilePath,
    knownForDepartment,
  );

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      __$$PersonImplCopyWithImpl<_$PersonImpl>(this, _$identity);
}

abstract class _Person extends Person {
  const factory _Person({
    required final int id,
    required final String name,
    final String? biography,
    final String? birthday,
    final String? deathday,
    final String? placeOfBirth,
    final String? profilePath,
    required final String knownForDepartment,
  }) = _$PersonImpl;
  const _Person._() : super._();

  @override
  int get id;
  @override
  String get name;
  @override
  String? get biography;
  @override
  String? get birthday;
  @override
  String? get deathday;
  @override
  String? get placeOfBirth;
  @override
  String? get profilePath;
  @override
  String get knownForDepartment;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PersonCredit {
  Media get media => throw _privateConstructorUsedError; // For cast roles
  String? get character => throw _privateConstructorUsedError; // For crew roles
  String? get job => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;

  /// Create a copy of PersonCredit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonCreditCopyWith<PersonCredit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonCreditCopyWith<$Res> {
  factory $PersonCreditCopyWith(
    PersonCredit value,
    $Res Function(PersonCredit) then,
  ) = _$PersonCreditCopyWithImpl<$Res, PersonCredit>;
  @useResult
  $Res call({Media media, String? character, String? job, String? department});

  $MediaCopyWith<$Res> get media;
}

/// @nodoc
class _$PersonCreditCopyWithImpl<$Res, $Val extends PersonCredit>
    implements $PersonCreditCopyWith<$Res> {
  _$PersonCreditCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PersonCredit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? media = null,
    Object? character = freezed,
    Object? job = freezed,
    Object? department = freezed,
  }) {
    return _then(
      _value.copyWith(
            media: null == media
                ? _value.media
                : media // ignore: cast_nullable_to_non_nullable
                      as Media,
            character: freezed == character
                ? _value.character
                : character // ignore: cast_nullable_to_non_nullable
                      as String?,
            job: freezed == job
                ? _value.job
                : job // ignore: cast_nullable_to_non_nullable
                      as String?,
            department: freezed == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of PersonCredit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaCopyWith<$Res> get media {
    return $MediaCopyWith<$Res>(_value.media, (value) {
      return _then(_value.copyWith(media: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PersonCreditImplCopyWith<$Res>
    implements $PersonCreditCopyWith<$Res> {
  factory _$$PersonCreditImplCopyWith(
    _$PersonCreditImpl value,
    $Res Function(_$PersonCreditImpl) then,
  ) = __$$PersonCreditImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Media media, String? character, String? job, String? department});

  @override
  $MediaCopyWith<$Res> get media;
}

/// @nodoc
class __$$PersonCreditImplCopyWithImpl<$Res>
    extends _$PersonCreditCopyWithImpl<$Res, _$PersonCreditImpl>
    implements _$$PersonCreditImplCopyWith<$Res> {
  __$$PersonCreditImplCopyWithImpl(
    _$PersonCreditImpl _value,
    $Res Function(_$PersonCreditImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PersonCredit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? media = null,
    Object? character = freezed,
    Object? job = freezed,
    Object? department = freezed,
  }) {
    return _then(
      _$PersonCreditImpl(
        media: null == media
            ? _value.media
            : media // ignore: cast_nullable_to_non_nullable
                  as Media,
        character: freezed == character
            ? _value.character
            : character // ignore: cast_nullable_to_non_nullable
                  as String?,
        job: freezed == job
            ? _value.job
            : job // ignore: cast_nullable_to_non_nullable
                  as String?,
        department: freezed == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PersonCreditImpl extends _PersonCredit {
  const _$PersonCreditImpl({
    required this.media,
    this.character,
    this.job,
    this.department,
  }) : super._();

  @override
  final Media media;
  // For cast roles
  @override
  final String? character;
  // For crew roles
  @override
  final String? job;
  @override
  final String? department;

  @override
  String toString() {
    return 'PersonCredit(media: $media, character: $character, job: $job, department: $department)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonCreditImpl &&
            (identical(other.media, media) || other.media == media) &&
            (identical(other.character, character) ||
                other.character == character) &&
            (identical(other.job, job) || other.job == job) &&
            (identical(other.department, department) ||
                other.department == department));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, media, character, job, department);

  /// Create a copy of PersonCredit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonCreditImplCopyWith<_$PersonCreditImpl> get copyWith =>
      __$$PersonCreditImplCopyWithImpl<_$PersonCreditImpl>(this, _$identity);
}

abstract class _PersonCredit extends PersonCredit {
  const factory _PersonCredit({
    required final Media media,
    final String? character,
    final String? job,
    final String? department,
  }) = _$PersonCreditImpl;
  const _PersonCredit._() : super._();

  @override
  Media get media; // For cast roles
  @override
  String? get character; // For crew roles
  @override
  String? get job;
  @override
  String? get department;

  /// Create a copy of PersonCredit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonCreditImplCopyWith<_$PersonCreditImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
