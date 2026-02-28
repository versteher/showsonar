import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bottom input area for the AI chat screen.
///
/// Displays a text field and an animated send button. The send button and
/// text field are disabled while [isLoading] is true.
class AiChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;

  /// Called with the message text when the user submits.
  final ValueChanged<String> onSend;

  const AiChatInputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
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
                    color: isLoading
                        ? AppTheme.textMuted.withValues(alpha: 0.2)
                        : const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  enabled: !isLoading,
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: isLoading
                        ? 'StreamScout AI denkt nach...'
                        : 'Frag mich was...',
                    hintStyle: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: isLoading ? null : onSend,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: isLoading ? null : () => onSend(controller.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isLoading
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                        ),
                  color: isLoading ? AppTheme.surfaceLight : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 12,
                          ),
                        ],
                ),
                child: Icon(
                  isLoading
                      ? Icons.hourglass_top_rounded
                      : Icons.send_rounded,
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
