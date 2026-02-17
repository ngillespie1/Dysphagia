import 'package:flutter/material.dart';

import '../../core/constants/dimensions.dart';
import '../../core/theme/premium_theme.dart';

/// Week calendar showing 7 days with completion rings
/// PreHab-inspired progress visualization
class WeekCalendar extends StatelessWidget {
  final List<DayProgress> days;
  final int? selectedDayIndex;
  final ValueChanged<int>? onDayTap;

  const WeekCalendar({
    super.key,
    required this.days,
    this.selectedDayIndex,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.paddingCard,
      ),
      decoration: BoxDecoration(
        color: PremiumTheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: PremiumTheme.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(days.length, (index) {
          final day = days[index];
          final isSelected = selectedDayIndex == index;
          
          return GestureDetector(
            onTap: onDayTap != null ? () => onDayTap!(index) : null,
            child: _DayItem(
              day: day,
              isSelected: isSelected,
            ),
          );
        }),
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final DayProgress day;
  final bool isSelected;

  const _DayItem({
    required this.day,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Day label
        Text(
          day.dayLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: day.isToday
                ? PremiumTheme.accent
                : PremiumTheme.textTertiary,
            fontWeight: day.isToday ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        
        // Progress ring
        _DayRing(
          progress: day.progress,
          isSelected: isSelected,
          isToday: day.isToday,
        ),
      ],
    );
  }
}

class _DayRing extends StatelessWidget {
  final double progress;
  final bool isSelected;
  final bool isToday;

  const _DayRing({
    required this.progress,
    required this.isSelected,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final size = AppDimensions.weekDayRingSize;
    const strokeWidth = 3.0;
    
    Color ringColor;
    Color bgColor;
    
    if (progress >= 1.0) {
      ringColor = PremiumTheme.accent;
      bgColor = PremiumTheme.accent;
    } else if (progress > 0) {
      ringColor = PremiumTheme.accent;
      bgColor = PremiumTheme.progressRingBackground;
    } else {
      ringColor = PremiumTheme.progressRingBackground;
      bgColor = PremiumTheme.progressRingBackground;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: PremiumTheme.accent, width: 2)
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size - (isSelected ? 4 : 0),
            height: size - (isSelected ? 4 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: progress >= 1.0 ? bgColor : Colors.transparent,
              border: Border.all(
                color: bgColor,
                width: strokeWidth,
              ),
            ),
          ),
          
          // Progress arc (only if partial)
          if (progress > 0 && progress < 1.0)
            SizedBox(
              width: size - (isSelected ? 4 : 0),
              height: size - (isSelected ? 4 : 0),
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(ringColor),
              ),
            ),
          
          // Check mark or today indicator
          if (progress >= 1.0)
            const Icon(
              Icons.check_rounded,
              size: 18,
              color: Colors.white,
            )
          else if (isToday)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTheme.accent,
              ),
            ),
        ],
      ),
    );
  }
}

/// Data model for a day's progress
class DayProgress {
  final String dayLabel; // e.g., "M", "T", "W"
  final double progress; // 0.0 to 1.0
  final bool isToday;
  final DateTime date;

  const DayProgress({
    required this.dayLabel,
    required this.progress,
    this.isToday = false,
    required this.date,
  });

  factory DayProgress.fromDate(DateTime date, double progress) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayLabel = labels[date.weekday - 1];

    return DayProgress(
      dayLabel: dayLabel,
      progress: progress,
      isToday: isToday,
      date: date,
    );
  }
}

/// Creates a week of DayProgress objects
List<DayProgress> createWeekProgress(Map<DateTime, double> completions) {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  
  return List.generate(7, (index) {
    final date = monday.add(Duration(days: index));
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final progress = completions[normalizedDate] ?? 0.0;
    return DayProgress.fromDate(normalizedDate, progress);
  });
}
