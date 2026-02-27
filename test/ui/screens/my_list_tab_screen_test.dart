import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:neon_voyager/ui/screens/my_list_tab_screen.dart';
import 'package:neon_voyager/config/providers.dart';

import '../../utils/test_app_wrapper.dart';

class MockUser extends Mock implements User {}

void main() {
  group('MyListTabScreen Widget Tests', () {
    testWidgets('displays sign in prompt when not logged in', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const MyListTabScreen(),
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        ),
      );

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(
        find.text('Sign in to access your synchronized lists'),
        findsOneWidget,
      );
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('displays tabs when logged in', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const MyListTabScreen(),
          overrides: [
            // Dummy user indicating logged in
            authStateProvider.overrideWith((ref) => Stream.value(MockUser())),
            watchlistEntriesProvider.overrideWith((ref) => Future.value([])),
            watchHistoryEntriesProvider.overrideWith((ref) => Future.value([])),
          ],
        ),
      );

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget); // tabHistory
    });
  });
}
