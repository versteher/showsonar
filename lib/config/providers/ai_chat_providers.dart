import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/screens/ai_chat_models.dart';

/// Persists AI chat conversation history across modal open/close cycles.
class ChatHistoryNotifier extends StateNotifier<List<ChatMessage>> {
  ChatHistoryNotifier() : super([]);

  void add(ChatMessage message) => state = [...state, message];

  void updateAt(int index, ChatMessage message) {
    final updated = [...state];
    updated[index] = message;
    state = updated;
  }

  void clear() => state = [];
}

final chatHistoryProvider =
    StateNotifierProvider<ChatHistoryNotifier, List<ChatMessage>>(
      (_) => ChatHistoryNotifier(),
    );
