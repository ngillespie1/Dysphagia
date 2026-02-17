import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/premium_theme.dart';
import '../../core/models/program_week.dart';
import '../../data/models/exercise_education.dart';

/// Expandable card showing week summary with exercises
class WeekSummaryCard extends StatefulWidget {
  final ProgramWeek week;
  final bool isCurrent;
  final bool initiallyExpanded;
  final VoidCallback? onContinue;

  const WeekSummaryCard({
    super.key,
    required this.week,
    this.isCurrent = false,
    this.initiallyExpanded = false,
    this.onContinue,
  });

  @override
  State<WeekSummaryCard> createState() => _WeekSummaryCardState();
}

class _WeekSummaryCardState extends State<WeekSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (!widget.week.status.isAccessible) return;
    
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.week.status;
    final isAccessible = status.isAccessible;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: PremiumTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCurrent
              ? PremiumTheme.primary
              : isAccessible
                  ? PremiumTheme.textTertiary.withOpacity(0.2)
                  : PremiumTheme.textTertiary.withOpacity(0.1),
          width: widget.isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isCurrent
                ? PremiumTheme.primary.withOpacity(0.1)
                : PremiumTheme.shadow,
            blurRadius: widget.isCurrent ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAccessible ? _toggleExpand : null,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(isAccessible),

              // Expandable content
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: _buildExpandedContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAccessible) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Week indicator
          _buildWeekIndicator(),
          const SizedBox(width: 12),

          // Title and focus
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${widget.week.label} · ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isAccessible
                            ? PremiumTheme.textSecondary
                            : PremiumTheme.textTertiary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.week.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isAccessible
                              ? PremiumTheme.textPrimary
                              : PremiumTheme.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'This week\'s focus: ${widget.week.focus}',
                  style: TextStyle(
                    fontSize: 13,
                    color: PremiumTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Progress or expand indicator
          const SizedBox(width: 12),
          if (widget.week.status.showProgress)
            _buildProgressIndicator()
          else if (isAccessible)
            RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: PremiumTheme.textSecondary,
              ),
            )
          else
            Icon(
              Icons.lock_rounded,
              color: PremiumTheme.textTertiary,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildWeekIndicator() {
    final status = widget.week.status;

    Color bgColor;
    Color iconColor;
    IconData? icon;

    switch (status) {
      case WeekStatus.completed:
        bgColor = PremiumTheme.primary;
        iconColor = Colors.white;
        icon = Icons.check_rounded;
        break;
      case WeekStatus.inProgress:
        bgColor = PremiumTheme.primaryLight;
        iconColor = PremiumTheme.primaryDark;
        icon = null;
        break;
      case WeekStatus.available:
        bgColor = PremiumTheme.surfaceVariant;
        iconColor = PremiumTheme.textSecondary;
        icon = null;
        break;
      case WeekStatus.locked:
        bgColor = PremiumTheme.surfaceVariant.withOpacity(0.5);
        iconColor = PremiumTheme.textTertiary;
        icon = Icons.lock_rounded;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: iconColor, size: 20)
            : Text(
                '${widget.week.weekNumber}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final percent = widget.week.completionPercent;

    return SizedBox(
      width: 48,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: PremiumTheme.progressRingBackground,
              valueColor: const AlwaysStoppedAnimation(PremiumTheme.primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percent * 100).round()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: PremiumTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Summary
          Text(
            widget.week.summary,
            style: TextStyle(
              fontSize: 14,
              color: PremiumTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Educational focus callout
          _buildEducationalFocus(),
          const SizedBox(height: 16),

          // Exercise list
          Text(
            'Exercises',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PremiumTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          ..._buildExerciseList(),

          const SizedBox(height: 16),

          // Continue button
          if (widget.week.status == WeekStatus.inProgress ||
              widget.week.status == WeekStatus.available)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.week.status == WeekStatus.inProgress
                      ? 'Continue ${widget.week.label}'
                      : 'Start ${widget.week.label}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEducationalFocus() {
    // Gather unique muscles targeted by this week's exercises
    final allMuscles = <String>{};
    for (final id in widget.week.exerciseIds) {
      final edu = ExerciseEducation.forExercise(id);
      if (edu != null) {
        allMuscles.addAll(edu.musclesTargeted);
      }
    }

    if (allMuscles.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PremiumTheme.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PremiumTheme.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'What you\'re building this week',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: PremiumTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allMuscles.take(5).map((muscle) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  muscle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: PremiumTheme.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExerciseList() {
    // Sample exercise names - in a real app these would come from data
    final exerciseNames = {
      'intro_swallow': 'Introduction to Swallowing',
      'chin_tuck': 'Chin Tuck Exercise',
      'tongue_press': 'Tongue Press',
      'effortful_swallow': 'Effortful Swallow',
      'mendelsohn': 'Mendelsohn Maneuver',
      'supraglottic': 'Supraglottic Swallow',
      'shaker_exercise': 'Shaker Exercise',
      'masako': 'Masako Maneuver',
      'tongue_resistance': 'Tongue Resistance',
      'breath_hold': 'Breath Hold',
      'vocal_exercises': 'Vocal Exercises',
      'rapid_swallow': 'Rapid Swallow',
    };

    final completedCount = widget.week.completedExercises;

    return widget.week.exerciseIds.asMap().entries.map((entry) {
      final index = entry.key;
      final exerciseId = entry.value;
      final isCompleted = index < completedCount;
      final name = exerciseNames[exerciseId] ?? exerciseId;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? PremiumTheme.primary : PremiumTheme.surfaceVariant,
                border: Border.all(
                  color: isCompleted ? PremiumTheme.primary : PremiumTheme.textTertiary,
                  width: 1.5,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  color: isCompleted
                      ? PremiumTheme.textSecondary
                      : PremiumTheme.textPrimary,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
