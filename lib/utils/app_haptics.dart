import 'package:flutter/services.dart';

/// Centralized haptic feedback strategy for the entire application.
/// Ensures consistent patterns across UI interactions.
class AppHaptics {
  // Prevent instantiation
  AppHaptics._();

  /// Light impact:
  /// Used for navigation, opening sheets, changing tabs, or minor UI toggles.
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact:
  /// Used for primary actions (e.g., adding to watchlist, submitting a rating, standard button presses).
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact:
  /// Used for destructive actions (e.g., removing from history, clearing caches, resetting preferences).
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click:
  /// Used for granular selection events (e.g., segmented controls, scrolling list tick feedback, dragging sliders).
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate:
  /// Generic vibration for major alerts or errors.
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
