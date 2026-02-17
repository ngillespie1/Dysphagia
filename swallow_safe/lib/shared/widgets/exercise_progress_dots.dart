import 'package:flutter/material.dart';

import '../../core/constants/dimensions.dart';
import '../../core/theme/premium_theme.dart';

/// Progress dots showing current position in exercise session
/// Animated transition between exercises
class ExerciseProgressDots extends StatelessWidget {
  final int totalCount;
  final int currentIndex;
  final int completedCount;

  const ExerciseProgressDots({
    super.key,
    required this.totalCount,
    required this.currentIndex,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.exerciseProgressDotsHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalCount, (index) {
          final isCompleted = index < completedCount;
          final isCurrent = index == currentIndex;
          
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.exerciseDotSpacing / 2,
            ),
            child: _Dot(
              isCompleted: isCompleted,
              isCurrent: isCurrent,
            ),
          );
        }),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;

  const _Dot({
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: isCurrent
          ? AppDimensions.exerciseDotSize * 2.5
          : AppDimensions.exerciseDotSize,
      height: AppDimensions.exerciseDotSize,
      decoration: BoxDecoration(
        color: _getColor(),
        borderRadius: BorderRadius.circular(AppDimensions.exerciseDotSize / 2),
      ),
    );
  }

  Color _getColor() {
    if (isCompleted) {
      return PremiumTheme.accent;
    } else if (isCurrent) {
      return PremiumTheme.accent;
    } else {
      return PremiumTheme.progressRingBackground;
    }
  }
}

/// Numbered progress indicator for exercise position
class ExerciseProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final String currentExerciseName;

  const ExerciseProgressBar({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.currentExerciseName,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentIndex + 1) / totalCount;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exercise ${currentIndex + 1} of $totalCount',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: PremiumTheme.textSecondary,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: PremiumTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.spacingS),
        
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.progressHeight / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: AppDimensions.progressHeight,
            backgroundColor: PremiumTheme.progressRingBackground,
            valueColor: const AlwaysStoppedAnimation<Color>(PremiumTheme.accent),
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacingM),
        
        // Exercise name
        Text(
          currentExerciseName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Rep counter overlay for during exercise
class RepCounter extends StatelessWidget {
  final int currentRep;
  final int totalReps;
  final bool isAnimating;

  const RepCounter({
    super.key,
    required this.currentRep,
    required this.totalReps,
    this.isAnimating = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isAnimating ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.elasticOut,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingM,
        ),
        decoration: BoxDecoration(
          color: PremiumTheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusPill),
          boxShadow: [
            BoxShadow(
              color: PremiumTheme.shadowMediumColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$currentRep',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: PremiumTheme.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' / $totalReps',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: PremiumTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
