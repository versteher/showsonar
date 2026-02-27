// GeminiService tests
//
// The GeminiService constructor initializes a GenerativeModel with the API key
// from dotenv. In test environments where dotenv is not loaded, the API key
// will be empty and methods will use fallback paths.
//
// However, the google_generative_ai package may throw during model/chat
// initialization with an empty key. We test what we can without a configured
// API: the resetChat method and the class structure.
//
// For full integration testing of GeminiService, a real or mocked API key
// would be needed, which is beyond the scope of unit tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:neon_voyager/data/services/gemini_service.dart';

void main() {
  group('GeminiService', () {
    test('can be instantiated', () {
      // The constructor should not throw even with empty API key
      final service = GeminiService();
      expect(service, isNotNull);
    });

    test('resetChat can be called without error', () {
      final service = GeminiService();
      // resetChat re-initializes the chat session
      expect(() => service.resetChat(), returnsNormally);
    });

    test('resetChat can be called multiple times', () {
      final service = GeminiService();
      service.resetChat();
      service.resetChat();
      // No exception expected
    });

    // sendMessage, sendMessageStream, getWhyWatch depend on
    // ApiConfig.isGeminiConfigured which reads from dotenv.
    // Since dotenv is not loaded in test, these would throw.
    // They are tested via integration tests instead.
  });
}
