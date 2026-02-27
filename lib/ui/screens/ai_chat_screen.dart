import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/providers.dart';
import '../../utils/ai_title_parser.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';

/// AI Chat screen for getting movie/series recommendations
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  StreamSubscription<String>? _currentStream;

  static const List<_SuggestionChip> _suggestions = [
    _SuggestionChip(
      '🎬 Was ist gerade gut?',
      'Was sind die besten Filme und Serien die gerade im Trend sind?',
    ),
    _SuggestionChip(
      '😂 Was Lustiges',
      'Empfiehl mir eine richtig lustige Komödie die man gesehen haben muss',
    ),
    _SuggestionChip(
      '🔥 Thriller wie Dark',
      'Ich suche einen spannenden Thriller oder Mystery-Serie ähnlich wie Dark',
    ),
    _SuggestionChip(
      '🤔 Zum Nachdenken',
      'Empfiehl mir einen Film oder eine Serie die zum Nachdenken anregt, tiefgründig und emotional',
    ),
    _SuggestionChip(
      '👨‍👩‍👧 Familienabend',
      'Was kann man als Familie zusammen schauen? Nicht zu kindisch aber jugendfrei',
    ),
    _SuggestionChip(
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
      _messages.add(_ChatMessage(text: userMessage, isUser: true));
      _messages.add(_ChatMessage(text: '', isUser: false, isStreaming: true));
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
                _messages[aiMessageIndex] = _ChatMessage(
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
                _messages[aiMessageIndex] = _ChatMessage(
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
                _messages[aiMessageIndex] = _ChatMessage(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            // App bar
            _buildAppBar(context),

            // Chat body
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeView()
                  : _buildMessageList(),
            ),

            // Input area
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                    ).createShader(bounds),
                    child: Text(
                      'NeonVoyager AI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'Dein persönlicher Film-Berater',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (_messages.isNotEmpty)
              IconButton(
                onPressed: _resetChat,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // AI avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 40,
              color: Colors.white,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            'Was möchtest du schauen?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 8),

          Text(
            'Frag mich nach Empfehlungen, Stimmungen\noder bestimmten Genres!',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 32),

          // Suggestion chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              return _buildSuggestionChip(suggestion, index);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(_SuggestionChip suggestion, int index) {
    return GestureDetector(
      onTap: () => _sendMessage(suggestion.prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          suggestion.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    ).animate().fadeIn(delay: (400 + index * 80).ms).slideY(begin: 0.2, end: 0);
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
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser
                          ? AppTheme.primary.withValues(alpha: 0.3)
                          : AppTheme.surfaceLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.text.isEmpty && message.isStreaming)
                        _buildTypingIndicator()
                      else
                        SelectableText(
                          message.text,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      if (message.isStreaming && message.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: const Color(0xFF7C4DFF),
                            ),
                          ),
                        ),
                      // Feature 2: Clickable AI title chips
                      if (!isUser &&
                          !message.isStreaming &&
                          message.text.isNotEmpty)
                        _buildTitleChips(message.text),
                      // Feature 10: Copy/Share action row
                      if (!isUser &&
                          !message.isStreaming &&
                          message.text.isNotEmpty)
                        _buildMessageActions(message.text),
                    ],
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 8),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: isUser ? 0.1 : -0.1, end: 0, duration: 300.ms);
  }

  /// Feature 2: Render clickable title chips for detected movie/series names
  Widget _buildTitleChips(String text) {
    final titles = AiTitleParser.extractTitles(text);
    if (titles.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: titles.map((title) {
          return ActionChip(
            key: Key('title_chip_$title'),
            avatar: const Icon(
              Icons.movie_filter_outlined,
              size: 16,
              color: Color(0xFF7C4DFF),
            ),
            label: Text(
              title,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
            ),
            backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
              ),
            ),
            onPressed: () => _searchAndNavigate(title),
          );
        }).toList(),
      ),
    );
  }

  /// Search TMDB for a title and navigate to its detail screen
  Future<void> _searchAndNavigate(String title) async {
    try {
      final tmdb = ref.read(tmdbRepositoryProvider);
      final results = await tmdb.searchMulti(title);
      if (results.isNotEmpty && mounted) {
        final media = results.first;
        context.push('/media.type/media.id');
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

  /// Feature 10: Action row with copy & share for AI responses
  Widget _buildMessageActions(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            key: const Key('copy_button'),
            icon: Icons.copy_rounded,
            tooltip: 'Kopieren',
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              if (mounted) {
                AppSnackBar.showInfo(context, 'Text kopiert');
              }
            },
          ),
          const SizedBox(width: 4),
          _buildActionButton(
            key: const Key('share_button'),
            icon: Icons.share_rounded,
            tooltip: 'Teilen',
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              if (mounted) {
                AppSnackBar.showInfo(
                  context,
                  'In Zwischenablage kopiert — zum Teilen einfügen',
                  icon: Icons.share_rounded,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required Key key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 16, color: AppTheme.textMuted),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: _BouncingDot(delay: index * 200),
        );
      }),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: AppTheme.surfaceLight.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            // Text field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isLoading
                        ? AppTheme.textMuted.withValues(alpha: 0.2)
                        : const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: _isLoading
                        ? 'NeonVoyager AI denkt nach...'
                        : 'Frag mich was...',
                    hintStyle: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: _isLoading ? null : (text) => _sendMessage(text),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: _isLoading ? null : () => _sendMessage(_controller.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: _isLoading
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                        ),
                  color: _isLoading ? AppTheme.surfaceLight : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(
                              0xFF7C4DFF,
                            ).withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                ),
                child: Icon(
                  _isLoading ? Icons.hourglass_top_rounded : Icons.send_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Helper Classes
// =============================================================================

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isStreaming;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isStreaming = false,
  });
}

class _SuggestionChip {
  final String label;
  final String prompt;

  const _SuggestionChip(this.label, this.prompt);
}

/// Bouncing dot for typing indicator
class _BouncingDot extends StatefulWidget {
  final int delay;

  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -4 * _controller.value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
