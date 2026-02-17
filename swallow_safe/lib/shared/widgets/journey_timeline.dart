import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/premium_theme.dart';
import '../../core/models/program_week.dart';

/// A curved journey path timeline showing 8 weeks of progress
class JourneyTimeline extends StatefulWidget {
  final List<ProgramWeek> weeks;
  final int currentWeek;
  final int? selectedWeek;
  final ValueChanged<int>? onWeekTap;
  final bool compact;

  const JourneyTimeline({
    super.key,
    required this.weeks,
    required this.currentWeek,
    this.selectedWeek,
    this.onWeekTap,
    this.compact = false,
  });

  @override
  State<JourneyTimeline> createState() => _JourneyTimelineState();
}

class _JourneyTimelineState extends State<JourneyTimeline>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pathAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pathAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.compact ? 140.0 : 200.0;
    final waymarkSize = widget.compact ? 36.0 : 44.0;

    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AnimatedBuilder(
          animation: _pathAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: _JourneyPathPainter(
                weeks: widget.weeks,
                currentWeek: widget.currentWeek,
                progress: _pathAnimation.value,
                compact: widget.compact,
              ),
              child: child,
            );
          },
          child: SizedBox(
            width: _calculateWidth(),
            child: Stack(
              children: [
                for (int i = 0; i < widget.weeks.length; i++)
                  _buildWaymark(i, waymarkSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateWidth() {
    // 8 weeks with spacing
    return 80.0 * widget.weeks.length + 48;
  }

  Widget _buildWaymark(int index, double size) {
    final week = widget.weeks[index];
    final position = _getWaymarkPosition(index);
    final isCurrent = week.weekNumber == widget.currentWeek;
    final isSelected = week.weekNumber == widget.selectedWeek;

    return Positioned(
      left: position.dx - size / 2,
      top: position.dy - size / 2,
      child: _AnimatedWaymark(
        week: week,
        isCurrent: isCurrent,
        isSelected: isSelected,
        size: size,
        delay: Duration(milliseconds: 100 * index),
        onTap: week.status.isAccessible
            ? () => widget.onWeekTap?.call(week.weekNumber)
            : null,
      ),
    );
  }

  Offset _getWaymarkPosition(int index) {
    // Create a serpentine/curved path
    final width = _calculateWidth();
    final horizontalSpacing = (width - 48) / (widget.weeks.length - 1);
    final x = 24.0 + index * horizontalSpacing;

    // Curve pattern: alternating up and down
    final amplitude = widget.compact ? 30.0 : 50.0;
    final baseY = widget.compact ? 70.0 : 100.0;
    
    // Use sine wave for smooth curve
    final y = baseY + amplitude * math.sin(index * math.pi / 2);

    return Offset(x, y);
  }
}

class _AnimatedWaymark extends StatefulWidget {
  final ProgramWeek week;
  final bool isCurrent;
  final bool isSelected;
  final double size;
  final Duration delay;
  final VoidCallback? onTap;

  const _AnimatedWaymark({
    required this.week,
    required this.isCurrent,
    required this.isSelected,
    required this.size,
    required this.delay,
    this.onTap,
  });

  @override
  State<_AnimatedWaymark> createState() => _AnimatedWaymarkState();
}

class _AnimatedWaymarkState extends State<_AnimatedWaymark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Week label
            Text(
              widget.week.shortLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: widget.isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: widget.isCurrent
                    ? PremiumTheme.primary
                    : widget.week.status.isAccessible
                        ? PremiumTheme.textSecondary
                        : PremiumTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            
            // Waymark circle
            _WaymarkCircle(
              status: widget.week.status,
              isSelected: widget.isSelected,
              isCurrent: widget.isCurrent,
              size: widget.size,
              completionPercent: widget.week.completionPercent,
            ),
            
            // Week title (below)
            if (widget.isCurrent || widget.isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.week.title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: PremiumTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WaymarkCircle extends StatelessWidget {
  final WeekStatus status;
  final bool isSelected;
  final bool isCurrent;
  final double size;
  final double completionPercent;

  const _WaymarkCircle({
    required this.status,
    required this.isSelected,
    required this.isCurrent,
    required this.size,
    required this.completionPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _backgroundColor,
        border: Border.all(
          color: _borderColor,
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
            : isSelected
                ? [
                    BoxShadow(
                      color: PremiumTheme.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
      ),
      child: _buildContent(),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case WeekStatus.completed:
        return PremiumTheme.primary;
      case WeekStatus.inProgress:
        return PremiumTheme.primaryLight;
      case WeekStatus.available:
        return PremiumTheme.surface;
      case WeekStatus.locked:
        return PremiumTheme.surfaceVariant;
    }
  }

  Color get _borderColor {
    if (isCurrent) return PremiumTheme.primary;
    switch (status) {
      case WeekStatus.completed:
        return PremiumTheme.primaryDark;
      case WeekStatus.inProgress:
        return PremiumTheme.primary;
      case WeekStatus.available:
        return PremiumTheme.textTertiary;
      case WeekStatus.locked:
        return PremiumTheme.textTertiary.withOpacity(0.5);
    }
  }

  Widget _buildContent() {
    switch (status) {
      case WeekStatus.completed:
        return const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 20,
        );
      case WeekStatus.inProgress:
        return _buildProgressIndicator();
      case WeekStatus.available:
        return Icon(
          Icons.circle,
          color: PremiumTheme.primary.withOpacity(0.3),
          size: 8,
        );
      case WeekStatus.locked:
        return Icon(
          Icons.lock_rounded,
          color: PremiumTheme.textTertiary,
          size: 16,
        );
    }
  }

  Widget _buildProgressIndicator() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size - 12,
          height: size - 12,
          child: CircularProgressIndicator(
            value: completionPercent,
            strokeWidth: 3,
            backgroundColor: PremiumTheme.primaryMuted,
            valueColor: const AlwaysStoppedAnimation(PremiumTheme.primary),
          ),
        ),
        Text(
          '${(completionPercent * 100).round()}%',
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: PremiumTheme.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _JourneyPathPainter extends CustomPainter {
  final List<ProgramWeek> weeks;
  final int currentWeek;
  final double progress;
  final bool compact;

  _JourneyPathPainter({
    required this.weeks,
    required this.currentWeek,
    required this.progress,
    required this.compact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weeks.isEmpty) return;

    final path = Path();
    final completedPath = Path();
    final points = <Offset>[];

    // Calculate waymark positions
    final horizontalSpacing = (size.width - 48) / (weeks.length - 1);
    final amplitude = compact ? 30.0 : 50.0;
    final baseY = compact ? 70.0 : 100.0;

    for (int i = 0; i < weeks.length; i++) {
      final x = 24.0 + i * horizontalSpacing;
      final y = baseY + amplitude * math.sin(i * math.pi / 2);
      points.add(Offset(x, y));
    }

    // Draw path through points with curves
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final controlPoint1 = Offset(
          current.dx + (next.dx - current.dx) / 2,
          current.dy,
        );
        final controlPoint2 = Offset(
          current.dx + (next.dx - current.dx) / 2,
          next.dy,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          next.dx,
          next.dy,
        );
      }
    }

    // Create animated path
    final pathMetrics = path.computeMetrics().first;
    final animatedPath = pathMetrics.extractPath(
      0,
      pathMetrics.length * progress,
    );

    // Draw background path (future)
    final bgPaint = Paint()
      ..color = PremiumTheme.textTertiary.withOpacity(0.2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, bgPaint);

    // Draw completed portion
    final completedProgress = (currentWeek - 1) / (weeks.length - 1);
    final completedLength = pathMetrics.length * completedProgress;
    final completedPathExtracted = pathMetrics.extractPath(0, completedLength);

    final completedPaint = Paint()
      ..color = PremiumTheme.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(completedPathExtracted, completedPaint);

    // Draw animated overlay
    final animatedPaint = Paint()
      ..color = PremiumTheme.primary.withOpacity(0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(animatedPath, animatedPaint);
  }

  @override
  bool shouldRepaint(covariant _JourneyPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentWeek != currentWeek;
  }
}
