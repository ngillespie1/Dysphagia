import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/premium_theme.dart';

/// The type of illustration to render.
enum EmptyStateType {
  journey,
  foodDiary,
  checkIn,
}

/// A warm, illustrated empty-state widget used throughout the app.
///
/// Each [EmptyStateType] draws a unique custom illustration that matches the
/// Fresh Mint palette. The widget fades and slides in on first build.
class IllustratedEmptyState extends StatefulWidget {
  final EmptyStateType type;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const IllustratedEmptyState({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<IllustratedEmptyState> createState() => _IllustratedEmptyStateState();
}

class _IllustratedEmptyStateState extends State<IllustratedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideIn,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration circle
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : _bgColorForType(widget.type),
                ),
                child: CustomPaint(
                  painter: _EmptyStateIllustrationPainter(
                    type: widget.type,
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                widget.title,
                style: PremiumTheme.headlineLarge.copyWith(
                  color: isDark ? Colors.white : PremiumTheme.textPrimary,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Subtitle
              SizedBox(
                width: 280,
                child: Text(
                  widget.subtitle,
                  style: PremiumTheme.bodyMedium.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : PremiumTheme.textTertiary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Optional CTA button
              if (widget.actionLabel != null && widget.onAction != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: widget.onAction,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(widget.actionLabel!),
                  style: FilledButton.styleFrom(
                    backgroundColor: PremiumTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: PremiumTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _bgColorForType(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.journey:
        return PremiumTheme.primarySoft;
      case EmptyStateType.foodDiary:
        return PremiumTheme.warningLight;
      case EmptyStateType.checkIn:
        return PremiumTheme.infoLight;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// ILLUSTRATION PAINTER
// ═══════════════════════════════════════════════════════════════════

class _EmptyStateIllustrationPainter extends CustomPainter {
  final EmptyStateType type;
  final bool isDark;

  _EmptyStateIllustrationPainter({required this.type, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case EmptyStateType.journey:
        _paintJourney(canvas, size);
        break;
      case EmptyStateType.foodDiary:
        _paintFoodDiary(canvas, size);
        break;
      case EmptyStateType.checkIn:
        _paintCheckIn(canvas, size);
        break;
    }
  }

  /// Journey illustration — a winding path with milestone dots
  void _paintJourney(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Winding path
    final pathPaint = Paint()
      ..color = isDark
          ? PremiumTheme.primary.withOpacity(0.35)
          : PremiumTheme.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(cx - 35, cy + 38);
    path.cubicTo(
      cx - 40, cy + 10,
      cx + 40, cy + 10,
      cx + 35, cy - 10,
    );
    path.cubicTo(
      cx + 30, cy - 30,
      cx - 45, cy - 25,
      cx - 30, cy - 42,
    );
    canvas.drawPath(path, pathPaint);

    // Dashed continuation hint at the end
    final dashPaint = Paint()
      ..color = (isDark
              ? PremiumTheme.primary
              : PremiumTheme.primaryLight)
          .withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(cx - 25 + i * 8, cy - 48 - i * 4),
        1.8,
        dashPaint,
      );
    }

    // Milestone dots along the path
    final dotColors = [
      PremiumTheme.primary,
      PremiumTheme.accent,
      PremiumTheme.success,
    ];
    final dotPositions = [
      Offset(cx - 35, cy + 38),
      Offset(cx + 35, cy - 10),
      Offset(cx - 30, cy - 42),
    ];
    for (int i = 0; i < dotPositions.length; i++) {
      // Glow
      canvas.drawCircle(
        dotPositions[i],
        10,
        Paint()..color = dotColors[i].withOpacity(0.15),
      );
      // Dot
      canvas.drawCircle(
        dotPositions[i],
        5.5,
        Paint()..color = dotColors[i],
      );
      // Inner highlight
      canvas.drawCircle(
        dotPositions[i] + const Offset(-1.5, -1.5),
        1.8,
        Paint()..color = Colors.white.withOpacity(0.6),
      );
    }

    // Star at destination
    _drawStar(canvas, Offset(cx + 2, cy - 58), 7, PremiumTheme.premium);
  }

  /// Food diary illustration — a plate with utensils
  void _paintFoodDiary(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Plate — large circle
    final platePaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.08) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy + 2), 42, platePaint);

    // Plate rim
    final rimPaint = Paint()
      ..color = isDark
          ? PremiumTheme.textMuted.withOpacity(0.3)
          : PremiumTheme.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(cx, cy + 2), 42, rimPaint);

    // Inner circle on plate
    canvas.drawCircle(
      Offset(cx, cy + 2),
      28,
      Paint()
        ..color = isDark
            ? Colors.white.withOpacity(0.03)
            : PremiumTheme.bgWarm.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );

    // Fork (left)
    final utensilPaint = Paint()
      ..color = isDark
          ? PremiumTheme.textMuted.withOpacity(0.5)
          : PremiumTheme.textTertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // Fork handle
    canvas.drawLine(
      Offset(cx - 56, cy - 20),
      Offset(cx - 56, cy + 35),
      utensilPaint,
    );
    // Fork tines
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(cx - 56 + i * 4, cy - 20),
        Offset(cx - 56 + i * 4, cy - 10),
        utensilPaint,
      );
    }

    // Knife (right)
    canvas.drawLine(
      Offset(cx + 56, cy - 20),
      Offset(cx + 56, cy + 35),
      utensilPaint,
    );
    // Knife blade edge
    final bladePath = Path();
    bladePath.moveTo(cx + 56, cy - 20);
    bladePath.quadraticBezierTo(cx + 62, cy - 8, cx + 56, cy + 5);
    canvas.drawPath(bladePath, utensilPaint);

    // Friendly food emoji placeholder — small shapes on plate
    // Small circle (pea)
    canvas.drawCircle(
      Offset(cx - 8, cy - 2),
      4,
      Paint()..color = PremiumTheme.success.withOpacity(0.6),
    );
    canvas.drawCircle(
      Offset(cx + 5, cy + 6),
      3.5,
      Paint()..color = PremiumTheme.warning.withOpacity(0.6),
    );
    canvas.drawCircle(
      Offset(cx + 10, cy - 6),
      5,
      Paint()..color = PremiumTheme.accent.withOpacity(0.5),
    );

    // Napkin fold (decorative line under plate)
    final napkinPaint = Paint()
      ..color = isDark
          ? PremiumTheme.primary.withOpacity(0.2)
          : PremiumTheme.primaryLight.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final napkinPath = Path();
    napkinPath.moveTo(cx - 30, cy + 50);
    napkinPath.quadraticBezierTo(cx, cy + 56, cx + 30, cy + 50);
    canvas.drawPath(napkinPath, napkinPaint);
  }

  /// Check-in illustration — a clipboard with a heart
  void _paintCheckIn(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Clipboard body
    final clipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 58, height: 70),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      clipRect,
      Paint()
        ..color = isDark ? Colors.white.withOpacity(0.08) : Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      clipRect,
      Paint()
        ..color = isDark
            ? PremiumTheme.textMuted.withOpacity(0.3)
            : PremiumTheme.surfaceVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Clip at top
    final clipTopRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 28), width: 28, height: 10),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      clipTopRect,
      Paint()
        ..color = isDark
            ? PremiumTheme.primary.withOpacity(0.5)
            : PremiumTheme.primary
        ..style = PaintingStyle.fill,
    );

    // Lines on clipboard
    final linePaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.07)
          : PremiumTheme.surfaceVariant.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final y = cy - 8 + i * 14.0;
      canvas.drawLine(
        Offset(cx - 18, y),
        Offset(cx + 18, y),
        linePaint,
      );
    }

    // Checkmark on first line
    final checkPaint = Paint()
      ..color = PremiumTheme.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 18, cy - 8),
      Offset(cx - 13, cy - 4),
      checkPaint,
    );
    canvas.drawLine(
      Offset(cx - 13, cy - 4),
      Offset(cx - 6, cy - 14),
      checkPaint,
    );

    // Heart at bottom
    _drawHeart(canvas, Offset(cx, cy + 30), 10, PremiumTheme.accent);

    // Small sparkles
    _drawSparkle(canvas, Offset(cx + 34, cy - 20), 4,
        PremiumTheme.premium.withOpacity(0.6));
    _drawSparkle(canvas, Offset(cx - 30, cy + 18), 3,
        PremiumTheme.primary.withOpacity(0.5));
  }

  // ─── Helpers ───

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;
      final outerPoint = Offset(
        center.dx + radius * math.cos(outerAngle),
        center.dy + radius * math.sin(outerAngle),
      );
      final innerPoint = Offset(
        center.dx + radius * 0.4 * math.cos(innerAngle),
        center.dy + radius * 0.4 * math.sin(innerAngle),
      );
      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color.withOpacity(0.7);
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.4);
    path.cubicTo(
      center.dx - size, center.dy - size * 0.3,
      center.dx - size * 0.5, center.dy - size,
      center.dx, center.dy - size * 0.35,
    );
    path.cubicTo(
      center.dx + size * 0.5, center.dy - size,
      center.dx + size, center.dy - size * 0.3,
      center.dx, center.dy + size * 0.4,
    );
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(
      Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyStateIllustrationPainter old) =>
      old.type != type || old.isDark != isDark;
}
