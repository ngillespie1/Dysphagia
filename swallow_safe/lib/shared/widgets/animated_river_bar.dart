import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/premium_theme.dart';

/// Horizontal animated river progress bar
/// Shows flowing water effect with wave animation
class AnimatedRiverBar extends StatefulWidget {
  final double progress;
  final int currentStep;
  final int totalSteps;
  final double height;
  final ValueChanged<int>? onStepTap;

  const AnimatedRiverBar({
    super.key,
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
    this.height = 80,
    this.onStepTap,
  });

  @override
  State<AnimatedRiverBar> createState() => _AnimatedRiverBarState();
}

class _AnimatedRiverBarState extends State<AnimatedRiverBar>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: Listenable.merge([_waveController, _particleController]),
        builder: (context, child) {
          return CustomPaint(
            painter: _RiverBarPainter(
              progress: widget.progress,
              currentStep: widget.currentStep,
              totalSteps: widget.totalSteps,
              wavePhase: _waveController.value,
              particlePhase: _particleController.value,
            ),
            child: _buildStepMarkers(),
          );
        },
      ),
    );
  }

  Widget _buildStepMarkers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.totalSteps, (index) {
        final step = index + 1;
        final isComplete = step < widget.currentStep;
        final isCurrent = step == widget.currentStep;
        final isFuture = step > widget.currentStep;

        return GestureDetector(
          onTap: !isFuture ? () => widget.onStepTap?.call(step) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Step marker
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isCurrent ? 36 : 28,
                height: isCurrent ? 36 : 28,
                decoration: BoxDecoration(
                  color: isComplete
                      ? PremiumTheme.primary
                      : isCurrent
                          ? PremiumTheme.primaryLight
                          : PremiumTheme.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFuture
                        ? PremiumTheme.textMuted
                        : PremiumTheme.primary,
                    width: isCurrent ? 3 : 2,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: PremiumTheme.primary.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isComplete
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : Text(
                          '$step',
                          style: PremiumTheme.labelMedium.copyWith(
                            color: isFuture
                                ? PremiumTheme.textTertiary
                                : isCurrent
                                    ? PremiumTheme.primary
                                    : PremiumTheme.textSecondary,
                            fontWeight: isCurrent ? FontWeight.w700 : null,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 6),

              // Step label
              Text(
                'W$step',
                style: PremiumTheme.labelSmall.copyWith(
                  color: isCurrent
                      ? PremiumTheme.primary
                      : isFuture
                          ? PremiumTheme.textTertiary
                          : PremiumTheme.textSecondary,
                  fontWeight: isCurrent ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _RiverBarPainter extends CustomPainter {
  final double progress;
  final int currentStep;
  final int totalSteps;
  final double wavePhase;
  final double particlePhase;

  _RiverBarPainter({
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
    required this.wavePhase,
    required this.particlePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2 - 8; // Account for labels
    final riverWidth = size.width - 40;
    final riverStartX = 20.0;
    final riverHeight = 8.0;

    // Draw river bed (background)
    final bedPaint = Paint()
      ..color = const Color(0xFFE8F4F4)
      ..style = PaintingStyle.fill;

    final bedPath = Path();
    bedPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(riverStartX, centerY - riverHeight / 2, riverWidth, riverHeight),
      const Radius.circular(4),
    ));
    canvas.drawPath(bedPath, bedPaint);

    // Draw flowing water (progress)
    if (progress > 0) {
      final waterWidth = riverWidth * progress.clamp(0.0, 1.0);

      // Create water gradient with wave effect
      final waterPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            PremiumTheme.primary,
            PremiumTheme.primaryLight,
          ],
        ).createShader(Rect.fromLTWH(riverStartX, 0, waterWidth, riverHeight));

      final waterPath = Path();
      waterPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(riverStartX, centerY - riverHeight / 2, waterWidth, riverHeight),
        const Radius.circular(4),
      ));
      canvas.drawPath(waterPath, waterPaint);

      // Draw wave highlights
      _drawWaves(canvas, riverStartX, centerY, waterWidth, riverHeight);

      // Draw floating particles
      _drawParticles(canvas, riverStartX, centerY, waterWidth, riverHeight);
    }
  }

  void _drawWaves(Canvas canvas, double startX, double centerY, double width, double height) {
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final wavePath = Path();
    const waveCount = 3;
    final waveLength = width / waveCount;

    wavePath.moveTo(startX, centerY);
    for (int i = 0; i < waveCount; i++) {
      final x = startX + i * waveLength;
      final phase = wavePhase * 2 * math.pi + i * math.pi / 2;
      final amplitude = 2.0;

      wavePath.quadraticBezierTo(
        x + waveLength * 0.25,
        centerY + math.sin(phase) * amplitude,
        x + waveLength * 0.5,
        centerY,
      );
      wavePath.quadraticBezierTo(
        x + waveLength * 0.75,
        centerY - math.sin(phase) * amplitude,
        x + waveLength,
        centerY,
      );
    }

    canvas.drawPath(wavePath, wavePaint);
  }

  void _drawParticles(Canvas canvas, double startX, double centerY, double width, double height) {
    final random = math.Random(42);

    for (int i = 0; i < 8; i++) {
      final particleProgress = (particlePhase + i * 0.125) % 1.0;
      final x = startX + width * particleProgress;
      final y = centerY + (random.nextDouble() - 0.5) * height * 0.5;
      final opacity = math.sin(particleProgress * math.pi) * 0.5;

      final particlePaint = Paint()
        ..color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 1.5 + random.nextDouble(), particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RiverBarPainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.particlePhase != particlePhase ||
        oldDelegate.progress != progress;
  }
}

/// Compact river bar for tight spaces
class CompactRiverBar extends StatefulWidget {
  final double progress;
  final double height;

  const CompactRiverBar({
    super.key,
    required this.progress,
    this.height = 6,
  });

  @override
  State<CompactRiverBar> createState() => _CompactRiverBarState();
}

class _CompactRiverBarState extends State<CompactRiverBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.height / 2),
        child: Stack(
          children: [
            // Background
            Container(
              color: const Color(0xFFE8F4F4),
            ),

            // Progress
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: PremiumTheme.primaryGradient,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widget.progress.clamp(0.0, 1.0),
                child: Container(),
              ),
            ),

            // Shimmer effect
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Positioned(
                  left: -100 + (_shimmerController.value * 200) * widget.progress,
                  top: 0,
                  bottom: 0,
                  width: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
