import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/media.dart';
import '../../config/providers.dart';

class TrailerButton extends ConsumerWidget {
  final int mediaId;
  final MediaType mediaType;

  const TrailerButton({
    super.key,
    required this.mediaId,
    required this.mediaType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trailerAsync = ref.watch(
      trailerUrlProvider((id: mediaId, type: mediaType)),
    );

    return trailerAsync.when(
      data: (url) {
        if (url == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF0000).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_filled_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trailer ansehen',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms);
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
