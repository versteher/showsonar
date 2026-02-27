import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neon_voyager/ui/screens/login_screen.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    // Default auth state to null
    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => Stream.value(null));
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders all expected UI elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In with Email'), findsOneWidget);
      expect(find.text('Sign In with Google'), findsOneWidget);
      expect(find.text('Sign In with Apple'), findsOneWidget);
      expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Sign In with Email'));
      await tester.pump();

      expect(find.text('Enter an email'), findsOneWidget);
      expect(find.text('Enter a password'), findsOneWidget);
      verifyNever(
        () => mockAuthService.signInWithEmailAndPassword(any(), any()),
      );
    });

    testWidgets('calls signInWithEmailAndPassword on valid submit', (
      WidgetTester tester,
    ) async {
      when(
        () => mockAuthService.signInWithEmailAndPassword(
          'test@test.com',
          'password123',
        ),
      ).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(createTestWidget());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'test@test.com');
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Sign In with Email'));
      await tester.pump();

      verify(
        () => mockAuthService.signInWithEmailAndPassword(
          'test@test.com',
          'password123',
        ),
      ).called(1);
    });

    testWidgets('calls signInWithGoogle on button tap', (
      WidgetTester tester,
    ) async {
      when(
        () => mockAuthService.signInWithGoogle(),
      ).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Sign In with Google'));
      await tester.pump();

      verify(() => mockAuthService.signInWithGoogle()).called(1);
    });
  });
}
