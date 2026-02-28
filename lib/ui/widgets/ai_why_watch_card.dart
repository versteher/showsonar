import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/media.dart';
import '../../config/providers.dart';
import '../theme/app_theme.dart';

class AiWhyWatchCard extends ConsumerStatefulWidget {
  final Media media;

  const AiWhyWatchCard({super.key, required this.media});

  @override
  ConsumerState<AiWhyWatchCard> createState() => _AiWhyWatchCardState();
}

class _AiWhyWatchCardState extends ConsumerState<AiWhyWatchCard> {
  String? _recommendation;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

  Future<void> _loadRecommendation() async {
    try {
      final gemini = ref.read(geminiServiceProvider);
      final typeStr = widget.media.type == MediaType.movie ? 'Film' : 'Serie';
      final result = await gemini.getWhyWatch(widget.media.title, typeStr);
      if (mounted) {
        setState(() {
          _recommendation = result.isNotEmpty ? result : null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || (!_isLoading && _recommendation == null)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C4DFF).withValues(alpha: 0.15),
            const Color(0xFFE040FB).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Warum du das schauen solltest',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE040FB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7C4DFF),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'StreamScout AI denkt nach...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          else
            Text(
              _recommendation!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
