import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../theme/app_theme.dart';

/// Weekly recap card showing this week's watching stats
class WeeklyRecapCard extends ConsumerWidget {
  const WeeklyRecapCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recapAsync = ref.watch(weeklyRecapProvider);

    return recapAsync.when(
      data: (recap) {
        // Don't show if nothing watched ever
        if (recap.watchedThisWeek == 0 && recap.streakDays == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child:
              Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                          const Color(0xFF0F3460).withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                              ).createShader(bounds),
                              child: const Icon(
                                Icons.insights_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.recapTitle,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            const Spacer(),
                            if (recap.streakDays > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6D00),
                                      Color(0xFFFF9100),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.recapDays(recap.streakDays),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Stats row
                        Row(
                          children: [
                            _buildStatItem(
                              context,
                              icon: Icons.play_circle_rounded,
                              value: '${recap.watchedThisWeek}',
                              label: AppLocalizations.of(context)!.recapWatched,
                              color: const Color(0xFF00E5FF),
                            ),
                            const SizedBox(width: 16),
                            _buildStatItem(
                              context,
                              icon: Icons.schedule_rounded,
                              value:
                                  '${recap.estimatedHours.toStringAsFixed(1)}h',
                              label: AppLocalizations.of(context)!.recapHours,
                              color: const Color(0xFF76FF03),
                            ),
                            if (recap.averageRating > 0) ...[
                              const SizedBox(width: 16),
                              _buildStatItem(
                                context,
                                icon: Icons.star_rounded,
                                value: recap.averageRating.toStringAsFixed(1),
                                label: AppLocalizations.of(
                                  context,
                                )!.recapRating,
                                color: const Color(0xFFFFD740),
                              ),
                            ],
                            if (recap.topGenreName != null) ...[
                              const SizedBox(width: 16),
                              _buildStatItem(
                                context,
                                icon: Icons.category_rounded,
                                value: recap.topGenreName!,
                                label: AppLocalizations.of(
                                  context,
                                )!.recapTopGenre,
                                color: const Color(0xFFE040FB),
                                isText: true,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isText = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isText ? 11 : 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
