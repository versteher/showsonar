import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stream_scout/config/providers/ai_trivia_provider.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';
import 'package:stream_scout/l10n/app_localizations.dart';

class AiTriviaSection extends ConsumerWidget {
  final Media media;

  const AiTriviaSection({super.key, required this.media});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final triviaAsync = ref.watch(aiTriviaProvider(media));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF7C4DFF),
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                AppLocalizations.of(context)!.aiTriviaTitle, // 'Did You Know?'
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          triviaAsync.when(
            data: (facts) => _buildFactsList(facts),
            loading: () => _buildLoadingState(),
            error: (_, __) =>
                const SizedBox.shrink(), // Silently fail and hide trivia
          ),
        ],
      ),
    );
  }

  Widget _buildFactsList(List<String> facts) {
    return Column(
      children: facts
          .map(
            (fact) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 6,
                      right: AppTheme.spacingSm,
                    ),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7C4DFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      fact,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLoadingState() {
    return Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 6,
                      right: AppTheme.spacingSm,
                    ),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, color: AppTheme.surfaceLight),
                        const SizedBox(height: 6),
                        Container(
                          height: 14,
                          width: index == 1 ? 150 : 250,
                          color: AppTheme.surfaceLight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1500.ms,
          colors: [
            AppTheme.surfaceLight,
            AppTheme.surfaceLight.withValues(alpha: 0.5),
            AppTheme.surfaceLight,
          ],
        );
  }
}
