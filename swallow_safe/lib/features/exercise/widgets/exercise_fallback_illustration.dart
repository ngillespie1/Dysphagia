import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/premium_theme.dart';

/// Beautiful illustrated fallback when a video can't load or isn't cached.
///
/// Shows a calming illustration with the exercise name and a gentle
/// "you can still follow along" message, so the patient never feels stuck.
class ExerciseFallbackIllustration extends StatefulWidget {
  final String exerciseName;
  final String instructions;
  final VoidCallback? onRetry;

  const ExerciseFallbackIllustration({
    super.key,
    required this.exerciseName,
    required this.instructions,
    this.onRetry,
  });

  @override
  State<ExerciseFallbackIllustration> createState() =>
      _ExerciseFallbackIllustrationState();
}

class _ExerciseFallbackIllustrationState
    extends State<ExerciseFallbackIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PremiumTheme.primaryDark,
            const Color(0xFF1A3A2F),
            Colors.black87,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // Animated breathing circle illustration
              AnimatedBuilder(
                animation: _breatheController,
                builder: (context, child) {
                  final scale = 1.0 + 0.08 * _breatheController.value;
                  final opacity = 0.3 + 0.4 * _breatheController.value;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: 180 * scale,
                        height: 180 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PremiumTheme.primaryLight
                                .withOpacity(opacity * 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      // Middle ring
                      Container(
                        width: 140 * scale,
                        height: 140 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: PremiumTheme.primary.withOpacity(0.08),
                          border: Border.all(
                            color: PremiumTheme.primaryLight
                                .withOpacity(opacity * 0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // Inner circle with icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              PremiumTheme.primaryLight.withOpacity(0.3),
                              PremiumTheme.primary.withOpacity(0.2),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.self_improvement_rounded,
                          size: 48,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // Exercise name
              Text(
                widget.exerciseName,
                style: PremiumTheme.headlineLarge.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Friendly offline message
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: PremiumTheme.accent.withOpacity(0.8),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Video unavailable — follow the steps below',
                        style: PremiumTheme.bodySmall.copyWith(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Written instructions as fallback
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered_rounded,
                          color: PremiumTheme.primaryLight,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How to do this exercise',
                          style: PremiumTheme.labelLarge.copyWith(
                            color: PremiumTheme.primaryLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.instructions,
                      style: PremiumTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        height: 1.7,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Retry button if callback provided
              if (widget.onRetry != null)
                TextButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try loading video'),
                  style: TextButton.styleFrom(
                    foregroundColor: PremiumTheme.accent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
