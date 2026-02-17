import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/data_sync_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../core/utils/accessibility.dart';
import '../../../data/models/streak_data.dart';
import '../../../shared/widgets/ai_insight_card.dart';
import '../../../shared/widgets/animated_mesh_background.dart';
import '../../../shared/widgets/appointment_card.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/hydration_tracker_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/tip_of_day_card.dart';
import '../../../shared/widgets/weekly_summary_sheet.dart';
import '../../../core/services/ai_service.dart';
import '../../ai_assistant/bloc/ai_chat_bloc.dart';
import '../../gamification/bloc/gamification_bloc.dart';
import '../../../core/models/program.dart';
import '../../program/bloc/program_bloc.dart';
import '../../program/bloc/program_state.dart';
import '../../user/bloc/user_bloc.dart';

/// Today screen — the award-winning daily dashboard.
///
/// Visual layers:
/// 0. AnimatedMeshBackground — slowly drifting organic mint blobs
/// 1. Immersive gradient header with large progress ring & greeting
/// 2. Elevated hero exercise card with bespoke illustration
/// 3. Daily status strip (XP + Streak + Hydration)
/// 4. Redesigned check-in with emoji selectors
/// 5. Celebration banner (conditional)
/// 6. Secondary section wrapped in GlassCards
///
/// All sections stagger-animate on entrance.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final DataSyncService _dataService = getIt<DataSyncService>();

  StreakInfo _streak = const StreakInfo();
  bool _completedToday = false;
  bool _checkedInToday = false;
  bool _isRestDay = false;

  // Check-in values (1-5)
  double _pain = 3;
  double _swallowing = 3;
  double _dryMouth = 3;
  bool _checkInExpanded = false;

  // Hydration inline expansion
  bool _hydrationExpanded = false;

  // Confetti state
  bool _showConfetti = false;

  // ── Animation controllers ──
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  late AnimationController _emojiController;
  late Animation<double> _emojiBounce;

  // Staggered entrance controller (drives all section entrances)
  late AnimationController _entranceController;
  late Animation<double> _headerEntrance;
  late Animation<double> _heroEntrance;
  late Animation<double> _stripEntrance;
  late Animation<double> _checkInEntrance;
  late Animation<double> _secondaryEntrance;

  // Confetti controller
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    // Shimmer pulse for hero card
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Emoji bounce
    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _emojiBounce = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.elasticOut),
    );

    // Staggered entrance — 1200ms total, each section gets its own Interval
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    _heroEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.10, 0.50, curve: Curves.easeOutCubic),
    );
    _stripEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.60, curve: Curves.easeOutCubic),
    );
    _checkInEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.70, curve: Curves.easeOutCubic),
    );
    _secondaryEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.50, 0.85, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();

    // Confetti
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _loadData();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _emojiController.dispose();
    _entranceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// Daily completion: on active days session = 50% + check-in = 50%.
  /// On rest days, just checking in counts as 100%.
  double get _dailyProgress {
    if (_isRestDay && !_completedToday) {
      return _checkedInToday ? 1.0 : 0.0;
    }
    double p = 0;
    if (_completedToday) p += 0.5;
    if (_checkedInToday) p += 0.5;
    return p;
  }

  Future<void> _loadData() async {
    // Determine rest day status from program state
    final programState = context.read<ProgramBloc>().state;
    List<int> restDayWeekdays = const [];
    bool todayIsRestDay = false;
    if (programState is ProgramLoaded) {
      restDayWeekdays = programState.program.effectiveRestDays;
      todayIsRestDay = programState.program.isTodayRestDay;
    }

    final streak = await _dataService.getStreakData(
      restDayWeekdays: restDayWeekdays,
    );
    final todayProgress = await _dataService.getTodayProgress();
    final todayCheckIn = await _dataService.getTodayCheckIn();

    if (!mounted) return;
    setState(() {
      _streak = streak;
      _completedToday = todayProgress?.sessionCompleted ?? false;
      _checkedInToday = todayCheckIn != null;
      _isRestDay = todayIsRestDay;
      if (todayCheckIn != null) {
        _pain = todayCheckIn.painLevel.toDouble();
        _swallowing = todayCheckIn.swallowingEase.toDouble();
        _dryMouth = todayCheckIn.dryMouth.toDouble();
      }
      if (!_checkedInToday && !_checkInExpanded) {
        _checkInExpanded = true;
      }
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedMeshBackground(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _loadData,
                color: PremiumTheme.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Immersive Gradient Header ───
                      _buildStaggeredSection(
                        animation: _headerEntrance,
                        slideOffset: 15,
                        child: _buildImmersiveHeader(isDark, topPadding),
                      ),

                      // ─── Scrollable content ───
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Hero card (exercise or rest day)
                            _buildStaggeredSection(
                              animation: _heroEntrance,
                              slideOffset: 20,
                              child: _isRestDay && !_completedToday
                                  ? _buildRestDayCard(isDark)
                                  : Semantics(
                                      button: !_completedToday,
                                      label: _completedToday
                                          ? 'Today\'s session is complete'
                                          : 'Tap to begin today\'s exercise session',
                                      child: _TapScaleWrapper(
                                        onTap: _completedToday
                                            ? null
                                            : _startExercise,
                                        child: _buildHeroExerciseCard(isDark),
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 16),

                            // Status strip
                            _buildStaggeredSection(
                              animation: _stripEntrance,
                              slideOffset: 20,
                              child: _buildDailyStatusStrip(isDark),
                            ),

                            const SizedBox(height: 20),

                            // Check-in
                            _buildStaggeredSection(
                              animation: _checkInEntrance,
                              slideOffset: 20,
                              child: _buildCheckInSection(isDark),
                            ),

                            if (_completedToday && _checkedInToday) ...[
                              const SizedBox(height: 16),
                              _buildCelebrationBanner(isDark),
                            ],

                            if (_hydrationExpanded) ...[
                              const SizedBox(height: 16),
                              const HydrationTrackerCard(),
                            ],

                            const SizedBox(height: 20),

                            // ─── Week in Review ───
                            _buildStaggeredSection(
                              animation: _secondaryEntrance,
                              slideOffset: 20,
                              child: Semantics(
                                button: true,
                                label: 'View your week in review',
                                child: _TapScaleWrapper(
                                  onTap: _openWeeklySummary,
                                  child: _buildWeekInReviewCard(isDark),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ─── Section divider ───
                            _buildStaggeredSection(
                              animation: _secondaryEntrance,
                              slideOffset: 15,
                              child: _buildSectionDivider(isDark),
                            ),

                            const SizedBox(height: 20),

                            // ─── Secondary content in GlassCards ───
                            _buildStaggeredSection(
                              animation: _secondaryEntrance,
                              slideOffset: 20,
                              child: Column(
                                children: [
                                  _TapScaleWrapper(
                                    onTap: () =>
                                        context.push(AppRoutes.foodDiary),
                                    child: _buildFoodDiaryLink(isDark),
                                  ),
                                  const SizedBox(height: 12),
                                  _TapScaleWrapper(
                                    child: GlassCard(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: isDark
                                          ? PremiumTheme.darkCardColor
                                          : Colors.white,
                                      blur: isDark ? 8 : 12,
                                      child: const AppointmentCard(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInsightSection(),
                                  const SizedBox(height: 12),
                                  GlassCard(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: isDark
                                        ? PremiumTheme.darkCardColor
                                        : Colors.white,
                                    blur: isDark ? 8 : 12,
                                    child: const TipOfDayCard(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Confetti overlay
              if (_showConfetti)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _confettiController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _ConfettiPainter(
                            progress: _confettiController.value,
                            centerX: MediaQuery.of(context).size.width / 2,
                            centerY: MediaQuery.of(context).size.height * 0.55,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // STAGGER HELPER
  // ════════════════════════════════════════════════════════════════

  Widget _buildStaggeredSection({
    required Animation<double> animation,
    required Widget child,
    double slideOffset = 20,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 1. IMMERSIVE GRADIENT HEADER
  // ════════════════════════════════════════════════════════════════

  Widget _buildImmersiveHeader(bool isDark, double topPadding) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final name = userState is UserLoaded ? userState.firstName : '';

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      PremiumTheme.darkSurface,
                      PremiumTheme.darkBackground.withOpacity(0.0),
                    ]
                  : [
                      PremiumTheme.bgWarm,
                      PremiumTheme.bgCream.withOpacity(0.7),
                      Colors.transparent,
                    ],
              stops: isDark ? null : const [0.0, 0.7, 1.0],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: streak badge (right-aligned) ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_streak.currentStreak > 0)
                      _StreakBadge(
                        days: _streak.currentStreak,
                        isDark: isDark,
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Main greeting row: ring + text ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Large daily progress ring with glow
                    Container(
                      decoration: _dailyProgress >= 1.0
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: PremiumTheme.success
                                      .withOpacity(0.25),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            )
                          : null,
                      child: ProgressRing(
                        progress: _dailyProgress,
                        size: 80,
                        strokeWidth: 7,
                        showPercentage: false,
                        child: _dailyProgress >= 1.0
                            ? const Icon(Icons.check_rounded,
                                color: PremiumTheme.success, size: 30)
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Typography drama: bigger, bolder percentage
                                  Text(
                                    '${(_dailyProgress * 100).round()}',
                                    style:
                                        PremiumTheme.displayMedium.copyWith(
                                      color: PremiumTheme.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                      height: 1.0,
                                      shadows: [
                                        Shadow(
                                          color: PremiumTheme.primary
                                              .withOpacity(0.15),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '%',
                                    style: PremiumTheme.labelSmall.copyWith(
                                      color: PremiumTheme.textTertiary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Greeting + name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_greeting${name.isNotEmpty ? ',' : ''}',
                            style: PremiumTheme.bodyLarge.copyWith(
                              color: isDark
                                  ? Colors.white.withOpacity(0.6)
                                  : PremiumTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          if (name.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              name,
                              style:
                                  PremiumTheme.displayMedium.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : PremiumTheme.textPrimary,
                                fontSize: 30,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            _dailyProgress >= 1.0
                                ? 'All done for today — rest up! 💛'
                                : _dailyProgress > 0
                                    ? 'Almost there — you\'ve got this'
                                    : 'Your exercises are ready whenever you are',
                            style: PremiumTheme.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : PremiumTheme.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // REST DAY CARD
  // ════════════════════════════════════════════════════════════════

  Widget _buildRestDayCard(bool isDark) {
    return Semantics(
      label: 'Today is a scheduled rest day',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    PremiumTheme.darkSurface,
                    PremiumTheme.darkPrimarySoft,
                  ]
                : [
                    PremiumTheme.infoLight,
                    PremiumTheme.primarySoft,
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : PremiumTheme.info.withOpacity(0.15),
          ),
          boxShadow: isDark
              ? PremiumTheme.darkSoftShadow
              : PremiumTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: PremiumTheme.info.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.self_improvement_rounded,
                      size: 14, color: PremiumTheme.info),
                  const SizedBox(width: 5),
                  Text(
                    'Rest Day',
                    style: PremiumTheme.labelSmall.copyWith(
                      color: PremiumTheme.info,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Title
            Text(
              'Time to recharge 🌿',
              style: PremiumTheme.headlineLarge.copyWith(
                color: isDark ? Colors.white : PremiumTheme.textPrimary,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 8),

            // Message
            Text(
              'Your muscles recover and grow stronger on rest days. '
              'Stay hydrated and enjoy some downtime — you\'ve earned it!',
              style: PremiumTheme.bodyMedium.copyWith(
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : PremiumTheme.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // Optional: still allow session if user wants
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Want to exercise anyway?',
                    style: PremiumTheme.bodySmall.copyWith(
                      color: PremiumTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _startExercise,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : PremiumTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Start session',
                      style: PremiumTheme.labelSmall.copyWith(
                        color: PremiumTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 2. ELEVATED HERO EXERCISE CARD
  // ════════════════════════════════════════════════════════════════

  Widget _buildHeroExerciseCard(bool isDark) {
    return BlocBuilder<ProgramBloc, ProgramState>(
      builder: (context, programState) {
        String weekLabel = 'Your Exercises';
        String focusLabel = 'Daily session';
        String timeLabel = '~12 min';

        if (programState is ProgramLoaded) {
          final program = programState.program;
          final weekData = program.currentWeekData;
          weekLabel =
              'Week ${program.currentWeek}: ${weekData?.title ?? 'Exercises'}';
          focusLabel = weekData?.focus ?? program.type.focusArea;
          timeLabel = '~${program.estimatedSessionMinutes} min';
        }

        // Parse the minute number for typography drama
        final timeMatch = RegExp(r'~?(\d+)').firstMatch(timeLabel);
        final timeNumber = timeMatch?.group(1) ?? '12';

        return AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            final shimmerValue = _shimmerAnimation.value;
            final shimmerOpacity = _completedToday
                ? 0.0
                : 0.04 * math.sin(shimmerValue * math.pi);

            return Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: _completedToday
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                PremiumTheme.darkPrimarySoft,
                                PremiumTheme.darkSurface
                              ]
                            : [
                                PremiumTheme.successLight,
                                PremiumTheme.successLight
                              ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          isDark
                              ? PremiumTheme.darkSurface
                              : PremiumTheme.primary.withOpacity(0.08),
                          isDark
                              ? PremiumTheme.darkPrimarySoft
                              : PremiumTheme.primaryLight.withOpacity(
                                  0.15 + shimmerOpacity * 2),
                        ],
                      ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _completedToday
                      ? PremiumTheme.success.withOpacity(0.2)
                      : (isDark
                          ? PremiumTheme.darkPrimaryLight.withOpacity(0.15)
                          : PremiumTheme.primaryLight.withOpacity(
                              0.35 + shimmerOpacity * 2)),
                  width: 1,
                ),
                boxShadow: _completedToday
                    ? (isDark
                        ? PremiumTheme.darkSoftShadow
                        : PremiumTheme.softShadow)
                    : [
                        BoxShadow(
                          color: (isDark
                                  ? Colors.black
                                  : PremiumTheme.primary)
                              .withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: (isDark
                                  ? Colors.black
                                  : PremiumTheme.primary)
                              .withOpacity(0.06 + shimmerOpacity),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  // Bespoke hero illustration — flowing throat/swallow curves
                  if (!_completedToday)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _HeroIllustrationPainter(
                          animationValue: shimmerValue,
                          color: isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.white.withOpacity(0.55),
                        ),
                      ),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time badge + session status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _completedToday
                                    ? PremiumTheme.success.withOpacity(0.15)
                                    : PremiumTheme.accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _completedToday
                                        ? Icons.check_rounded
                                        : Icons.timer_outlined,
                                    size: 13,
                                    color: _completedToday
                                        ? PremiumTheme.success
                                        : PremiumTheme.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  // Typography drama: bigger minute number
                                  _completedToday
                                      ? Text(
                                          'Completed',
                                          style: PremiumTheme.labelSmall
                                              .copyWith(
                                            color: PremiumTheme.success,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '~',
                                                style: PremiumTheme.labelSmall
                                                    .copyWith(
                                                  color: PremiumTheme.accent,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text: timeNumber,
                                                style: PremiumTheme.labelSmall
                                                    .copyWith(
                                                  color: PremiumTheme.accent,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' min',
                                                style: PremiumTheme.labelSmall
                                                    .copyWith(
                                                  color: PremiumTheme.accent,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (!_completedToday)
                              Icon(
                                Icons.fitness_center_rounded,
                                size: 20,
                                color: isDark
                                    ? Colors.white.withOpacity(0.15)
                                    : PremiumTheme.primary.withOpacity(0.2),
                              ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Title
                        Text(
                          weekLabel,
                          style: PremiumTheme.headlineLarge.copyWith(
                            color: isDark
                                ? Colors.white
                                : PremiumTheme.textPrimary,
                            fontSize: 22,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Focus: $focusLabel',
                          style: PremiumTheme.bodyMedium.copyWith(
                            color: isDark
                                ? Colors.white.withOpacity(0.6)
                                : PremiumTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // CTA button
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: _completedToday
                              ? null
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: PremiumTheme.primary
                                          .withOpacity(0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                          child: ElevatedButton(
                            onPressed:
                                _completedToday ? null : _startExercise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _completedToday
                                  ? PremiumTheme.success
                                  : PremiumTheme.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  PremiumTheme.success.withOpacity(0.7),
                              disabledForegroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _completedToday
                                      ? Icons.check_circle_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _completedToday
                                      ? 'You did it!'
                                      : 'Let\'s begin today\'s exercises',
                                  style: PremiumTheme.button.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 3. DAILY STATUS STRIP
  // ════════════════════════════════════════════════════════════════

  Widget _buildDailyStatusStrip(bool isDark) {
    final hydration = _dataService.getTodayHydration();

    return BlocBuilder<GamificationBloc, GamificationState>(
      builder: (context, gamState) {
        final userLevel =
            gamState is GamificationLoaded ? gamState.userLevel : null;

        return Row(
          children: [
            // XP pill
            Expanded(
              child: _TapScaleWrapper(
                onTap: () => context.go(AppRoutes.journey),
                child: _StatusPill(
                  icon: userLevel != null
                      ? Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                PremiumTheme.primary,
                                PremiumTheme.primaryDark
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${userLevel.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.star_rounded,
                          size: 18, color: PremiumTheme.primary),
                  label: userLevel?.title ?? 'XP',
                  progress: userLevel?.levelProgress,
                  progressColor: PremiumTheme.primary,
                  isDark: isDark,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Streak pill
            Expanded(
              child: _StatusPill(
                icon: const Text('🔥', style: TextStyle(fontSize: 15)),
                label: _streak.currentStreak > 0
                    ? '${_streak.currentStreak}-day'
                    : 'Start!',
                isDark: isDark,
              ),
            ),

            const SizedBox(width: 8),

            // Hydration pill
            Expanded(
              child: _TapScaleWrapper(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _hydrationExpanded = !_hydrationExpanded);
                },
                child: _StatusPill(
                  icon: const Icon(
                    Icons.water_drop_rounded,
                    size: 16,
                    color: PremiumTheme.info,
                  ),
                  // Typography drama: bigger number, smaller unit
                  valueWidget: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${hydration.glassesDrunk}',
                          style: PremiumTheme.headlineMedium.copyWith(
                            color: isDark
                                ? Colors.white.withOpacity(0.85)
                                : PremiumTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: '/${hydration.targetGlasses}',
                          style: PremiumTheme.labelSmall.copyWith(
                            color: PremiumTheme.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  progress: hydration.progress,
                  progressColor: PremiumTheme.info,
                  isDark: isDark,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 4. REDESIGNED CHECK-IN
  // ════════════════════════════════════════════════════════════════

  Widget _buildCheckInSection(bool isDark) {
    if (_checkedInToday) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: isDark
            ? PremiumTheme.darkPrimarySoft
            : PremiumTheme.successLight,
        blur: isDark ? 8 : 12,
        showBorder: true,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: PremiumTheme.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: PremiumTheme.success, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checked in — thank you 🙏',
                    style: PremiumTheme.headlineSmall.copyWith(
                      color: PremiumTheme.success,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pain ${_pain.round()} · Swallowing ${_swallowing.round()} · Dry Mouth ${_dryMouth.round()}',
                    style: PremiumTheme.bodySmall.copyWith(
                      color: PremiumTheme.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      backgroundColor: isDark ? PremiumTheme.darkCardColor : Colors.white,
      blur: isDark ? 8 : 12,
      borderRadius: 20,
      child: Column(
        children: [
          // Header (tappable to expand/collapse)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _checkInExpanded = !_checkInExpanded);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PremiumTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: PremiumTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How are you feeling right now?',
                          style: PremiumTheme.headlineSmall.copyWith(
                            fontSize: 15,
                            color: isDark
                                ? Colors.white
                                : PremiumTheme.textPrimary,
                          ),
                        ),
                        if (!_checkInExpanded)
                          Text(
                            'Tap to share — it only takes a moment',
                            style: PremiumTheme.bodySmall.copyWith(
                              color: PremiumTheme.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _checkInExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: PremiumTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable emoji selector content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _checkInExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : PremiumTheme.surfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 18),

                  // Pain
                  _EmojiSelector(
                    label: 'Pain',
                    emojis: const ['😊', '🙂', '😐', '😟', '😣'],
                    value: _pain.round(),
                    onChanged: (v) {
                      setState(() => _pain = v.toDouble());
                      _bounceEmoji();
                    },
                    isDark: isDark,
                    bounceAnimation: _emojiBounce,
                  ),

                  const SizedBox(height: 14),

                  // Swallowing
                  _EmojiSelector(
                    label: 'Swallowing',
                    emojis: const ['😣', '😟', '😐', '🙂', '😊'],
                    value: _swallowing.round(),
                    onChanged: (v) {
                      setState(() => _swallowing = v.toDouble());
                      _bounceEmoji();
                    },
                    isDark: isDark,
                    bounceAnimation: _emojiBounce,
                  ),

                  const SizedBox(height: 14),

                  // Dry Mouth
                  _EmojiSelector(
                    label: 'Dry Mouth',
                    emojis: const ['😊', '🙂', '😐', '😟', '😣'],
                    value: _dryMouth.round(),
                    onChanged: (v) {
                      setState(() => _dryMouth = v.toDouble());
                      _bounceEmoji();
                    },
                    isDark: isDark,
                    bounceAnimation: _emojiBounce,
                  ),

                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: PremiumTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: PremiumTheme.primary.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _submitCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save',
                          style: PremiumTheme.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 5. CELEBRATION BANNER
  // ════════════════════════════════════════════════════════════════

  Widget _buildCelebrationBanner(bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        backgroundColor: isDark
            ? PremiumTheme.darkPrimarySoft
            : PremiumTheme.successLight,
        blur: isDark ? 8 : 12,
        child: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      'You showed up today!',
                      style: PremiumTheme.headlineSmall.copyWith(
                        color: PremiumTheme.success,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Session and check-in done — your muscles are getting stronger.',
                    style: PremiumTheme.bodySmall.copyWith(
                      color: PremiumTheme.textSecondary,
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

  // ════════════════════════════════════════════════════════════════
  // SECTION DIVIDER
  // ════════════════════════════════════════════════════════════════

  Widget _buildSectionDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : PremiumTheme.surfaceVariant,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'More for you',
            style: PremiumTheme.labelSmall.copyWith(
              color: PremiumTheme.textTertiary,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : PremiumTheme.surfaceVariant,
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SECONDARY SECTIONS
  // ════════════════════════════════════════════════════════════════

  Widget _buildFoodDiaryLink(bool isDark) {
    final mealCount = getIt<DataSyncService>().todayFoodEntryCount;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: isDark ? PremiumTheme.darkCardColor : Colors.white,
      blur: isDark ? 8 : 12,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: PremiumTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
              child: Text('🍽️', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food diary',
                  style: PremiumTheme.headlineSmall.copyWith(
                    color: isDark ? Colors.white : PremiumTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  mealCount == 0
                      ? 'Track what you\'re eating & how it goes'
                      : '$mealCount meal${mealCount != 1 ? 's' : ''} logged today',
                  style: PremiumTheme.bodySmall.copyWith(
                    color: PremiumTheme.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: PremiumTheme.textTertiary, size: 20),
        ],
      ),
    );
  }

  Widget _buildInsightSection() {
    return BlocBuilder<AIChatBloc, AIChatState>(
      builder: (context, state) {
        if (state is! AIChatReady) return const SizedBox.shrink();
        final insights = state.activeInsights;
        if (insights.isEmpty) return const SizedBox.shrink();

        final insight = insights.first;
        return AIInsightCard(
          insight: insight,
          onDismiss: () {
            context.read<AIChatBloc>().add(DismissInsight(insight.id));
          },
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════

  void _bounceEmoji() {
    _emojiController.forward(from: 0.0);
  }

  Future<void> _submitCheckIn() async {
    HapticFeedback.mediumImpact();
    await _dataService.saveCheckIn(
      painLevel: _pain.round(),
      swallowingEase: _swallowing.round(),
      dryMouth: _dryMouth.round(),
    );
    if (!mounted) return;

    // Trigger confetti burst
    setState(() => _showConfetti = true);
    _confettiController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _showConfetti = false);
    });

    setState(() => _checkedInToday = true);

    // Refresh insights after check-in
    context.read<AIChatBloc>().add(const RefreshInsights());

    // Gamification: grant XP for check-in and check achievements
    final gamBloc = context.read<GamificationBloc>();
    gamBloc.add(const GrantXP(amount: 15, reason: 'Check-in'));

    final totalCheckIns = await _dataService.getTotalCheckInCount();
    if (!mounted) return;
    gamBloc.add(CheckAchievements(
      totalCheckIns: totalCheckIns,
      currentStreak: _streak.currentStreak,
    ));
  }

  void _startExercise() {
    HapticFeedback.mediumImpact();
    context.push(AppRoutes.exercise);
  }

  // ════════════════════════════════════════════════════════════════
  // WEEK IN REVIEW
  // ════════════════════════════════════════════════════════════════

  Future<void> _openWeeklySummary() async {
    HapticFeedback.mediumImpact();

    // Gather data for WeeklyStats
    final weekProgress = await _dataService.getThisWeekProgress();
    final checkIns = await _dataService.getRecentCheckIns(limit: 7);
    final streak = await _dataService.getStreakData();

    final sessionsCompleted =
        weekProgress.where((p) => p.sessionCompleted).length;
    final totalMinutes =
        weekProgress.fold<int>(0, (sum, p) => sum + p.durationMinutes);

    // Compute week start (Monday)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    // Try to get an AI insight from bloc state
    ProactiveInsight? aiInsight;
    if (mounted) {
      final aiState = context.read<AIChatBloc>().state;
      if (aiState is AIChatReady && aiState.activeInsights.isNotEmpty) {
        aiInsight = aiState.activeInsights.first;
      }
    }

    if (!mounted) return;

    final stats = WeeklyStats(
      sessionsCompleted: sessionsCompleted,
      totalMinutes: totalMinutes,
      checkInsLogged: checkIns.length,
      streak: streak,
      checkIns: checkIns,
      aiInsight: aiInsight,
      weekStart: DateTime(weekStart.year, weekStart.month, weekStart.day),
    );

    showWeeklySummary(context, stats);
  }

  Widget _buildWeekInReviewCard(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      backgroundColor: isDark ? PremiumTheme.darkCardColor : Colors.white,
      blur: isDark ? 8 : 12,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PremiumTheme.primary,
                  PremiumTheme.accent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Center(
              child: Text('📊', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your week in review',
                  style: PremiumTheme.headlineSmall.copyWith(
                    color: isDark ? Colors.white : PremiumTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'See your stats, trends & a personal insight',
                  style: PremiumTheme.bodySmall.copyWith(
                    color: PremiumTheme.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : PremiumTheme.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: PremiumTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TAP SCALE WRAPPER — press-to-shrink micro-interaction
// ═══════════════════════════════════════════════════════════════════

class _TapScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _TapScaleWrapper({required this.child, this.onTap});

  @override
  State<_TapScaleWrapper> createState() => _TapScaleWrapperState();
}

class _TapScaleWrapperState extends State<_TapScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════════

/// Compact status pill for the daily strip
class _StatusPill extends StatelessWidget {
  final Widget icon;
  final String? label;
  final Widget? valueWidget;
  final double? progress;
  final Color? progressColor;
  final bool isDark;

  const _StatusPill({
    required this.icon,
    this.label,
    this.valueWidget,
    this.progress,
    this.progressColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : PremiumTheme.surfaceVariant.withOpacity(0.7),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 6),
              Flexible(
                child: valueWidget ??
                    Text(
                      label ?? '',
                      style: PremiumTheme.labelSmall.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.7)
                            : PremiumTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress!),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 3,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.06)
                        : PremiumTheme.surfaceVariant.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation(
                        progressColor ?? PremiumTheme.primary),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Streak badge — floating pill
class _StreakBadge extends StatelessWidget {
  final int days;
  final bool isDark;

  const _StreakBadge({required this.days, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkAccentSoft : PremiumTheme.accentSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PremiumTheme.accent.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            '$days day${days != 1 ? 's' : ''}',
            style: PremiumTheme.labelSmall.copyWith(
              color: PremiumTheme.accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Emoji circle selector — replaces raw slider for check-in
class _EmojiSelector extends StatelessWidget {
  final String label;
  final List<String> emojis;
  final int value; // 1-5
  final ValueChanged<int> onChanged;
  final bool isDark;
  final Animation<double>? bounceAnimation;

  const _EmojiSelector({
    required this.label,
    required this.emojis,
    required this.value,
    required this.onChanged,
    required this.isDark,
    this.bounceAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: PremiumTheme.bodyMedium.copyWith(
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : PremiumTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final level = i + 1;
              final isSelected = value == level;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(level);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 44 : 38,
                  height: isSelected ? 44 : 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? PremiumTheme.symptomScale[i].withOpacity(0.15)
                        : isDark
                            ? Colors.white.withOpacity(0.04)
                            : PremiumTheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(isSelected ? 14 : 12),
                    border: Border.all(
                      color: isSelected
                          ? PremiumTheme.symptomScale[i].withOpacity(0.4)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isSelected && bounceAnimation != null
                        ? ScaleTransition(
                            scale: bounceAnimation!,
                            child: Text(
                              emojis[i],
                              style: const TextStyle(fontSize: 20),
                            ),
                          )
                        : Text(
                            emojis[i],
                            style: TextStyle(
                              fontSize: isSelected ? 20 : 16,
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HERO ILLUSTRATION PAINTER — flowing swallow curves + water drop
// ═══════════════════════════════════════════════════════════════════

class _HeroIllustrationPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _HeroIllustrationPainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final waveShift = animationValue * 2 * math.pi;

    // ── Flowing curve 1 (5% opacity) — large, sweeping ──
    final paint1 = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(0, h * 0.7);
    path1.cubicTo(
      w * 0.25,
      h * (0.5 + 0.06 * math.sin(waveShift)),
      w * 0.55,
      h * (0.3 + 0.04 * math.cos(waveShift + 0.5)),
      w * 1.1,
      h * 0.15,
    );
    canvas.drawPath(path1, paint1);

    // ── Flowing curve 2 (8% opacity) — mid sweep ──
    final paint2 = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path2 = Path();
    path2.moveTo(0, h * 0.85);
    path2.cubicTo(
      w * 0.3,
      h * (0.6 + 0.05 * math.sin(waveShift + 1)),
      w * 0.6,
      h * (0.35 + 0.05 * math.cos(waveShift + 1.5)),
      w * 1.05,
      h * 0.05,
    );
    canvas.drawPath(path2, paint2);

    // ── Flowing curve 3 (12% opacity) — tighter ──
    final paint3 = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final path3 = Path();
    path3.moveTo(w * -0.05, h * 0.95);
    path3.cubicTo(
      w * 0.35,
      h * (0.65 + 0.04 * math.sin(waveShift + 2)),
      w * 0.65,
      h * (0.4 + 0.03 * math.cos(waveShift + 2.5)),
      w,
      h * 0.1,
    );
    canvas.drawPath(path3, paint3);

    // ── Water drop at focal point ──
    final dropCenter = Offset(
      w * 0.78 + 2 * math.sin(waveShift * 0.5),
      h * 0.28 + 2 * math.cos(waveShift * 0.5),
    );
    final dropPaint = Paint()
      ..color = color.withOpacity(0.10)
      ..style = PaintingStyle.fill;

    final dropPath = Path();
    final dropSize = 14.0;
    dropPath.moveTo(dropCenter.dx, dropCenter.dy - dropSize);
    dropPath.cubicTo(
      dropCenter.dx + dropSize * 0.6,
      dropCenter.dy - dropSize * 0.3,
      dropCenter.dx + dropSize * 0.5,
      dropCenter.dy + dropSize * 0.5,
      dropCenter.dx,
      dropCenter.dy + dropSize * 0.6,
    );
    dropPath.cubicTo(
      dropCenter.dx - dropSize * 0.5,
      dropCenter.dy + dropSize * 0.5,
      dropCenter.dx - dropSize * 0.6,
      dropCenter.dy - dropSize * 0.3,
      dropCenter.dx,
      dropCenter.dy - dropSize,
    );
    canvas.drawPath(dropPath, dropPaint);

    // Small highlight on drop
    canvas.drawCircle(
      Offset(dropCenter.dx - 2, dropCenter.dy - 4),
      2.5,
      Paint()..color = color.withOpacity(0.15),
    );
  }

  @override
  bool shouldRepaint(_HeroIllustrationPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.color != color;
}

// ═══════════════════════════════════════════════════════════════════
// CONFETTI PAINTER — burst of colored dots on check-in save
// ═══════════════════════════════════════════════════════════════════

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final double centerX;
  final double centerY;

  static final List<_ConfettiParticle> _particles = List.generate(
    12,
    (i) => _ConfettiParticle(
      angle: (i / 12) * 2 * math.pi + (math.Random(i).nextDouble() * 0.5),
      speed: 60 + math.Random(i).nextDouble() * 80,
      size: 4 + math.Random(i).nextDouble() * 4,
      color: [
        PremiumTheme.primary,
        PremiumTheme.primaryLight,
        PremiumTheme.accent,
        PremiumTheme.success,
        PremiumTheme.info,
      ][i % 5],
    ),
  );

  _ConfettiPainter({
    required this.progress,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1 - progress).clamp(0.0, 1.0);
    if (opacity <= 0) return;

    for (final particle in _particles) {
      final dx = centerX + math.cos(particle.angle) * particle.speed * progress;
      final dy =
          centerY + math.sin(particle.angle) * particle.speed * progress - 20 * progress;
      final r = particle.size * (1 - progress * 0.5);

      canvas.drawCircle(
        Offset(dx, dy),
        r,
        Paint()..color = particle.color.withOpacity(opacity * 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ConfettiParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  const _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}
