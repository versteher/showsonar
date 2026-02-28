import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/repositories/tmdb_repository.dart';
import '../theme/app_theme.dart';

class StreamingProviderChip extends StatelessWidget {
  final WatchProvider provider;
  final bool isUserService;
  final VoidCallback? onTap;

  const StreamingProviderChip({
    super.key,
    required this.provider,
    required this.isUserService,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor:
            onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isUserService
                ? AppTheme.success.withValues(alpha: 0.1)
                : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUserService
                  ? AppTheme.success.withValues(alpha: 0.5)
                  : AppTheme.surfaceBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.logoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: provider.fullLogoUrl,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 24,
                      height: 24,
                      color: AppTheme.surface,
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.play_circle,
                      size: 24,
                      color: AppTheme.textMuted,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.play_circle,
                  size: 24,
                  color: AppTheme.textMuted,
                ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  provider.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isUserService ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.open_in_new,
                  size: 12,
                  color: AppTheme.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
