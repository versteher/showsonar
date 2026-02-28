import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../config/api_config.dart';

/// Service for AI-powered movie/series recommendations using Gemini.
/// Calls go through the Cloud Run proxy — no API key on device.
class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;

  /// Lazy initialization of Gemini model via proxy endpoint.
  /// Uses a custom HTTP client to rewrite the SDK's upstream URL
  /// to our Cloud Run proxy, which injects the real API key.
  GenerativeModel get model {
    _model ??= GenerativeModel(
      model: 'gemini-2.0-flash',
      // The real key lives in Secret Manager; proxy injects it.
      // The SDK requires a non-empty value here, so we pass a placeholder.
      apiKey: 'proxy-managed',
      httpClient: _ProxyHttpClient(ApiConfig.geminiBaseUrl),
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(_systemPrompt),
    );
    return _model!;
  }

  static const String _systemPrompt = '''
Du bist StreamScout AI – ein enthusiastischer, sachkundiger Film- und Serienberater.
Deine Aufgabe ist es, personalisierte Empfehlungen zu geben, die begeistern.

REGELN:
1. Antworte IMMER auf Deutsch.
2. Sei enthusiastisch aber nicht übertrieben – wie ein guter Freund, der Filme liebt.
3. Gib bei jeder Empfehlung: Titel, Jahr, warum sehenswert (1-2 Sätze).
4. Nutze Emojis sparsam für Struktur (🎬 für Filme, 📺 für Serien, ⭐ für Highlights).
5. Bei Stimmungsanfragen (z.B. "was Lustiges") gib 3-5 Empfehlungen.
6. Erwähne wenn möglich ob etwas auf Netflix, Disney+, Amazon Prime o.ä. verfügbar ist.
7. Halte Antworten kompakt – maximal 200 Wörter.
8. Bei allgemeinen Fragen zu Filmen/Serien: antworte kenntnisreich und hilfreich.
''';

  /// Start or continue a chat session
  ChatSession get chatSession {
    _chatSession ??= model.startChat();
    return _chatSession!;
  }

  /// Send a message and get a streaming response
  Stream<String> sendMessageStream(String message) async* {
    if (!ApiConfig.isGeminiConfigured) {
      yield 'Gemini nicht konfiguriert.';
      return;
    }
    try {
      final response = chatSession.sendMessageStream(Content.text(message));
      await for (final chunk in response) {
        if (chunk.text != null) yield chunk.text!;
      }
    } catch (e) {
      yield '\n\n❌ Fehler: ${e.toString().split('\n').first}';
    }
  }

  /// Send a message and get a complete response
  Future<String> sendMessage(String message) async {
    if (!ApiConfig.isGeminiConfigured) return 'Gemini nicht konfiguriert.';
    try {
      final response = await chatSession.sendMessage(Content.text(message));
      return response.text ?? 'Keine Antwort erhalten.';
    } catch (e) {
      return 'Fehler: ${e.toString().split('\n').first}';
    }
  }

  /// Get a quick recommendation for why to watch something
  Future<String> getWhyWatch(String title, String type) async {
    if (!ApiConfig.isGeminiConfigured) return '';
    final prompt =
        'Gib mir in genau 2 kurzen Sätzen einen überzeugenden Grund, '
        'warum man "$title" ($type) schauen sollte. Keine Spoiler!';
    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Reset the chat session
  void resetChat() {
    _chatSession = null;
  }
}

/// HTTP client shim that rewrites the Gemini SDK's upstream URL to the proxy.
/// The SDK calls https://generativelanguage.googleapis.com/v1beta/...
/// We redirect to ApiConfig.geminiBaseUrl keeping the path and query intact.
class _ProxyHttpClient extends http.BaseClient {
  _ProxyHttpClient(this._proxyBase);

  final String _proxyBase;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final original = request.url;
    final proxyUri = Uri.parse(_proxyBase);
    final rewritten = proxyUri.replace(
      path: '${proxyUri.path}${original.path}',
      query: original.query,
    );
    final newRequest = http.Request(request.method, rewritten)
      ..headers.addAll(request.headers);
    if (request is http.Request) {
      newRequest.bodyBytes = request.bodyBytes;
    }
    return _inner.send(newRequest);
  }
}
