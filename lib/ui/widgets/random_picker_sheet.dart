import 'package:stream_scout/utils/app_haptics.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';

/// Random picker bottom sheet — spin to find what to watch
class RandomPickerSheet extends ConsumerStatefulWidget {
  const RandomPickerSheet({super.key});

  @override
  ConsumerState<RandomPickerSheet> createState() => _RandomPickerSheetState();
}

class _RandomPickerSheetState extends ConsumerState<RandomPickerSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  bool _isSpinning = false;
  bool _hasResult = false;
  Media? _result;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    setState(() {
      _isSpinning = true;
      _hasResult = false;
      _result = null;
    });

    _spinController.repeat();
    AppHaptics.mediumImpact();

    // Invalidate and refetch
    ref.invalidate(randomPickerResultProvider);

    try {
      final result = await ref.read(randomPickerResultProvider.future);
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 800));
        _spinController.stop();
        setState(() {
          _isSpinning = false;
          _hasResult = true;
          _result = result;
        });
        AppHaptics.heavyImpact();
      }
    } catch (_) {
      if (mounted) {
        _spinController.stop();
        setState(() {
          _isSpinning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(randomPickerFilterProvider);
    final minRating = ref.watch(randomPickerMinRatingProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            AppTheme.background,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF6D00), Color(0xFFFFD740)],
            ).createShader(bounds),
            child: const Text(
              '🎲 Was soll ich schauen?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip(
                  '🎬 Filme',
                  filter == RandomPickerFilter.movies,
                  () => ref.read(randomPickerFilterProvider.notifier).state =
                      RandomPickerFilter.movies,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  '📺 Serien',
                  filter == RandomPickerFilter.series,
                  () => ref.read(randomPickerFilterProvider.notifier).state =
                      RandomPickerFilter.series,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  '🌐 Beides',
                  filter == RandomPickerFilter.both,
                  () => ref.read(randomPickerFilterProvider.notifier).state =
                      RandomPickerFilter.both,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Min rating slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFFFD740),
                ),
                const SizedBox(width: 6),
                Text(
                  'Min. ${minRating.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFFFD740),
                      inactiveTrackColor: AppTheme.surface,
                      thumbColor: const Color(0xFFFFD740),
                      overlayColor: const Color(
                        0xFFFFD740,
                      ).withValues(alpha: 0.2),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                    ),
                    child: Slider(
                      value: minRating,
                      min: 1.0,
                      max: 9.0,
                      onChanged: (v) =>
                          ref
                                  .read(randomPickerMinRatingProvider.notifier)
                                  .state =
                              v,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Spin button / Result
          if (_isSpinning)
            SizedBox(
              height: 200,
              child: Center(
                child: RotationTransition(
                  turns: _spinController,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6D00), Color(0xFFFFD740)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6D00).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🎲', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ),
              ),
            )
          else if (_hasResult && _result != null)
            _buildResult(context, _result!)
          else if (_hasResult && _result == null)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Keine Titel gefunden. Versuch andere Filter!',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          else
            const SizedBox(height: 20),

          const SizedBox(height: 16),

          // Action button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSpinning ? null : _spin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6D00), Color(0xFFFFD740)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _hasResult ? '🎲 Nochmal!' : '🎲 Los geht\'s!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF6D00).withValues(alpha: 0.2)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF6D00)
                  : AppTheme.surfaceBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFFF6D00)
                    : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context, Media media) {
    return GestureDetector(
          onTap: () {
            context.pop();
            context.push('/media.type/media.id');
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: const Color(0xFFFFD740).withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD740).withValues(alpha: 0.1),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                // Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: media.posterPath != null
                      ? Hero(
                          tag: 'poster_${media.type.name}_${media.id}',
                          child: CachedNetworkImage(
                            imageUrl: media.fullPosterPath,
                            width: 70,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 100,
                          color: AppTheme.surfaceLight,
                          child: const Icon(
                            Icons.movie_rounded,
                            color: AppTheme.textMuted,
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        media.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFFFD740),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            media.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFFFFD740),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${media.year} • ${media.type.displayName}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        media.overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFFFD740),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 400.ms,
        );
  }
}
