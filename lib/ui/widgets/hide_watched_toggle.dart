import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/providers.dart';
import '../theme/app_theme.dart';

/// Toggle to hide/show already-watched content from carousels
class HideWatchedToggle extends ConsumerWidget {
  const HideWatchedToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideWatched = ref.watch(hideWatchedProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: GestureDetector(
        onTap: () =>
            ref.read(hideWatchedProvider.notifier).state = !hideWatched,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hideWatched
                ? AppTheme.primary.withValues(alpha: 0.15)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hideWatched ? AppTheme.primary : AppTheme.surfaceBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hideWatched
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 16,
                color: hideWatched ? AppTheme.primary : AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                hideWatched ? 'Gesehenes ausgeblendet' : 'Gesehenes anzeigen',
                style: TextStyle(
                  fontSize: 12,
                  color: hideWatched ? AppTheme.primary : AppTheme.textMuted,
                  fontWeight: hideWatched ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
