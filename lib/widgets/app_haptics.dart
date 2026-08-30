import 'package:flutter/services.dart';

/// Centralized sensory & haptic feedback profile for Trentify.
/// Provides consistent tactile response across all iOS and Android devices.
class AppHaptics {
  AppHaptics._();

  /// Subtle touch feedback for minor UI interactions (tabs, chips, filters)
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium tactile response for button presses and cards
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Strong impact for major transactions, order placement, or deletions
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection tick for pickers and segmented controls
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Success confirmation pattern
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Warning / Error notification pattern
  static void error() {
    HapticFeedback.heavyImpact();
  }
}
