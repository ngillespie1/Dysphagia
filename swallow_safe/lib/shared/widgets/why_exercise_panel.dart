import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/premium_theme.dart';
import '../../data/models/exercise_education.dart';

/// Expandable glassmorphic "Why this exercise?" panel shown on the exercise screen.
/// Displays explanation of the exercise's purpose and muscles targeted.
class WhyExercisePanel extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;

  const WhyExercisePanel({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<WhyExercisePanel> createState() => _WhyExercisePanelState();
}

class _WhyExercisePanelState extends State<WhyExercisePanel> {
  bool _expanded = false;
  ExerciseEducation? _education;

  @override
  void initState() {
    super.initState();
    // Try exercise ID first, then fall back to name
    _education = ExerciseEducation.forExercise(widget.exerciseId) ??
        ExerciseEducation.forExercise(widget.exerciseName);
  }

  @override
  void didUpdateWidget(WhyExercisePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseId != widget.exerciseId) {
      _education = ExerciseEducation.forExercise(widget.exerciseId) ??
          ExerciseEducation.forExercise(widget.exerciseName);
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_education == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _expanded = !_expanded);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collapsed header
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: PremiumTheme.info.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Text('🔬', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Why this exercise?',
                      style: PremiumTheme.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withOpacity(0.5),
                        size: 18,
                      ),
                    ),
                  ],
                ),

                // Expanded content
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _education!.whyItHelps,
                          style: PremiumTheme.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                            fontSize: 12,
                          ),
                        ),
                        if (_education!.musclesTargeted.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          // Muscles targeted chips
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _education!.musclesTargeted.map((muscle) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: PremiumTheme.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color:
                                        PremiumTheme.primary.withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  muscle,
                                  style: PremiumTheme.labelSmall.copyWith(
                                    color: PremiumTheme.primaryLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        if (_education!.researchNote != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _education!.researchNote!,
                            style: PremiumTheme.labelSmall.copyWith(
                              color: Colors.white.withOpacity(0.45),
                              fontStyle: FontStyle.italic,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
