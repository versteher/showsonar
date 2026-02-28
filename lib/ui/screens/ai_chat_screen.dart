import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
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
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  StreamSubscription<String>? _currentStream;

  static const List<SuggestionChip> _suggestions = [
    SuggestionChip(
      '🎬 Was ist gerade gut?',
      'Was sind die besten Filme und Serien die gerade im Trend sind?',
    ),
    SuggestionChip(
      '😂 Was Lustiges',
      'Empfiehl mir eine richtig lustige Komödie die man gesehen haben muss',
    ),
    SuggestionChip(
      '🔥 Thriller wie Dark',
      'Ich suche einen spannenden Thriller oder Mystery-Serie ähnlich wie Dark',
    ),
    SuggestionChip(
      '🤔 Zum Nachdenken',
      'Empfiehl mir einen Film oder eine Serie die zum Nachdenken anregt, tiefgründig und emotional',
    ),
    SuggestionChip(
      '👨‍👩‍👧 Familienabend',
      'Was kann man als Familie zusammen schauen? Nicht zu kindisch aber jugendfrei',
    ),
    SuggestionChip(
      '🏆 Oscar-würdig',
      'Was sind die besten preisgekrönten Filme der letzten Jahre die man gesehen haben muss?',
    ),
  ];

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

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _messages.add(ChatMessage(text: '', isUser: false, isStreaming: true));
      _isLoading = true;
    });
    _scrollToBottom();

    final gemini = ref.read(geminiServiceProvider);
    final aiMessageIndex = _messages.length - 1;
    final buffer = StringBuffer();

    _currentStream = gemini
        .sendMessageStream(userMessage)
        .listen(
          (chunk) {
            buffer.write(chunk);
            if (mounted) {
              setState(() {
                _messages[aiMessageIndex] = ChatMessage(
                  text: buffer.toString(),
                  isUser: false,
                  isStreaming: true,
                );
              });
              _scrollToBottom();
            }
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _messages[aiMessageIndex] = ChatMessage(
                  text: buffer.toString(),
                  isUser: false,
                  isStreaming: false,
                );
                _isLoading = false;
              });
              _scrollToBottom();
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _messages[aiMessageIndex] = ChatMessage(
                  text:
                      '❌ Ein Fehler ist aufgetreten. Bitte versuche es erneut.',
                  isUser: false,
                  isStreaming: false,
                );
                _isLoading = false;
              });
            }
          },
        );
  }

  void _resetChat() {
    ref.read(geminiServiceProvider).resetChat();
    setState(() {
      _messages.clear();
      _isLoading = false;
    });
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
          'Kein Ergebnis für "$title"',
          icon: Icons.search_off_rounded,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.showError(context, 'Suche fehlgeschlagen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            // App bar
            AiChatAppBar(
              hasMessages: _messages.isNotEmpty,
              onReset: _resetChat,
            ),

            // Chat body
            Expanded(
              child: _messages.isEmpty
                  ? AiChatWelcomeView(
                      suggestions: _suggestions,
                      onSuggestionTap: _sendMessage,
                    )
                  : _buildMessageList(),
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

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return AiChatMessageBubble(
          message: message,
          onTitleTap: _searchAndNavigate,
        );
      },
    );
  }
}
