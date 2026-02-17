import 'package:flutter/services.dart';

/// Audio & haptic feedback service for SwallowSafe.
///
/// Provides tonal cues for exercise phases (hold ticks, completion bells,
/// celebration sounds) using system haptics as a placeholder for future
/// bundled audio assets. Each method is a no-op when [enabled] is false.
///
/// Once real audio assets are bundled, replace the haptic stubs with
/// `AudioPlayer.play('assets/audio/bell_complete.wav')` etc.
class AudioFeedbackService {
  bool _enabled = true;

  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  /// Toggle sounds on/off.
  void toggle() => _enabled = !_enabled;

  /// Soft bell — exercise or session complete.
  Future<void> playCompletionBell() async {
    if (!_enabled) return;
    // Two ascending haptic pulses mimic a bell chime
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.lightImpact();
  }

  /// Gentle tick — one per second during a hold countdown.
  Future<void> playHoldTick() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Celebration — session complete or milestone unlocked.
  Future<void> playCelebration() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Subtle whoosh — page transitions.
  Future<void> playTransitionWhoosh() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Rep complete — one rep finished.
  Future<void> playRepComplete() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Countdown tick — 3-2-1 countdown before exercise.
  Future<void> playCountdownTick() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Rest start — entering rest period between reps.
  Future<void> playRestStart() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Ready pulse — about to start next exercise.
  Future<void> playReadyPulse() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }
}
