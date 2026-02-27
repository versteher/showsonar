import 'package:neon_voyager/utils/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class WatchlistButton extends StatelessWidget {
  final bool isOnWatchlist;
  final String mediaTitle;
  final VoidCallback onToggle;

  const WatchlistButton({
    super.key,
    required this.isOnWatchlist,
    required this.mediaTitle,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: isOnWatchlist
          ? l10n.semanticWatchlistRemove(mediaTitle)
          : l10n.semanticWatchlistAdd(mediaTitle),
      child: GestureDetector(
        onTap: () {
          AppHaptics.lightImpact();
          onToggle();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isOnWatchlist
                ? const LinearGradient(
                    colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                  )
                : null,
            color: isOnWatchlist ? null : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOnWatchlist
                  ? Colors.transparent
                  : AppTheme.surfaceBorder,
            ),
            boxShadow: isOnWatchlist
                ? [
                    BoxShadow(
                      color: const Color(0xFFE040FB).withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isOnWatchlist
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: isOnWatchlist ? Colors.white : AppTheme.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
