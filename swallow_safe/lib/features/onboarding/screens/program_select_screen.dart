import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/program.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../program/bloc/program_bloc.dart';
import '../../program/bloc/program_event.dart';
import '../../program/bloc/program_state.dart';
import '../../user/bloc/user_bloc.dart';
import '../bloc/onboarding_bloc.dart';

/// Premium program selection screen with elegant cards
class ProgramSelectScreen extends StatefulWidget {
  const ProgramSelectScreen({super.key});

  @override
  State<ProgramSelectScreen> createState() => _ProgramSelectScreenState();
}

class _ProgramSelectScreenState extends State<ProgramSelectScreen>
    with SingleTickerProviderStateMixin {
  ProgramType? _selectedType;
  late AnimationController _fadeController;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
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

                        // Progress indicator (step 6 of 6)
                        _buildProgressIndicator(6, 6),

                        const SizedBox(height: 40),

                        // Title
                        Text(
                          'Select your\ntreatment plan',
                          style: PremiumTheme.displayMedium,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Choose based on your healthcare provider\'s recommendation',
                          style: PremiumTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // Program list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: ProgramType.values.length,
                      itemBuilder: (context, index) {
                        final type = ProgramType.values[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400 + index * 80),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: _ProgramCard(
                            type: type,
                            isSelected: _selectedType == type,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedType = type);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context),
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
            margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
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

  Widget _buildBottomBar(BuildContext context) {
    return BlocListener<ProgramBloc, ProgramState>(
      listener: (context, state) {
        if (state is ProgramLoaded) {
          // Complete onboarding
          final onboardingState = context.read<OnboardingBloc>().state;
          if (onboardingState is OnboardingInProgress) {
            context.read<UserBloc>().add(CompleteUserOnboarding(
                  name: onboardingState.name ?? 'User',
                  email: onboardingState.email ?? '',
                  programType: _selectedType!,
                  disclaimerAccepted: onboardingState.disclaimerAccepted,
                  disclaimerAcceptedAt: onboardingState.disclaimerAcceptedAt,
                ));
          }
          context.read<OnboardingBloc>().add(const CompleteOnboarding());
          context.go(AppRoutes.home);
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BlocBuilder<ProgramBloc, ProgramState>(
          builder: (context, state) {
            final isLoading = state is ProgramLoading;

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedType != null && !isLoading ? _startProgram : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType != null
                      ? PremiumTheme.primary
                      : PremiumTheme.surfaceVariant,
                  foregroundColor: _selectedType != null
                      ? Colors.white
                      : PremiumTheme.textTertiary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text('Start Program', style: PremiumTheme.button),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startProgram() {
    HapticFeedback.mediumImpact();
    context.read<OnboardingBloc>().add(SetProgramType(_selectedType!));
    context.read<ProgramBloc>().add(SelectProgramType(_selectedType!));
  }
}

class _ProgramCard extends StatelessWidget {
  final ProgramType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        selected: isSelected,
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? PremiumTheme.primarySoft
                    : PremiumTheme.bgWarm,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(type.icon, style: const TextStyle(fontSize: 28)),
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          type.displayName,
                          style: PremiumTheme.headlineSmall.copyWith(
                            color: isSelected
                                ? PremiumTheme.primary
                                : PremiumTheme.textPrimary,
                          ),
                        ),
                      ),
                      // Duration badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? PremiumTheme.primary.withOpacity(0.15)
                              : PremiumTheme.bgWarm,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type.durationDisplay,
                          style: PremiumTheme.labelSmall.copyWith(
                            color: isSelected
                                ? PremiumTheme.primary
                                : PremiumTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type.description,
                    style: PremiumTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 14,
                        color: PremiumTheme.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${type.exercisesPerWeek} exercises/session',
                        style: PremiumTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? PremiumTheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? PremiumTheme.primary
                      : PremiumTheme.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
