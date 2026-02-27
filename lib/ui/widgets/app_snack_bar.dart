import 'package:neon_voyager/utils/app_haptics.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium styled snackbar helper for consistent feedback across the app.
class AppSnackBar {
  AppSnackBar._();

  /// Show a success snackbar (green accent)
  static void showSuccess(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
  }) {
    AppHaptics.lightImpact();
    _show(context, message, icon, AppTheme.success);
  }

  /// Show an info/action snackbar (primary accent)
  static void showInfo(
    BuildContext context,
    String message, {
    IconData icon = Icons.info_rounded,
  }) {
    AppHaptics.lightImpact();
    _show(context, message, icon, AppTheme.primary);
  }

  /// Show an accent snackbar (pink/purple for watchlist-type actions)
  static void showAccent(
    BuildContext context,
    String message, {
    IconData icon = Icons.bookmark_rounded,
  }) {
    AppHaptics.lightImpact();
    _show(context, message, icon, const Color(0xFFE040FB));
  }

  /// Show a removal/neutral snackbar
  static void showNeutral(
    BuildContext context,
    String message, {
    IconData icon = Icons.delete_outline_rounded,
  }) {
    AppHaptics.lightImpact();
    _show(context, message, icon, AppTheme.textMuted);
  }

  /// Show an error snackbar
  static void showError(
    BuildContext context,
    String message, {
    IconData icon = Icons.error_outline_rounded,
  }) {
    AppHaptics.heavyImpact();
    _show(context, message, icon, AppTheme.error);
  }

  /// Show a snackbar with an undo action. Returns a [ScaffoldFeatureController]
  /// that can be used to check if undo was tapped.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showWithUndo(
    BuildContext context,
    String message, {
    required VoidCallback onUndo,
    IconData icon = Icons.delete_outline_rounded,
    Color accentColor = const Color(0xFF90A4AE),
  }) {
    AppHaptics.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Rückgängig',
          textColor: AppTheme.primary,
          onPressed: onUndo,
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accentColor.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color accentColor,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accentColor.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );
  }
}
