import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neon_voyager/data/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockAuth);
  });

  group('AuthService', () {
    test('signInWithEmailAndPassword calls FirebaseAuth', () async {
      final mockCredential = MockUserCredential();
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await authService.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      expect(result, equals(mockCredential));
      verify(
        () => mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('createUserWithEmailAndPassword calls FirebaseAuth', () async {
      final mockCredential = MockUserCredential();
      when(
        () => mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await authService.createUserWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      expect(result, equals(mockCredential));
      verify(
        () => mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('signOut calls FirebaseAuth.signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('authStateChanges returns stream from FirebaseAuth', () {
      final mockUser = MockUser();
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(mockUser));

      final stream = authService.authStateChanges;

      expect(stream, emits(mockUser));
      verify(() => mockAuth.authStateChanges()).called(1);
    });

    test('currentUser returns from FirebaseAuth', () {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final user = authService.currentUser;

      expect(user, equals(mockUser));
      verify(() => mockAuth.currentUser).called(1);
    });
  });
}
