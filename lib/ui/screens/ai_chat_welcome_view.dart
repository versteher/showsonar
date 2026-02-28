import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'ai_chat_models.dart';

/// Welcome / empty-state view shown before the first message is sent.
class AiChatWelcomeView extends StatelessWidget {
  final List<SuggestionChip> suggestions;

  /// Called when the user taps a suggestion chip; receives the prompt text.
  final ValueChanged<String> onSuggestionTap;

  const AiChatWelcomeView({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
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
            children: suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              return _SuggestionChipTile(
                suggestion: suggestion,
                index: index,
                onTap: () => onSuggestionTap(suggestion.prompt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChipTile extends StatelessWidget {
  final SuggestionChip suggestion;
  final int index;
  final VoidCallback onTap;

  const _SuggestionChipTile({
    required this.suggestion,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
}
