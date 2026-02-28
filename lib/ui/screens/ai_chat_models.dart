/// Data models shared across the AI chat screen widgets.
library;

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
}

/// A pre-defined suggestion that the user can tap to start a conversation.
class SuggestionChip {
  final String label;
  final String prompt;

  const SuggestionChip(this.label, this.prompt);
}
