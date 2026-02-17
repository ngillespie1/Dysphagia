import 'package:flutter/material.dart';

import '../../core/models/program_week.dart';
import '../../core/theme/premium_theme.dart';

/// Horizontal journey progress bar with waystones
/// Shows all weeks as connected dots with current position highlighted
class JourneyProgressBar extends StatelessWidget {
  final List<ProgramWeek> weeks;
  final int currentWeek;
  final double height;
  final ValueChanged<int>? onWeekTap;

  const JourneyProgressBar({
    super.key,
    required this.weeks,
    required this.currentWeek,
    this.height = 100,
    this.onWeekTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Waystones row
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _JourneyLinePainter(
                    weekCount: weeks.length,
                    currentWeek: currentWeek,
                    weeks: weeks,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(weeks.length, (index) {
                      final week = weeks[index];
                      return _Waystone(
                        week: week,
                        isCurrent: week.weekNumber == currentWeek,
                        onTap: week.status.isAccessible
                            ? () => onWeekTap?.call(week.weekNumber)
                            : null,
                      );
                    }),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Current position indicator
          _buildCurrentIndicator(),
        ],
      ),
    );
  }

  Widget _buildCurrentIndicator() {
    final currentWeekData = weeks.firstWhere(
      (w) => w.weekNumber == currentWeek,
      orElse: () => weeks.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: PremiumTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: PremiumTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Week $currentWeek: ${currentWeekData.title}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PremiumTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyLinePainter extends CustomPainter {
  final int weekCount;
  final int currentWeek;
  final List<ProgramWeek> weeks;

  _JourneyLinePainter({
    required this.weekCount,
    required this.currentWeek,
    required this.weeks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weekCount < 2) return;

    final spacing = size.width / (weekCount - 1);
    final centerY = size.height / 2;
    const stoneRadius = 16.0;

    // Draw background line
    final bgPaint = Paint()
      ..color = const Color(0xFFE5E5EA)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(stoneRadius, centerY),
      Offset(size.width - stoneRadius, centerY),
      bgPaint,
    );

    // Draw completed line
    if (currentWeek > 1) {
      final completedEnd = (currentWeek - 1) * spacing;
      final completedPaint = Paint()
        ..color = PremiumTheme.primary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(stoneRadius, centerY),
        Offset(completedEnd, centerY),
        completedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyLinePainter oldDelegate) {
    return oldDelegate.currentWeek != currentWeek;
  }
}

class _Waystone extends StatelessWidget {
  final ProgramWeek week;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _Waystone({
    required this.week,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = week.status;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stone
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isCurrent ? 36 : 28,
            height: isCurrent ? 36 : 28,
            decoration: BoxDecoration(
              color: _getBackgroundColor(status),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getBorderColor(status),
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
            child: Center(child: _buildContent(status)),
          ),

          const SizedBox(height: 4),

          // Week number
          Text(
            '${week.weekNumber}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent
                  ? PremiumTheme.primary
                  : status.isAccessible
                      ? const Color(0xFF8E8E93)
                      : const Color(0xFFC7C7CC),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(WeekStatus status) {
    switch (status) {
      case WeekStatus.completed:
        return PremiumTheme.primary;
      case WeekStatus.inProgress:
        return PremiumTheme.primaryLight;
      case WeekStatus.available:
        return Colors.white;
      case WeekStatus.locked:
        return const Color(0xFFF2F2F7);
    }
  }

  Color _getBorderColor(WeekStatus status) {
    if (isCurrent) return PremiumTheme.primary;
    switch (status) {
      case WeekStatus.completed:
        return PremiumTheme.primaryDark;
      case WeekStatus.inProgress:
        return PremiumTheme.primary;
      case WeekStatus.available:
        return const Color(0xFFD1D1D6);
      case WeekStatus.locked:
        return const Color(0xFFE5E5EA);
    }
  }

  Widget? _buildContent(WeekStatus status) {
    switch (status) {
      case WeekStatus.completed:
        return Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: isCurrent ? 18 : 14,
        );
      case WeekStatus.inProgress:
        return Text(
          '${(week.completionPercent * 100).round()}',
          style: TextStyle(
            fontSize: isCurrent ? 10 : 8,
            fontWeight: FontWeight.w700,
            color: PremiumTheme.primaryDark,
          ),
        );
      case WeekStatus.available:
        return null;
      case WeekStatus.locked:
        return Icon(
          Icons.lock_rounded,
          color: const Color(0xFFC7C7CC),
          size: isCurrent ? 14 : 10,
        );
    }
  }
}

/// Compact version for smaller spaces
class JourneyProgressBarCompact extends StatelessWidget {
  final int currentWeek;
  final int totalWeeks;
  final double progress;

  const JourneyProgressBarCompact({
    super.key,
    required this.currentWeek,
    required this.totalWeeks,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E5EA),
            valueColor: const AlwaysStoppedAnimation(PremiumTheme.primary),
          ),
        ),

        const SizedBox(height: 8),

        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Week $currentWeek of $totalWeeks',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PremiumTheme.primary,
              ),
            ),
            Text(
              '${(progress * 100).round()}% complete',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
