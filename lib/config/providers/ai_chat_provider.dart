import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stream_scout/data/models/ai_chat_message.dart';

import 'package:stream_scout/config/providers.dart';

// Provides the GenAI chat session.
final aiChatSessionProvider = Provider<ChatSession?>((ref) {
  final apiKey = const String.fromEnvironment('GEMINI_API_KEY');
  if (apiKey.isEmpty) {
    return null;
  }

  // To give Gemini context, we pull the user's favorite genres
  final prefs = ref.watch(userPreferencesProvider).valueOrNull;
  final genresContext = prefs?.favoriteGenreIds.join(', ') ?? 'various genres';

  final watchHistory = ref.watch(watchHistoryEntriesProvider).valueOrNull ?? [];
  final recentHistory = watchHistory.take(5).map((e) => e.title).join(', ');

  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
    systemInstruction: Content.system('''
You are an expert movie and TV show recommendation assistant for an app called ShowSonar.
The user enjoys $genresContext.
Recently watched: $recentHistory.

When the user asks for recommendations, respond in a friendly conversational tone. 
If your response includes specific movies or TV shows, you MUST include a precise JSON payload at the VERY END of your message containing their TMDB IDs so the app can render them.

Format the IDs exactly like this on a new line at the end:
```json
{"tmdb_ids": [123, 456, 789]}
```
If you are just having a conversation and not recommending anything specific, omit the JSON payload. Keep responses relatively short.
'''),
  );

  return model.startChat();
});

class AiChatNotifier extends StateNotifier<List<AiChatMessage>> {
  AiChatNotifier(this._chatSession) : super([]);

  final ChatSession? _chatSession;
  bool isLoading = false;

  Future<void> sendMessage(String text) async {
    if (_chatSession == null || text.trim().isEmpty) return;

    final userMessage = AiChatMessage(
      id: DateTime.now().toIso8601String(),
      role: AiChatRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];
    isLoading = true;

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      final responseText = response.text ?? '';

      // Parse for tmdb_ids JSON payload
      List<int> extractedIds = [];
      String cleanContent = responseText;

      final jsonRegex = RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true);
      final match = jsonRegex.firstMatch(responseText);

      if (match != null) {
        try {
          final jsonStr = match.group(1)!;
          final Map<String, dynamic> data = jsonDecode(jsonStr);
          if (data['tmdb_ids'] is List) {
            extractedIds = List<int>.from(data['tmdb_ids']);
          }
          // Remove the JSON block from the user-facing text
          cleanContent = responseText.replaceFirst(match.group(0)!, '').trim();
        } catch (e) {
          // JSON parsing failed, just use original text
        }
      }

      final aiMessage = AiChatMessage(
        id: DateTime.now().toIso8601String(),
        role: AiChatRole.ai,
        content: cleanContent,
        recommendedMediaIds: extractedIds,
        timestamp: DateTime.now(),
      );

      state = [...state, aiMessage];
    } catch (e) {
      final errorMessage = AiChatMessage(
        id: DateTime.now().toIso8601String(),
        role: AiChatRole.ai,
        content:
            'I am having trouble connecting to my database right now. Please try again later.',
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    } finally {
      isLoading = false;
    }
  }
}

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, List<AiChatMessage>>((ref) {
      final session = ref.watch(aiChatSessionProvider);
      return AiChatNotifier(session);
    });
