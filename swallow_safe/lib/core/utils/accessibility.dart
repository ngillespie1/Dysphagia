import 'package:flutter/widgets.dart';

/// Accessibility helpers for SwallowSafe.
///
/// Every animation-driven widget should check [shouldReduceMotion] and
/// gracefully degrade: skip entrance fades, confetti, particle effects,
/// and pulse animations when the user has requested reduced motion.
class A11y {
  A11y._();

  /// Returns `true` when the platform has requested reduced animations
  /// (e.g., iOS "Reduce Motion", Android "Remove animations").
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Returns a duration that is either [normal] or [Duration.zero] when
  /// reduced motion is active — useful for wrapping AnimatedContainer /
  /// AnimatedOpacity durations.
  static Duration effectiveDuration(
    BuildContext context,
    Duration normal,
  ) {
    return shouldReduceMotion(context) ? Duration.zero : normal;
  }

  /// Returns the user's preferred text scale factor.
  /// Widgets should use this instead of hard-coded font sizes whenever
  /// possible, or at minimum apply `Theme.of(context).textTheme`.
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1.0);
  }

  /// Minimum touch target size per Material Design guidelines (48 × 48 dp).
  static const double kMinTouchTarget = 48.0;

  /// Preferred generous touch target for medical/motor-impairment contexts.
  static const double kComfortableTouchTarget = 56.0;

  /// Wraps a child with minimum touch target padding if needed.
  static Widget ensureTouchTarget(Widget child, {double min = 48.0}) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: min, minHeight: min),
      child: child,
    );
  }
}
