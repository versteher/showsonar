import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';
import 'ai_chat_app_bar.dart';
import 'ai_chat_input_bar.dart';
import 'ai_chat_message_bubble.dart';
import 'ai_chat_models.dart';
import 'ai_chat_welcome_view.dart';

/// AI Chat screen for getting movie/series recommendations
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  StreamSubscription<String>? _currentStream;

  List<SuggestionChip> _buildSuggestions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      SuggestionChip(l10n.aiSuggestion1Label, l10n.aiSuggestion1Query),
      SuggestionChip(l10n.aiSuggestion2Label, l10n.aiSuggestion2Query),
      SuggestionChip(l10n.aiSuggestion3Label, l10n.aiSuggestion3Query),
      SuggestionChip(l10n.aiSuggestion4Label, l10n.aiSuggestion4Query),
      SuggestionChip(l10n.aiSuggestion5Label, l10n.aiSuggestion5Query),
      SuggestionChip(l10n.aiSuggestion6Label, l10n.aiSuggestion6Query),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _currentStream?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessage = text.trim();
    _controller.clear();

    final notifier = ref.read(chatHistoryProvider.notifier);
    notifier.add(ChatMessage(text: userMessage, isUser: true));
    notifier.add(const ChatMessage(text: '', isUser: false, isStreaming: true));
    setState(() => _isLoading = true);
    _scrollToBottom();

    final gemini = ref.read(geminiServiceProvider);
    // Capture index immediately after adding both messages
    final aiMessageIndex = ref.read(chatHistoryProvider).length - 1;
    final buffer = StringBuffer();

    _currentStream = gemini
        .sendMessageStream(userMessage)
        .listen(
          (chunk) {
            buffer.write(chunk);
            if (mounted) {
              notifier.updateAt(
                aiMessageIndex,
                ChatMessage(
                  text: buffer.toString(),
                  isUser: false,
                  isStreaming: true,
                ),
              );
              _scrollToBottom();
            }
          },
          onDone: () {
            if (mounted) {
              notifier.updateAt(
                aiMessageIndex,
                ChatMessage(
                  text: buffer.toString(),
                  isUser: false,
                  isStreaming: false,
                ),
              );
              setState(() => _isLoading = false);
              _scrollToBottom();
            }
          },
          onError: (error) {
            if (mounted) {
              notifier.updateAt(
                aiMessageIndex,
                ChatMessage(
                  text: AppLocalizations.of(context)!.aiError,
                  isUser: false,
                  isStreaming: false,
                ),
              );
              setState(() => _isLoading = false);
            }
          },
        );
  }

  void _resetChat() {
    ref.read(geminiServiceProvider).resetChat();
    ref.read(chatHistoryProvider.notifier).clear();
    setState(() => _isLoading = false);
    _currentStream?.cancel();
  }

  /// Search TMDB for a title and navigate to its detail screen.
  Future<void> _searchAndNavigate(String title) async {
    try {
      final tmdb = ref.read(tmdbRepositoryProvider);
      final results = await tmdb.searchMulti(title);
      if (results.isNotEmpty && mounted) {
        final media = results.first;
        final typePath = media.type == MediaType.movie ? 'movie' : 'tv';
        context.push('/$typePath/${media.id}');
      } else if (mounted) {
        AppSnackBar.showNeutral(
          context,
          AppLocalizations.of(context)!.aiSearchNoResult(title),
          icon: Icons.search_off_rounded,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          AppLocalizations.of(context)!.aiSearchFailed,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatHistoryProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            // App bar
            AiChatAppBar(
              hasMessages: messages.isNotEmpty,
              onReset: _resetChat,
            ),

            // Chat body
            Expanded(
              child: messages.isEmpty
                  ? AiChatWelcomeView(
                      suggestions: _buildSuggestions(context),
                      onSuggestionTap: _sendMessage,
                    )
                  : _buildMessageList(messages),
            ),

            // Input area
            AiChatInputBar(
              controller: _controller,
              isLoading: _isLoading,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return AiChatMessageBubble(
          message: message,
          onTitleTap: _searchAndNavigate,
        );
      },
    );
  }
}
