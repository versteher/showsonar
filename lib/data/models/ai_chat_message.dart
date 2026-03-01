import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_message.freezed.dart';
part 'ai_chat_message.g.dart';

enum AiChatRole { user, ai }

@freezed
class AiChatMessage with _$AiChatMessage {
  const factory AiChatMessage({
    required String id,
    required AiChatRole role,
    required String content,
    @Default([]) List<int> recommendedMediaIds,
    required DateTime timestamp,
  }) = _AiChatMessage;

  factory AiChatMessage.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageFromJson(json);
}
