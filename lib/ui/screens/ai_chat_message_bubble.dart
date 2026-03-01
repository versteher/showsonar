import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/ai_title_parser.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';
import 'ai_chat_models.dart';

/// Renders a single chat message bubble for both user and AI messages.
///
/// For AI messages the bubble also shows:
///  - A typing indicator while streaming with no text yet.
///  - A streaming progress indicator while text is arriving.
///  - Clickable title chips for detected movie/series names.
///  - Copy / share action buttons.
class AiChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  /// Called when the user taps a detected title chip; receives the title string.
  final ValueChanged<String> onTitleTap;

  const AiChatMessageBubble({
    super.key,
    required this.message,
    required this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                        const _TypingIndicator()
                      else
                        SelectableText(
                          message.text,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      if (message.isStreaming && message.text.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Color(0xFF7C4DFF),
                            ),
                          ),
                        ),
                      // Clickable title chips (Feature 2)
                      if (!isUser &&
                          !message.isStreaming &&
                          message.text.isNotEmpty)
                        _TitleChips(
                          text: message.text,
                          onTitleTap: onTitleTap,
                        ),
                      // Copy / share actions (Feature 10)
                      if (!isUser &&
                          !message.isStreaming &&
                          message.text.isNotEmpty)
                        _MessageActions(text: message.text),
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
}

// ---------------------------------------------------------------------------
// Typing indicator
// ---------------------------------------------------------------------------

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
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
}

// ---------------------------------------------------------------------------
// Title chips (Feature 2)
// ---------------------------------------------------------------------------

class _TitleChips extends StatelessWidget {
  final String text;
  final ValueChanged<String> onTitleTap;

  const _TitleChips({required this.text, required this.onTitleTap});

  @override
  Widget build(BuildContext context) {
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
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
              ),
            ),
            backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
              ),
            ),
            onPressed: () => onTitleTap(title),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message action buttons (Feature 10)
// ---------------------------------------------------------------------------

class _MessageActions extends StatelessWidget {
  final String text;

  const _MessageActions({required this.text});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            key: const Key('copy_button'),
            icon: Icons.copy_rounded,
            tooltip: l10n.actionCopy,
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              AppSnackBar.showInfo(context, l10n.actionCopied);
            },
          ),
          const SizedBox(width: 4),
          _ActionButton(
            key: const Key('share_button'),
            icon: Icons.share_rounded,
            tooltip: l10n.actionShare,
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              AppSnackBar.showInfo(
                context,
                l10n.actionCopiedForSharing,
                icon: Icons.share_rounded,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}

// ---------------------------------------------------------------------------
// Bouncing dot animation
// ---------------------------------------------------------------------------

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
