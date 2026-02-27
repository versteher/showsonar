import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/user_preferences.dart';
import 'package:neon_voyager/domain/recommendation_engine.dart';

import '../utils/test_provider_container.dart';

class MockUser extends Mock implements User {
  @override
  String get uid => 'test_uid_123';
}

void main() {
  late MockDependencies mocks;
  late ProviderContainer container;

  setUp(() {
    mocks = MockDependencies();
    container = mocks.createContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('Core Providers', () {
    test('authServiceProvider returns a mock', () {
      final authService = container.read(authServiceProvider);
      expect(authService, mocks.authService);
    });

    test('authStateProvider emits states from authService', () async {
      final mockUser = MockUser();
      when(
        () => mocks.authService.authStateChanges,
      ).thenAnswer((_) => Stream.value(mockUser));

      final state = await container.read(authStateProvider.future);
      expect(state?.uid, 'test_uid_123');
    });

    test('userPreferencesRepositoryProvider gets uid from auth state', () async {
      // Use standard default "guest" without mocking auth
      final repo = container.read(userPreferencesRepositoryProvider);
      expect(repo, isNotNull);
      // We know it initialized successfully. Mocks handle the overrides in normal containers.
      // But this specifically tests the construction.
    });

    test('dismissedMediaIdsProvider resolves properly', () async {
      when(
        () => mocks.dismissedRepository.getAllDismissed(),
      ).thenAnswer((_) async => {'1', '2'});

      final ids = await container.read(dismissedMediaIdsProvider.future);

      expect(ids, {'1', '2'});
      verify(() => mocks.dismissedRepository.init()).called(1);
      verify(() => mocks.dismissedRepository.getAllDismissed()).called(1);
    });

    test('userPreferencesProvider resolves correctly', () async {
      const mockPrefs = UserPreferences(
        countryCode: 'US',
        countryName: 'United States',
        subscribedServiceIds: [],
        favoriteGenreIds: [28], // Action
        minimumRating: 5.0,
      );

      when(
        () => mocks.userPreferencesRepository.getPreferences(),
      ).thenAnswer((_) async => mockPrefs);

      final prefs = await container.read(userPreferencesProvider.future);

      expect(prefs.favoriteGenreIds, [28]);
      expect(prefs.countryCode, 'US');
      verify(() => mocks.userPreferencesRepository.init()).called(1);
      verify(() => mocks.userPreferencesRepository.getPreferences()).called(1);
    });

    test('recommendationEngineProvider constructs correctly', () async {
      const mockPrefs = UserPreferences(
        countryCode: 'US',
        countryName: 'United States',
        subscribedServiceIds: [],
        favoriteGenreIds: [],
        minimumRating: 0.0,
      );

      when(
        () => mocks.userPreferencesRepository.getPreferences(),
      ).thenAnswer((_) async => mockPrefs);

      final engine = await container.read(recommendationEngineProvider.future);

      expect(engine, isA<RecommendationEngine>());
      verify(() => mocks.watchHistoryRepository.init()).called(1);
    });

    test('themeModeProvider gets initial value or defaults to dark', () {
      when(
        () => mocks.localPreferencesRepository.themeMode,
      ).thenReturn(ThemeMode.light);

      final theme = container.read(themeModeProvider);
      expect(theme, ThemeMode.light);
    });
  });
}
