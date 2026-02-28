import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:stream_scout/ui/screens/ai_chat_screen.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/services/gemini_service.dart';
import 'package:stream_scout/data/repositories/tmdb_repository.dart';

import '../../utils/test_app_wrapper.dart';

class MockGeminiService extends Mock implements GeminiService {}

class MockTmdbRepository extends Mock implements TmdbRepository {}

void main() {
  late MockGeminiService mockGemini;
  late MockTmdbRepository mockTmdb;

  setUpAll(() {
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = Duration.zero; // Disable animations
  });

  setUp(() {
    mockGemini = MockGeminiService();
    mockTmdb = MockTmdbRepository();
  });

  group('AiChatScreen Widget Tests', () {
    testWidgets('displays welcome view initially', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(
          child: const AiChatScreen(),
          overrides: [
            geminiServiceProvider.overrideWithValue(mockGemini),
            tmdbRepositoryProvider.overrideWithValue(mockTmdb),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Was möchtest du schauen?'), findsOneWidget);
      expect(
        find.text('🎬 Was ist gerade gut?'),
        findsOneWidget,
      ); // Suggestion chip
    });

    testWidgets('sends message and displays stream', (tester) async {
      when(
        () => mockGemini.sendMessageStream(any()),
      ).thenAnswer((_) => Stream.fromIterable(['I recommend ', '*Matrix*.']));

      await tester.pumpWidget(
        pumpAppScreen(
          child: const AiChatScreen(),
          overrides: [
            geminiServiceProvider.overrideWithValue(mockGemini),
            tmdbRepositoryProvider.overrideWithValue(mockTmdb),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Tap suggestion to send message
      await tester.tap(find.text('🎬 Was ist gerade gut?'));

      // Wait for stream to process
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check user message is shown
      expect(
        find.text(
          'Was sind die besten Filme und Serien die gerade im Trend sind?',
        ),
        findsOneWidget,
      );
      // Check AI response is shown
      expect(find.text('I recommend *Matrix*.'), findsOneWidget);
    });
  });
}
