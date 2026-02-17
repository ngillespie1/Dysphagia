import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/daily_progress.dart';
import '../../core/theme/premium_theme.dart';
import 'glass_card.dart';

/// Weekly progress calendar with river-style connections
/// Swipeable to navigate between weeks
class DailyProgressCalendar extends StatefulWidget {
  final Map<String, DailyProgress> progressData;
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onWeekChanged;

  const DailyProgressCalendar({
    super.key,
    required this.progressData,
    required this.selectedDate,
    this.onDateSelected,
    this.onWeekChanged,
  });

  @override
  State<DailyProgressCalendar> createState() => _DailyProgressCalendarState();
}

class _DailyProgressCalendarState extends State<DailyProgressCalendar> {
  late PageController _pageController;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getWeekStart(widget.selectedDate);
    _pageController = PageController(initialPage: 100);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week navigation header
        _buildHeader(),

        const SizedBox(height: 12),

        // Days row with swipe
        SizedBox(
          height: 90,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              final weekOffset = page - 100;
              setState(() {
                _currentWeekStart = _getWeekStart(DateTime.now())
                    .add(Duration(days: weekOffset * 7));
              });
              widget.onWeekChanged?.call(_currentWeekStart);
            },
            itemBuilder: (context, pageIndex) {
              final weekOffset = pageIndex - 100;
              final weekStart = _getWeekStart(DateTime.now())
                  .add(Duration(days: weekOffset * 7));
              return _buildWeekDays(weekStart);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    final monthFormat = _formatMonth(_currentWeekStart, weekEnd);

    return Row(
      children: [
        // Previous week button
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: PremiumTheme.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: PremiumTheme.primary,
              size: 20,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Date range
        Expanded(
          child: Text(
            monthFormat,
            style: PremiumTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(width: 12),

        // Next week button (disabled for future)
        GestureDetector(
          onTap: _canGoNext()
              ? () {
                  HapticFeedback.selectionClick();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                }
              : null,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _canGoNext()
                  ? PremiumTheme.primarySoft
                  : PremiumTheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: _canGoNext()
                  ? PremiumTheme.primary
                  : PremiumTheme.textTertiary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  bool _canGoNext() {
    final nextWeekStart = _currentWeekStart.add(const Duration(days: 7));
    return nextWeekStart.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  String _formatMonth(DateTime start, DateTime end) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    if (start.month == end.month) {
      return '${months[start.month - 1]} ${start.day}-${end.day}';
    } else {
      return '${months[start.month - 1]} ${start.day} - ${months[end.month - 1]} ${end.day}';
    }
  }

  Widget _buildWeekDays(DateTime weekStart) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final date = weekStart.add(Duration(days: index));
        final dateKey = _dateToKey(date);
        final progress = widget.progressData[dateKey];
        final isToday = date.isAtSameMomentAs(today);
        final isFuture = date.isAfter(today);
        final isSelected = _isSameDay(date, widget.selectedDate);

        return _DayCell(
          date: date,
          progress: progress,
          isToday: isToday,
          isFuture: isFuture,
          isSelected: isSelected,
          onTap: isFuture
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  widget.onDateSelected?.call(date);
                },
        );
      }),
    );
  }

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DayCell extends StatefulWidget {
  final DateTime date;
  final DailyProgress? progress;
  final bool isToday;
  final bool isFuture;
  final bool isSelected;
  final VoidCallback? onTap;

  const _DayCell({
    required this.date,
    this.progress,
    required this.isToday,
    required this.isFuture,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Only pulse today's dot
    if (widget.isToday) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPracticed = widget.progress?.hasPracticed ?? false;
    final mood = widget.progress?.mood;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day label
            Text(
              _weekdays[widget.date.weekday - 1],
              style: PremiumTheme.labelSmall.copyWith(
                color: widget.isToday
                    ? PremiumTheme.primary
                    : PremiumTheme.textTertiary,
              ),
            ),

            const SizedBox(height: 6),

            // Day circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                shape: BoxShape.circle,
                border: widget.isToday
                    ? Border.all(color: PremiumTheme.primary, width: 2)
                    : widget.isSelected
                        ? Border.all(
                            color: PremiumTheme.primaryLight, width: 2)
                        : null,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: PremiumTheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: hasPracticed && mood != null
                    ? Text(mood.emoji, style: const TextStyle(fontSize: 18))
                    : hasPracticed
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : Text(
                            '${widget.date.day}',
                            style: PremiumTheme.labelMedium.copyWith(
                              color: _getTextColor(),
                              fontWeight:
                                  widget.isToday ? FontWeight.w700 : null,
                            ),
                          ),
              ),
            ),

            const SizedBox(height: 4),

            // Activity indicator dot — pulses for today
            widget.isToday
                ? AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: hasPracticed
                            ? PremiumTheme.success
                            : PremiumTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: PremiumTheme.primary.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: hasPracticed
                          ? PremiumTheme.success
                          : widget.isFuture
                              ? Colors.transparent
                              : PremiumTheme.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.progress?.hasPracticed ?? false) {
      return PremiumTheme.primary;
    }
    if (widget.isFuture) {
      return PremiumTheme.bgWarm;
    }
    if (widget.isSelected) {
      return PremiumTheme.primarySoft;
    }
    return PremiumTheme.bgCard;
  }

  Color _getTextColor() {
    if (widget.progress?.hasPracticed ?? false) {
      return Colors.white;
    }
    if (widget.isFuture) {
      return PremiumTheme.textTertiary;
    }
    if (widget.isToday) {
      return PremiumTheme.primary;
    }
    return PremiumTheme.textSecondary;
  }
}

/// Compact mini calendar showing just activity dots
class MiniProgressCalendar extends StatelessWidget {
  final Map<String, DailyProgress> progressData;
  final int daysToShow;

  const MiniProgressCalendar({
    super.key,
    required this.progressData,
    this.daysToShow = 7,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(daysToShow, (index) {
        final date = today.subtract(Duration(days: daysToShow - 1 - index));
        final dateKey = _dateToKey(date);
        final progress = progressData[dateKey];
        final hasPracticed = progress?.hasPracticed ?? false;
        final isToday = index == daysToShow - 1;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: hasPracticed
                    ? PremiumTheme.primary
                    : PremiumTheme.primarySoft,
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: PremiumTheme.primary, width: 2)
                    : null,
              ),
              child: Center(
                child: hasPracticed
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : Text(
                        '${date.day}',
                        style: PremiumTheme.labelSmall.copyWith(
                          color: isToday
                              ? PremiumTheme.primary
                              : PremiumTheme.textTertiary,
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
