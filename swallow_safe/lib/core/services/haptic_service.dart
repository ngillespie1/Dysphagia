import 'package:flutter/services.dart';

/// Service for haptic feedback
/// Provides physical vibration feedback for stroke patients with sensory loss
class HapticService {
  /// Light haptic feedback for UI interactions
  Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }
  
  /// Medium haptic feedback for selections
  Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }
  
  /// Heavy haptic feedback for exercise completion
  Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }
  
  /// Selection click feedback
  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }
  
  /// Success pattern - double vibration for exercise complete
  Future<void> successPattern() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
  
  /// Hold complete pattern - distinct feedback when hold gesture completes
  Future<void> holdComplete() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }
  
  /// Error/warning pattern
  Future<void> errorPattern() async {
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.vibrate();
  }
  
  /// Subtle feedback for scroll or drag
  Future<void> subtle() async {
    await HapticFeedback.selectionClick();
  }
}
