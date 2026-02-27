import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:neon_voyager/data/repositories/profile_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ProfileRepository repo;
  const userId = 'test_user';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = ProfileRepository(userId, firestore: fakeFirestore);
  });

  group('ProfileRepository', () {
    group('getProfiles', () {
      test('returns empty list when no profiles exist', () async {
        final profiles = await repo.getProfiles();
        expect(profiles, isEmpty);
      });

      test('returns profiles after creating one', () async {
        await repo.createProfile(name: 'Kids', avatarEmoji: '👦');

        final profiles = await repo.getProfiles();

        expect(profiles, hasLength(1));
        expect(profiles.first.name, 'Kids');
        expect(profiles.first.avatarEmoji, '👦');
      });

      test('returns multiple profiles', () async {
        await repo.createProfile(name: 'Alice', avatarEmoji: '👩');
        await repo.createProfile(name: 'Bob', avatarEmoji: '👨');

        final profiles = await repo.getProfiles();

        expect(profiles, hasLength(2));
        final names = profiles.map((p) => p.name).toList();
        expect(names, containsAll(['Alice', 'Bob']));
      });
    });

    group('createProfile', () {
      test('creates profile with given name and emoji', () async {
        final profile = await repo.createProfile(
          name: 'Partner',
          avatarEmoji: '🧑',
        );

        expect(profile.name, 'Partner');
        expect(profile.avatarEmoji, '🧑');
        expect(profile.id, isNotEmpty);
        expect(profile.createdAt, isNotNull);
      });

      test('uses default emoji when not specified', () async {
        final profile = await repo.createProfile(name: 'Test');
        expect(profile.avatarEmoji, '🎬');
      });

      test('persists profile to Firestore', () async {
        final created = await repo.createProfile(name: 'Alex');

        final fetched = await repo.getProfile(created.id);

        expect(fetched, isNotNull);
        expect(fetched!.name, 'Alex');
      });
    });

    group('deleteProfile', () {
      test('removes profile from Firestore', () async {
        final profile = await repo.createProfile(name: 'ToDelete');
        expect(await repo.getProfiles(), hasLength(1));

        await repo.deleteProfile(profile.id);

        expect(await repo.getProfiles(), isEmpty);
      });

      test('no-ops for non-existent profile id', () async {
        // Should not throw
        await repo.deleteProfile('nonexistent_id');
        expect(await repo.getProfiles(), isEmpty);
      });
    });

    group('updateProfile', () {
      test('updates profile name', () async {
        final profile = await repo.createProfile(name: 'Old Name');

        final updated = profile.copyWith(name: 'New Name');
        await repo.updateProfile(updated);

        final fetched = await repo.getProfile(profile.id);
        expect(fetched!.name, 'New Name');
      });

      test('updates profile emoji', () async {
        final profile = await repo.createProfile(
          name: 'Test',
          avatarEmoji: '🎬',
        );

        final updated = profile.copyWith(avatarEmoji: '🦸');
        await repo.updateProfile(updated);

        final fetched = await repo.getProfile(profile.id);
        expect(fetched!.avatarEmoji, '🦸');
      });
    });

    group('getProfile', () {
      test('returns null for non-existent id', () async {
        final result = await repo.getProfile('does_not_exist');
        expect(result, isNull);
      });

      test('returns correct profile by id', () async {
        final created = await repo.createProfile(name: 'FindMe');

        final found = await repo.getProfile(created.id);

        expect(found, isNotNull);
        expect(found!.id, created.id);
        expect(found.name, 'FindMe');
      });
    });
  });
}
