import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../bloc/onboarding_bloc.dart';

/// Goals screen — Step 4 of 6
/// "What matters most to you?" — lets the patient choose 1-3 personal goals
/// so copy, milestones, and insights feel intentional rather than generic.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  final Set<String> _selectedGoals = {};

  static const _goals = [
    _Goal(
      id: 'eat_comfortably',
      emoji: '🍽️',
      title: 'Eat more comfortably',
      subtitle: 'Enjoy meals without worry',
    ),
    _Goal(
      id: 'build_strength',
      emoji: '💪',
      title: 'Build swallowing strength',
      subtitle: 'Strengthen muscles over time',
    ),
    _Goal(
      id: 'reduce_anxiety',
      emoji: '🧘',
      title: 'Feel less anxious',
      subtitle: 'Gain confidence at mealtimes',
    ),
    _Goal(
      id: 'stay_consistent',
      emoji: '📅',
      title: 'Stay consistent',
      subtitle: 'Build a daily exercise habit',
    ),
    _Goal(
      id: 'track_progress',
      emoji: '📈',
      title: 'See my progress',
      subtitle: 'Know I\'m getting better',
    ),
    _Goal(
      id: 'share_with_team',
      emoji: '👩‍⚕️',
      title: 'Share with my care team',
      subtitle: 'Keep my doctor informed',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: PremiumTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Semantics(
                      button: true,
                      label: 'Go back',
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: PremiumTheme.softShadow,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: PremiumTheme.textPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Progress indicator (step 4 of 6)
                    _buildProgressIndicator(4, 6),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      'What matters\nmost to you?',
                      style: PremiumTheme.displayMedium,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Choose up to 3 goals — we\'ll tailor your experience around them.',
                      style: PremiumTheme.bodyMedium.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Goal cards
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _goals.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          final isSelected =
                              _selectedGoals.contains(goal.id);

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(
                                milliseconds: 400 + index * 60),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset:
                                    Offset(0, 16 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: _GoalCard(
                              goal: goal,
                              isSelected: isSelected,
                              onTap: () => _toggleGoal(goal.id),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedGoals.isNotEmpty
                              ? PremiumTheme.primary
                              : PremiumTheme.surfaceVariant,
                          foregroundColor: _selectedGoals.isNotEmpty
                              ? Colors.white
                              : PremiumTheme.textTertiary,
                          padding:
                              const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _selectedGoals.isEmpty
                              ? 'Select at least one'
                              : 'Continue',
                          style: PremiumTheme.button,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Skip
                    Center(
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context.go(AppRoutes.onboardingDisclaimer);
                        },
                        child: Text(
                          'Skip for now',
                          style: PremiumTheme.bodySmall.copyWith(
                            color: PremiumTheme.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int current, int total) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index < current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? PremiumTheme.primary
                  : PremiumTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  void _toggleGoal(String goalId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedGoals.contains(goalId)) {
        _selectedGoals.remove(goalId);
      } else if (_selectedGoals.length < 3) {
        _selectedGoals.add(goalId);
      }
    });
  }

  void _continue() {
    if (_selectedGoals.isEmpty) return;
    HapticFeedback.mediumImpact();
    context.read<OnboardingBloc>().add(
          SetGoals(_selectedGoals.toList()),
        );
    context.go(AppRoutes.onboardingDisclaimer);
  }
}

class _Goal {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;

  const _Goal({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class _GoalCard extends StatelessWidget {
  final _Goal goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${goal.title}: ${goal.subtitle}',
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? PremiumTheme.primarySoft
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? PremiumTheme.primary.withOpacity(0.4)
                  : PremiumTheme.surfaceVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: PremiumTheme.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : PremiumTheme.softShadow,
          ),
          child: Row(
            children: [
              // Emoji
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? PremiumTheme.primary.withOpacity(0.1)
                      : PremiumTheme.bgWarm,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(goal.emoji,
                      style: const TextStyle(fontSize: 24)),
                ),
              ),

              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: PremiumTheme.headlineSmall.copyWith(
                        color: isSelected
                            ? PremiumTheme.primary
                            : PremiumTheme.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.subtitle,
                      style: PremiumTheme.bodySmall.copyWith(
                        color: PremiumTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Check
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? PremiumTheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? PremiumTheme.primary
                        : PremiumTheme.textMuted,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
