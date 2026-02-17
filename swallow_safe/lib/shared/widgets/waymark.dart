import 'package:flutter/material.dart';

import '../../core/theme/premium_theme.dart';
import '../../core/models/program_week.dart';

/// Waymark indicator for the journey timeline
class Waymark extends StatelessWidget {
  final ProgramWeek week;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback? onTap;
  final double size;

  const Waymark({
    super.key,
    required this.week,
    this.isSelected = false,
    this.isCurrent = false,
    this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final status = week.status;
    
    return Semantics(
      button: status.isAccessible,
      label: 'Week ${week.weekNumber}: ${week.title}${isCurrent ? ", current" : ""}${status == WeekStatus.completed ? ", completed" : ""}${status == WeekStatus.locked ? ", locked" : ""}',
      child: GestureDetector(
        onTap: status.isAccessible ? onTap : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Week label
            Text(
              week.shortLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent
                  ? PremiumTheme.primary
                  : status.isAccessible
                      ? PremiumTheme.textSecondary
                      : PremiumTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          
          // Waymark circle
          _WaymarkCircle(
            status: status,
            isSelected: isSelected,
            isCurrent: isCurrent,
            size: size,
            completionPercent: week.completionPercent,
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
