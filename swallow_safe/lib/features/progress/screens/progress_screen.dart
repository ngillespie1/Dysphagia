import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/daily_progress.dart';
import '../../../core/models/program.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/data_sync_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../data/models/check_in.dart';
import '../../../shared/widgets/achievement_grid.dart';
import '../../../shared/widgets/ai_insight_card.dart';
import '../../../shared/widgets/daily_progress_calendar.dart';
import '../../../shared/widgets/illustrated_empty_state.dart';
import '../../../shared/widgets/journey_timeline.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/week_summary_card.dart';
import '../../ai_assistant/bloc/ai_chat_bloc.dart';
import '../../gamification/bloc/gamification_bloc.dart';
import '../../program/bloc/program_bloc.dart';
import '../../program/bloc/program_event.dart';
import '../../program/bloc/program_state.dart';

/// Journey tab — program timeline, calendar heatmap, trends, and insights.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DataSyncService _dataService = getIt<DataSyncService>();

  Map<String, DailyProgress> _progressMap = {};
  List<CheckIn> _recentCheckIns = [];
  DateTime _selectedDate = DateTime.now();
  int? _selectedWeek;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 60));
    final progressRecords = await _dataService.getProgressInRange(startDate, now);
    final checkIns = await _dataService.getRecentCheckIns(limit: 30);

    if (!mounted) return;

    final map = <String, DailyProgress>{};
    for (final record in progressRecords) {
      if (record.sessionCompleted) {
        map[record.date] = DailyProgress(
          date: DateTime.parse(record.date),
          exercisesCompleted: record.exercisesCompleted,
          exercisesTotal: record.exercisesTotal,
          durationMinutes: record.durationMinutes,
          sessionCompleted: record.sessionCompleted,
        );
      }
    }

    setState(() {
      _progressMap = map;
      _recentCheckIns = checkIns;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? PremiumTheme.darkBackground : PremiumTheme.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: PremiumTheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(isDark),
                  BlocBuilder<ProgramBloc, ProgramState>(
                    builder: (context, programState) {
                      final hasProgramLoaded = programState is ProgramLoaded;
                      final hasData = _progressMap.isNotEmpty || _recentCheckIns.isNotEmpty;

                      if (!hasProgramLoaded && !hasData) {
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildJourneyEmptyState(),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildProgressHero(isDark),
                          const SizedBox(height: 24),
                          _buildJourneyTimeline(isDark),
                          const SizedBox(height: 24),
                          _buildCalendarSection(isDark),
                          const SizedBox(height: 24),
                          _buildTrends(isDark),
                          const SizedBox(height: 20),
                          _buildInsightSection(),
                          const SizedBox(height: 24),
                          _buildAchievements(isDark),
                          const SizedBox(height: 24),
                          _buildSymptomHistorySection(isDark),
                          const SizedBox(height: 20),
                          _buildSelectedWeekDetail(isDark),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Title ───

  Widget _buildTitle(bool isDark) {
    return Text(
      'Your Journey',
      style: PremiumTheme.displayMedium.copyWith(
        color: isDark ? Colors.white : PremiumTheme.textPrimary,
        fontSize: 28,
      ),
    );
  }

  // ─── Journey Empty State ───

  Widget _buildJourneyEmptyState() {
    return const IllustratedEmptyState(
      type: EmptyStateType.journey,
      title: 'Your journey begins here',
      subtitle:
          'Complete your first exercise session and check in — every step you take builds your recovery story.',
    );
  }

  // ─── Progress Hero Card ───

  Widget _buildProgressHero(bool isDark) {
    return BlocBuilder<ProgramBloc, ProgramState>(
      builder: (context, state) {
        if (state is! ProgramLoaded) {
          return const SizedBox.shrink();
        }

        final program = state.program;
        final progress = program.overallProgress;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [PremiumTheme.darkPrimarySoft, PremiumTheme.darkSurface]
                  : [PremiumTheme.primarySoft, PremiumTheme.backgroundMint],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: PremiumTheme.primary.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Animated progress ring (animates on load)
              ProgressRing(
                progress: progress,
                size: 72,
                strokeWidth: 6,
                showPercentage: true,
                animationDuration: const Duration(milliseconds: 1200),
                animationCurve: Curves.easeOutCubic,
              ),
              const SizedBox(width: 20),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week ${program.currentWeek} of ${program.totalWeeks}',
                      style: PremiumTheme.headlineLarge.copyWith(
                        color: isDark ? Colors.white : PremiumTheme.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      program.type.displayName,
                      style: PremiumTheme.bodyMedium.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : PremiumTheme.textSecondary,
                      ),
                    ),
                    if (program.daysRemaining > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${program.daysRemaining} days to go',
                        style: PremiumTheme.bodySmall.copyWith(
                          color: PremiumTheme.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Journey Timeline ───

  Widget _buildJourneyTimeline(bool isDark) {
    return BlocBuilder<ProgramBloc, ProgramState>(
      builder: (context, state) {
        if (state is! ProgramLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Timeline',
              style: PremiumTheme.headlineSmall.copyWith(
                color: isDark ? Colors.white : PremiumTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            JourneyTimeline(
              weeks: state.program.weeks,
              currentWeek: state.program.currentWeek,
              selectedWeek: _selectedWeek ?? state.selectedWeek,
              compact: true,
              onWeekTap: (weekNum) {
                HapticFeedback.selectionClick();
                setState(() => _selectedWeek = weekNum);
                context.read<ProgramBloc>().add(SelectWeek(weekNum));
              },
            ),
          ],
        );
      },
    );
  }

  // ─── Calendar Heatmap ───

  Widget _buildCalendarSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Activity',
          style: PremiumTheme.headlineSmall.copyWith(
            color: isDark ? Colors.white : PremiumTheme.textPrimary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        DailyProgressCalendar(
          progressData: _progressMap,
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() => _selectedDate = date);
          },
        ),
      ],
    );
  }

  // ─── Trend Sparklines ───

  Widget _buildTrends(bool isDark) {
    if (_recentCheckIns.length < 3) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How You\'re Trending',
          style: PremiumTheme.headlineSmall.copyWith(
            color: isDark ? Colors.white : PremiumTheme.textPrimary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TrendCard(
                label: 'Pain',
                values: _recentCheckIns
                    .take(14)
                    .map((c) => c.painLevel.toDouble())
                    .toList()
                    .reversed
                    .toList(),
                isDark: isDark,
                lowerIsBetter: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TrendCard(
                label: 'Swallowing',
                values: _recentCheckIns
                    .take(14)
                    .map((c) => c.swallowingEase.toDouble())
                    .toList()
                    .reversed
                    .toList(),
                isDark: isDark,
                lowerIsBetter: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TrendCard(
                label: 'Dry Mouth',
                values: _recentCheckIns
                    .take(14)
                    .map((c) => c.dryMouth.toDouble())
                    .toList()
                    .reversed
                    .toList(),
                isDark: isDark,
                lowerIsBetter: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── AI Insight ───

  Widget _buildInsightSection() {
    return BlocBuilder<AIChatBloc, AIChatState>(
      builder: (context, state) {
        if (state is! AIChatReady) return const SizedBox.shrink();
        final insights = state.activeInsights;
        if (insights.length < 2) return const SizedBox.shrink();

        // Show second insight on Journey (first is on Today)
        final insight = insights.length > 1 ? insights[1] : insights.first;
        return AIInsightCard(
          insight: insight,
          onDismiss: () {
            context.read<AIChatBloc>().add(DismissInsight(insight.id));
          },
        );
      },
    );
  }

  // ─── Achievements Milestone Path ───

  Widget _buildAchievements(bool isDark) {
    return BlocBuilder<GamificationBloc, GamificationState>(
      builder: (context, state) {
        if (state is! GamificationLoaded) return const SizedBox.shrink();
        return AchievementMilestonePath(
          achievements: state.allAchievements,
          totalSessions: state.totalSessions,
          currentStreak: state.currentStreak,
          totalCheckIns: state.totalCheckIns,
          programProgress: state.programProgress,
        );
      },
    );
  }

  // ─── Symptom History & Export ───

  Widget _buildSymptomHistorySection(bool isDark) {
    if (_recentCheckIns.length < 2) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your Symptom Story',
                style: PremiumTheme.headlineSmall.copyWith(
                  color: isDark ? Colors.white : PremiumTheme.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            // CSV export button
            GestureDetector(
              onTap: _exportCSV,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : PremiumTheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download_rounded,
                        size: 14, color: PremiumTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Export',
                      style: PremiumTheme.labelSmall.copyWith(
                        color: PremiumTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Full symptom history chart (last 14 check-ins)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? PremiumTheme.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : PremiumTheme.surfaceVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Legend
              Row(
                children: [
                  _legendDot(PremiumTheme.error, 'Pain'),
                  const SizedBox(width: 14),
                  _legendDot(PremiumTheme.primary, 'Swallowing'),
                  const SizedBox(width: 14),
                  _legendDot(PremiumTheme.warning, 'Dry Mouth'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SymptomChartPainter(
                    checkIns: _recentCheckIns.take(14).toList().reversed.toList(),
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last ${_recentCheckIns.take(14).length} check-ins',
                style: PremiumTheme.labelSmall.copyWith(
                  color: PremiumTheme.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: PremiumTheme.labelSmall.copyWith(
            color: PremiumTheme.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _exportCSV() {
    if (_recentCheckIns.isEmpty) return;
    HapticFeedback.mediumImpact();

    // Build CSV
    final buffer = StringBuffer();
    buffer.writeln('Date,Pain Level,Swallowing Ease,Dry Mouth');
    for (final c in _recentCheckIns.reversed) {
      buffer.writeln('${c.date},${c.painLevel},${c.swallowingEase},${c.dryMouth}');
    }

    // Show in a bottom sheet for now (real app would share/save)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? PremiumTheme.darkCardColor : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PremiumTheme.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share Your Data',
                style: PremiumTheme.headlineSmall.copyWith(
                  color: isDark ? Colors.white : PremiumTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_recentCheckIns.length} check-ins ready to share',
                style: PremiumTheme.bodySmall.copyWith(
                  color: PremiumTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : PremiumTheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  buffer.toString().trim(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: buffer.toString()));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied — ready to share with your team'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy to clipboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ─── Selected Week Detail ───

  Widget _buildSelectedWeekDetail(bool isDark) {
    return BlocBuilder<ProgramBloc, ProgramState>(
      builder: (context, state) {
        if (state is! ProgramLoaded) return const SizedBox.shrink();

        final weekNum = _selectedWeek ?? state.selectedWeek;
        final week = state.selectedWeekData ??
            state.program.currentWeekData;
        if (week == null) return const SizedBox.shrink();

        return WeekSummaryCard(
          week: week,
          isCurrent: weekNum == state.program.currentWeek,
          initiallyExpanded: true,
          onContinue: () {
            HapticFeedback.mediumImpact();
            context.push(AppRoutes.exercise);
          },
        );
      },
    );
  }
}

// ─── Trend Sparkline Card ───

class _TrendCard extends StatelessWidget {
  final String label;
  final List<double> values;
  final bool isDark;
  final bool lowerIsBetter;

  const _TrendCard({
    required this.label,
    required this.values,
    required this.isDark,
    required this.lowerIsBetter,
  });

  String get _trendLabel {
    if (values.length < 4) return '';
    final mid = values.length ~/ 2;
    final recentAvg =
        values.sublist(mid).reduce((a, b) => a + b) / (values.length - mid);
    final olderAvg = values.sublist(0, mid).reduce((a, b) => a + b) / mid;
    final diff = recentAvg - olderAvg;

    if (lowerIsBetter) {
      if (diff < -0.3) return 'Improving';
      if (diff > 0.3) return 'Worsening';
    } else {
      if (diff > 0.3) return 'Improving';
      if (diff < -0.3) return 'Worsening';
    }
    return 'Stable';
  }

  Color get _trendColor {
    final trend = _trendLabel;
    if (trend == 'Improving') return PremiumTheme.success;
    if (trend == 'Worsening') return PremiumTheme.error;
    return PremiumTheme.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : PremiumTheme.surfaceVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: PremiumTheme.labelSmall.copyWith(
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : PremiumTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          // Animated sparkline with draw-in effect
          _AnimatedSparkline(
            values: values,
            color: _trendColor,
            height: 28,
          ),
          const SizedBox(height: 6),
          Text(
            _trendLabel.isNotEmpty ? _trendLabel : '—',
            style: PremiumTheme.labelSmall.copyWith(
              color: _trendColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated sparkline with gradient fill and draw-in effect
class _AnimatedSparkline extends StatefulWidget {
  final List<double> values;
  final Color color;
  final double height;

  const _AnimatedSparkline({
    required this.values,
    required this.color,
    this.height = 28,
  });

  @override
  State<_AnimatedSparkline> createState() => _AnimatedSparklineState();
}

class _AnimatedSparklineState extends State<_AnimatedSparkline>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawController;
  late Animation<double> _drawAnimation;

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeOutCubic,
    );
    _drawController.forward();
  }

  @override
  void dispose() {
    _drawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _drawAnimation,
        builder: (context, _) {
          return CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _SparklinePainter(
              values: widget.values,
              color: widget.color,
              drawProgress: _drawAnimation.value,
            ),
          );
        },
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double drawProgress;

  _SparklinePainter({
    required this.values,
    required this.color,
    this.drawProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    if (range == 0) return;

    // Compute how many points to draw based on drawProgress
    final maxPoints = ((values.length - 1) * drawProgress).ceil() + 1;
    final pointsToDraw = maxPoints.clamp(2, values.length);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < pointsToDraw; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minVal) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Gradient fill below line
    final lastX = ((pointsToDraw - 1) / (values.length - 1)) * size.width;
    final fillPath = Path.from(path);
    fillPath.lineTo(lastX, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.25 * drawProgress),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw a glowing dot at the end of the drawn line
    if (drawProgress > 0.1 && pointsToDraw >= 2) {
      final endX = ((pointsToDraw - 1) / (values.length - 1)) * size.width;
      final endY = size.height -
          ((values[pointsToDraw - 1] - minVal) / range) * size.height;
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(endX, endY), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.drawProgress != drawProgress;
  }
}

/// Full symptom history chart painter with three line series.
class _SymptomChartPainter extends CustomPainter {
  final List<CheckIn> checkIns;
  final bool isDark;

  _SymptomChartPainter({required this.checkIns, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (checkIns.length < 2) return;

    final n = checkIns.length;
    const maxVal = 5.0;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.06)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw each series
    _drawSeries(canvas, size, n, maxVal,
        checkIns.map((c) => c.painLevel.toDouble()).toList(),
        PremiumTheme.error);
    _drawSeries(canvas, size, n, maxVal,
        checkIns.map((c) => c.swallowingEase.toDouble()).toList(),
        PremiumTheme.primary);
    _drawSeries(canvas, size, n, maxVal,
        checkIns.map((c) => c.dryMouth.toDouble()).toList(),
        PremiumTheme.warning);
  }

  void _drawSeries(Canvas canvas, Size size, int n, double maxVal,
      List<double> values, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < n; i++) {
      final x = n > 1 ? (i / (n - 1)) * size.width : size.width / 2;
      final y = size.height - (values[i] / maxVal) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Dot at last point
    final lastX = size.width;
    final lastY = size.height - (values.last / maxVal) * size.height;
    canvas.drawCircle(Offset(lastX, lastY), 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SymptomChartPainter old) {
    return old.checkIns != checkIns || old.isDark != isDark;
  }
}
