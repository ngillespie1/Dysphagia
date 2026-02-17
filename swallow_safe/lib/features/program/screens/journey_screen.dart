import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../shared/widgets/journey_timeline.dart';
import '../../../shared/widgets/week_summary_card.dart';
import '../bloc/program_bloc.dart';
import '../bloc/program_event.dart';
import '../bloc/program_state.dart';

/// Full journey screen with scrollable timeline and expandable week cards
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        body: SafeArea(
          child: BlocBuilder<ProgramBloc, ProgramState>(
            builder: (context, state) {
              if (state is! ProgramLoaded) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: PremiumTheme.primary,
                  ),
                );
              }

              final program = state.program;

              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _buildHeader(context, program.type.displayName),
                  ),

                  // Program progress summary
                  SliverToBoxAdapter(
                    child: _buildProgressSummary(context, state),
                  ),

                  // Journey timeline
                  SliverToBoxAdapter(
                    child: _buildTimeline(context, state),
                  ),

                  // Section header
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(context),
                  ),

                  // Week cards
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final week = program.weeks[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: WeekSummaryCard(
                            week: week,
                            isCurrent: week.weekNumber == program.currentWeek,
                            initiallyExpanded:
                                week.weekNumber == state.selectedWeek,
                            onContinue: () {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<ProgramBloc>()
                                  .add(SelectWeek(week.weekNumber));
                              context.go(AppRoutes.exercise);
                            },
                          ),
                        );
                      },
                      childCount: program.weeks.length,
                    ),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 40),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String programName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF8E8E93),
                size: 22,
              ),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              const Text(
                'Your Journey',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              Text(
                programName,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(BuildContext context, ProgramLoaded state) {
    final program = state.program;
    final completedWeeks =
        program.weeks.where((w) => w.completionPercent >= 1.0).length;
    final overallProgress = program.overallProgress;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumTheme.primary,
              PremiumTheme.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: PremiumTheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Progress circle
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: overallProgress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text(
                    '${(overallProgress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week ${program.currentWeek} of ${program.totalWeeks}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completedWeeks weeks completed · ${program.daysRemaining} days remaining',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, ProgramLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Text(
            'Timeline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
        ),
        JourneyTimeline(
          weeks: state.program.weeks,
          currentWeek: state.program.currentWeek,
          selectedWeek: state.selectedWeek,
          onWeekTap: (weekNumber) {
            HapticFeedback.selectionClick();
            context.read<ProgramBloc>().add(SelectWeek(weekNumber));
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        'Week Details',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF000000),
        ),
      ),
    );
  }
}
