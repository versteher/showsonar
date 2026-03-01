/// Data models shared across the AI chat screen widgets.
library;

import 'dart:convert';

/// Represents a single message in the AI chat conversation.
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isStreaming;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isStreaming = false,
  });

  /// The cleaned text without the hidden JSON payload
  String get cleanText {
    final match = _jsonRegex.firstMatch(text);
    if (match != null) {
      return text.replaceFirst(match.group(0)!, '').trim();
    }
    return text.trim();
  }

  /// Any TMDB IDs extracted from a JSON payload in the text
  List<int> get recommendedIds {
    final match = _jsonRegex.firstMatch(text);
    if (match != null) {
      try {
        final jsonStr = match.group(1)!;
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        if (data['tmdb_ids'] is List) {
          return List<int>.from(data['tmdb_ids']);
        }
      } catch (_) {}
    }
    return [];
  }

  // Regex to match a JSON block (optionally wrapped in triple backticks)
  static final RegExp _jsonRegex = RegExp(
    r'```json\s*(\{.*?\})\s*```',
    dotAll: true,
  );
}

/// A pre-defined suggestion that the user can tap to start a conversation.
class SuggestionChip {
  final String label;
  final String prompt;

  const SuggestionChip(this.label, this.prompt);
}
