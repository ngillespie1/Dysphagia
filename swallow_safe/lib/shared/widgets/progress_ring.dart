import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/dimensions.dart';
import '../../core/theme/premium_theme.dart';

/// Animated circular progress ring - PreHab style
/// Shows completion percentage with smooth animation
class ProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;
  final bool showPercentage;
  final Duration animationDuration;
  final Curve animationCurve;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = AppDimensions.progressRingSizeLarge,
    this.strokeWidth = AppDimensions.progressRingStrokeLarge,
    this.progressColor,
    this.backgroundColor,
    this.child,
    this.showPercentage = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _setupAnimation();
    _controller.forward();
  }

  void _setupAnimation() {
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _progressAnimation.value;
      _setupAnimation();
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final percentage = (_progressAnimation.value * 100).round();
        
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: widget.backgroundColor ?? PremiumTheme.progressRingBackground,
                ),
              ),
              // Progress ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _progressAnimation.value,
                  strokeWidth: widget.strokeWidth,
                  color: widget.progressColor ?? PremiumTheme.progressRing,
                ),
              ),
              // Center content
              if (widget.child != null)
                widget.child!
              else if (widget.showPercentage)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: PremiumTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.size > AppDimensions.progressRingSizeMedium)
                      Text(
                        'complete',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PremiumTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw arc from top (-90 degrees) clockwise
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }
}

/// Small progress ring for inline use (e.g., in lists)
class ProgressRingSmall extends StatelessWidget {
  final double progress;
  final Color? color;

  const ProgressRingSmall({
    super.key,
    required this.progress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ProgressRing(
      progress: progress,
      size: AppDimensions.progressRingSizeSmall,
      strokeWidth: AppDimensions.progressRingStrokeSmall,
      progressColor: color,
      showPercentage: false,
      child: Icon(
        progress >= 1.0 ? Icons.check_rounded : null,
        size: 20,
        color: color ?? PremiumTheme.progressRing,
      ),
    );
  }
}
