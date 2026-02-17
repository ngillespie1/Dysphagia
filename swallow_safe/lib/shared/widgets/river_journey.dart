import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/program_week.dart';
import '../../core/theme/premium_theme.dart';

/// Flowing river journey timeline with animated water effects
class RiverJourney extends StatefulWidget {
  final List<ProgramWeek> weeks;
  final int currentWeek;
  final int? selectedWeek;
  final ValueChanged<int>? onWeekTap;

  const RiverJourney({
    super.key,
    required this.weeks,
    required this.currentWeek,
    this.selectedWeek,
    this.onWeekTap,
  });

  @override
  State<RiverJourney> createState() => _RiverJourneyState();
}

class _RiverJourneyState extends State<RiverJourney>
    with SingleTickerProviderStateMixin {
  late AnimationController _flowController;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flowController,
      builder: (context, child) {
        return CustomPaint(
          painter: _RiverPainter(
            weeks: widget.weeks,
            currentWeek: widget.currentWeek,
            flowProgress: _flowController.value,
          ),
          child: child,
        );
      },
      child: _buildWeekMarkers(),
    );
  }

  Widget _buildWeekMarkers() {
    return Column(
      children: [
        for (int i = 0; i < widget.weeks.length; i++) ...[
          _WeekStone(
            week: widget.weeks[i],
            isCurrent: widget.weeks[i].weekNumber == widget.currentWeek,
            isSelected: widget.weeks[i].weekNumber == widget.selectedWeek,
            isLeft: i % 2 == 0,
            onTap: widget.weeks[i].status.isAccessible
                ? () => widget.onWeekTap?.call(widget.weeks[i].weekNumber)
                : null,
          ),
          if (i < widget.weeks.length - 1) const SizedBox(height: 40),
        ],
      ],
    );
  }
}

class _RiverPainter extends CustomPainter {
  final List<ProgramWeek> weeks;
  final int currentWeek;
  final double flowProgress;

  _RiverPainter({
    required this.weeks,
    required this.currentWeek,
    required this.flowProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weeks.isEmpty) return;

    const riverWidth = 40.0;
    final centerX = size.width / 2;
    final sectionHeight = (size.height - 80) / (weeks.length - 1);

    // Create river path
    final riverPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < weeks.length; i++) {
      final y = 40.0 + i * sectionHeight;
      // Alternate left and right for serpentine effect
      final xOffset = (i % 2 == 0) ? -60.0 : 60.0;
      points.add(Offset(centerX + xOffset, y));
    }

    // Draw river path with curves
    if (points.isNotEmpty) {
      riverPath.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final midY = (current.dy + next.dy) / 2;

        // Create smooth S-curves
        riverPath.cubicTo(
          current.dx, midY,
          next.dx, midY,
          next.dx, next.dy,
        );
      }
    }

    // Draw river background (future path)
    final futurePaint = Paint()
      ..color = const Color(0xFFE8F6F4)
      ..strokeWidth = riverWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(riverPath, futurePaint);

    // Draw completed portion of river
    final completedIndex = currentWeek - 1;
    if (completedIndex > 0 && points.length > 1) {
      final completedPath = Path();
      completedPath.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < completedIndex && i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final midY = (current.dy + next.dy) / 2;

        completedPath.cubicTo(
          current.dx, midY,
          next.dx, midY,
          next.dx, next.dy,
        );
      }

      // Gradient for completed river
      final completedPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PremiumTheme.primary,
            PremiumTheme.primaryLight,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeWidth = riverWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(completedPath, completedPaint);
    }

    // Draw flowing water particles
    _drawWaterParticles(canvas, size, points, riverWidth);

    // Draw ripples around current position
    if (currentWeek > 0 && currentWeek <= points.length) {
      final currentPos = points[currentWeek - 1];
      _drawRipples(canvas, currentPos);
    }
  }

  void _drawWaterParticles(
    Canvas canvas,
    Size size,
    List<Offset> points,
    double riverWidth,
  ) {
    final random = math.Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 20; i++) {
      // Particle position based on flow progress
      final baseProgress = (flowProgress + i * 0.05) % 1.0;
      final particleIndex = (baseProgress * (points.length - 1)).floor();

      if (particleIndex >= points.length - 1) continue;

      final p1 = points[particleIndex];
      final p2 = points[particleIndex + 1];
      final localProgress = (baseProgress * (points.length - 1)) % 1.0;

      final x = p1.dx + (p2.dx - p1.dx) * localProgress;
      final y = p1.dy + (p2.dy - p1.dy) * localProgress;

      // Add some randomness to position
      final offsetX = (random.nextDouble() - 0.5) * (riverWidth * 0.6);
      
      final particlePaint = Paint()
        ..color = Colors.white.withOpacity(0.4 * (1 - localProgress))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x + offsetX, y),
        2 + random.nextDouble() * 2,
        particlePaint,
      );
    }
  }

  void _drawRipples(Canvas canvas, Offset center) {
    // Animated ripple rings
    for (int i = 0; i < 3; i++) {
      final rippleProgress = (flowProgress + i * 0.33) % 1.0;
      final radius = 20 + rippleProgress * 30;
      final opacity = (1 - rippleProgress) * 0.3;

      final ripplePaint = Paint()
        ..color = PremiumTheme.primary.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, ripplePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RiverPainter oldDelegate) {
    return oldDelegate.flowProgress != flowProgress ||
        oldDelegate.currentWeek != currentWeek;
  }
}

/// Week stepping stone marker
class _WeekStone extends StatelessWidget {
  final ProgramWeek week;
  final bool isCurrent;
  final bool isSelected;
  final bool isLeft;
  final VoidCallback? onTap;

  const _WeekStone({
    required this.week,
    required this.isCurrent,
    required this.isSelected,
    required this.isLeft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isLeft ? 20 : 100,
        right: isLeft ? 100 : 20,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment:
              isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (!isLeft) _buildContent(),
            _buildStone(),
            if (isLeft) _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildStone() {
    final status = week.status;
    
    Color bgColor;
    Color borderColor;
    Widget? icon;

    switch (status) {
      case WeekStatus.completed:
        bgColor = PremiumTheme.primary;
        borderColor = PremiumTheme.primaryDark;
        icon = const Icon(Icons.check_rounded, color: Colors.white, size: 24);
        break;
      case WeekStatus.inProgress:
        bgColor = PremiumTheme.primaryLight;
        borderColor = PremiumTheme.primary;
        icon = Text(
          '${(week.completionPercent * 100).round()}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: PremiumTheme.primaryDark,
          ),
        );
        break;
      case WeekStatus.available:
        bgColor = Colors.white;
        borderColor = PremiumTheme.textTertiary;
        icon = Text(
          '${week.weekNumber}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: PremiumTheme.textSecondary,
          ),
        );
        break;
      case WeekStatus.locked:
        bgColor = const Color(0xFFF2F2F7);
        borderColor = const Color(0xFFE5E5EA);
        icon = const Icon(Icons.lock_rounded, color: Color(0xFFC7C7CC), size: 20);
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: isCurrent ? 3 : 2),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: PremiumTheme.primary.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(child: icon),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          left: isLeft ? 16 : 0,
          right: isLeft ? 0 : 16,
        ),
        child: Column(
          crossAxisAlignment:
              isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              week.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCurrent ? PremiumTheme.primary : const Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              week.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: week.status.isAccessible
                    ? const Color(0xFF000000)
                    : const Color(0xFFC7C7CC),
              ),
              textAlign: isLeft ? TextAlign.left : TextAlign.right,
            ),
            if (isCurrent) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PremiumTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'YOU ARE HERE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PremiumTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
