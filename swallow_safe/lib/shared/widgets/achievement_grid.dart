import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/premium_theme.dart';
import '../../data/models/achievement.dart';

/// Milestone path that replaces the flat achievement grid.
///
/// Visual modes per node:
///   1. **Earned** — full emoji, name, XP badge, glowing circle.
///   2. **Upcoming** (next 2-3) — hint text + mini progress bar, muted.
///   3. **Distant** — small faded dots, no text.
///
/// Auto-scrolls to the first un-earned milestone on load.
class AchievementMilestonePath extends StatefulWidget {
  final List<Achievement> achievements;
  final int totalSessions;
  final int currentStreak;
  final int totalCheckIns;
  final double programProgress;

  const AchievementMilestonePath({
    super.key,
    required this.achievements,
    this.totalSessions = 0,
    this.currentStreak = 0,
    this.totalCheckIns = 0,
    this.programProgress = 0.0,
  });

  @override
  State<AchievementMilestonePath> createState() =>
      _AchievementMilestonePathState();
}

class _AchievementMilestonePathState extends State<AchievementMilestonePath>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawController;
  late Animation<double> _drawAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeOutCubic,
    );
    _drawController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScroll());
  }

  @override
  void dispose() {
    _drawController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll so the first un-earned milestone is near the left edge.
  void _autoScroll() {
    final firstLockedIdx =
        widget.achievements.indexWhere((a) => !a.isUnlocked);
    if (firstLockedIdx <= 0) return;
    // Each node occupies ~_nodeSpacing px in the horizontal list.
    final target = (firstLockedIdx - 1) * _nodeSpacing;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        target.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ── Layout constants ──

  static const double _nodeSpacing = 120.0;
  static const double _pathHeight = 200.0;
  static const int _upcomingCount = 3;

  // ── Helpers ──

  /// Classify each achievement into earned / upcoming / distant.
  _NodeMode _modeFor(int index) {
    final a = widget.achievements[index];
    if (a.isUnlocked) return _NodeMode.earned;

    // Count how many locked ones precede this one.
    int lockedBefore = 0;
    for (int i = 0; i < index; i++) {
      if (!widget.achievements[i].isUnlocked) lockedBefore++;
    }
    return lockedBefore < _upcomingCount
        ? _NodeMode.upcoming
        : _NodeMode.distant;
  }

  /// Sine-wave Y offset for the serpentine path.
  double _yForIndex(int index) {
    const amplitude = 28.0;
    const baseY = _pathHeight / 2;
    return baseY + amplitude * math.sin(index * math.pi / 2.2);
  }

  double get _totalWidth =>
      _nodeSpacing * widget.achievements.length + 48;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final earned =
        widget.achievements.where((a) => a.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Milestones',
              style: PremiumTheme.headlineSmall.copyWith(
                color: isDark ? Colors.white : PremiumTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: earned > 0
                    ? PremiumTheme.primarySoft
                    : (isDark
                        ? Colors.white.withOpacity(0.06)
                        : PremiumTheme.surfaceVariant),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$earned / ${widget.achievements.length}',
                style: PremiumTheme.labelSmall.copyWith(
                  color: earned > 0
                      ? PremiumTheme.primary
                      : PremiumTheme.textTertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            const Spacer(),
            if (earned == 0)
              Text(
                'Keep going — you\'ll unlock these!',
                style: PremiumTheme.bodySmall.copyWith(
                  color: PremiumTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Scrollable milestone path
        SizedBox(
          height: _pathHeight,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedBuilder(
              animation: _drawAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MilestonePathPainter(
                    count: widget.achievements.length,
                    earnedCount: earned,
                    yForIndex: _yForIndex,
                    drawProgress: _drawAnimation.value,
                    isDark: isDark,
                  ),
                  child: child,
                );
              },
              child: SizedBox(
                width: _totalWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (int i = 0; i < widget.achievements.length; i++)
                      _buildNode(i, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNode(int index, bool isDark) {
    final mode = _modeFor(index);
    final a = widget.achievements[index];
    final cx = 24.0 + index * _nodeSpacing;
    final cy = _yForIndex(index);

    switch (mode) {
      case _NodeMode.earned:
        return _EarnedNode(
          achievement: a,
          cx: cx,
          cy: cy,
          delay: Duration(milliseconds: 80 * index),
          isDark: isDark,
        );
      case _NodeMode.upcoming:
        return _UpcomingNode(
          achievement: a,
          cx: cx,
          cy: cy,
          delay: Duration(milliseconds: 80 * index),
          isDark: isDark,
          totalSessions: widget.totalSessions,
          currentStreak: widget.currentStreak,
          totalCheckIns: widget.totalCheckIns,
          programProgress: widget.programProgress,
        );
      case _NodeMode.distant:
        return _DistantNode(
          cx: cx,
          cy: cy,
          delay: Duration(milliseconds: 80 * index),
          isDark: isDark,
        );
    }
  }
}

// ─── Visual modes ───

enum _NodeMode { earned, upcoming, distant }

// ═══════════════════════════════════════════════════════════════════════
// EARNED NODE — full emoji, name, +XP badge
// ═══════════════════════════════════════════════════════════════════════

class _EarnedNode extends StatefulWidget {
  final Achievement achievement;
  final double cx, cy;
  final Duration delay;
  final bool isDark;

  const _EarnedNode({
    required this.achievement,
    required this.cx,
    required this.cy,
    required this.delay,
    required this.isDark,
  });

  @override
  State<_EarnedNode> createState() => _EarnedNodeState();
}

class _EarnedNodeState extends State<_EarnedNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 52.0;

    return Positioned(
      left: widget.cx - size / 2,
      top: widget.cy - size / 2 - 12, // shift up to centre with label
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _showDetail(context);
          },
          child: SizedBox(
            width: _AchievementMilestonePathState._nodeSpacing,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge circle
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PremiumTheme.primarySoft,
                    border: Border.all(
                      color: PremiumTheme.primary.withOpacity(0.4),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PremiumTheme.primary.withOpacity(0.25),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.achievement.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Name
                Text(
                  widget.achievement.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.85)
                        : PremiumTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // XP chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: PremiumTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${widget.achievement.xpReward} XP',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: PremiumTheme.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final a = widget.achievement;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PremiumTheme.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(a.icon, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                a.name,
                style: PremiumTheme.headlineLarge.copyWith(
                  color: widget.isDark ? Colors.white : PremiumTheme.textPrimary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                a.description,
                style: PremiumTheme.bodyMedium.copyWith(
                  color: PremiumTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: PremiumTheme.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${a.xpReward} XP',
                  style: PremiumTheme.labelSmall.copyWith(
                    color: PremiumTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (a.unlockedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Unlocked ${_fmtDate(a.unlockedAt!)}',
                  style: PremiumTheme.bodySmall.copyWith(
                    color: PremiumTheme.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════════
// UPCOMING NODE — hint text + mini progress bar
// ═══════════════════════════════════════════════════════════════════════

class _UpcomingNode extends StatefulWidget {
  final Achievement achievement;
  final double cx, cy;
  final Duration delay;
  final bool isDark;
  final int totalSessions;
  final int currentStreak;
  final int totalCheckIns;
  final double programProgress;

  const _UpcomingNode({
    required this.achievement,
    required this.cx,
    required this.cy,
    required this.delay,
    required this.isDark,
    required this.totalSessions,
    required this.currentStreak,
    required this.totalCheckIns,
    required this.programProgress,
  });

  @override
  State<_UpcomingNode> createState() => _UpcomingNodeState();
}

class _UpcomingNodeState extends State<_UpcomingNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final progress = a.progressFor(
      totalSessions: widget.totalSessions,
      currentStreak: widget.currentStreak,
      totalCheckIns: widget.totalCheckIns,
      programProgress: widget.programProgress,
    );
    final current = a.currentValueFor(
      totalSessions: widget.totalSessions,
      currentStreak: widget.currentStreak,
      totalCheckIns: widget.totalCheckIns,
      programProgress: widget.programProgress,
    );
    const size = 44.0;

    return Positioned(
      left: widget.cx - size / 2,
      top: widget.cy - size / 2 - 12,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: _AchievementMilestonePathState._nodeSpacing,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle with progress ring
              SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark
                            ? Colors.white.withOpacity(0.06)
                            : PremiumTheme.bgWarm,
                        border: Border.all(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.1)
                              : PremiumTheme.surfaceVariant,
                          width: 2,
                        ),
                      ),
                    ),
                    // Progress ring overlay
                    SizedBox(
                      width: size - 4,
                      height: size - 4,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          PremiumTheme.primary.withOpacity(0.6),
                        ),
                      ),
                    ),
                    // Emoji (muted)
                    Opacity(
                      opacity: 0.35,
                      child: Text(
                        a.icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              // Hint text
              Text(
                a.hint.isNotEmpty ? a.hint : a.description,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.5)
                      : PremiumTheme.textTertiary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              // Progress label (e.g. "3 / 7")
              Text(
                '$current / ${a.target}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: PremiumTheme.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DISTANT NODE — small faded dot
// ═══════════════════════════════════════════════════════════════════════

class _DistantNode extends StatefulWidget {
  final double cx, cy;
  final Duration delay;
  final bool isDark;

  const _DistantNode({
    required this.cx,
    required this.cy,
    required this.delay,
    required this.isDark,
  });

  @override
  State<_DistantNode> createState() => _DistantNodeState();
}

class _DistantNodeState extends State<_DistantNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 20.0;

    return Positioned(
      left: widget.cx - size / 2,
      top: widget.cy - size / 2,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark
                ? Colors.white.withOpacity(0.06)
                : PremiumTheme.surfaceVariant.withOpacity(0.6),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.08)
                  : PremiumTheme.textMuted.withOpacity(0.3),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PATH PAINTER — curved connecting line
// ═══════════════════════════════════════════════════════════════════════

class _MilestonePathPainter extends CustomPainter {
  final int count;
  final int earnedCount;
  final double Function(int) yForIndex;
  final double drawProgress;
  final bool isDark;

  _MilestonePathPainter({
    required this.count,
    required this.earnedCount,
    required this.yForIndex,
    required this.drawProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (count < 2) return;

    final spacing = _AchievementMilestonePathState._nodeSpacing;
    final points = <Offset>[];
    for (int i = 0; i < count; i++) {
      final x = 24.0 + i * spacing;
      final y = yForIndex(i);
      points.add(Offset(x, y));
    }

    // Build smooth cubic path
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final c = points[i];
      final n = points[i + 1];
      final cp1 = Offset(c.dx + (n.dx - c.dx) / 2, c.dy);
      final cp2 = Offset(c.dx + (n.dx - c.dx) / 2, n.dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, n.dx, n.dy);
    }

    // 1. Background path (full, muted)
    final bgPaint = Paint()
      ..color = (isDark ? Colors.white : PremiumTheme.textTertiary)
          .withOpacity(0.12)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, bgPaint);

    // 2. Animated draw-in portion
    final metrics = path.computeMetrics().first;
    final animLen = metrics.length * drawProgress;
    final animPath = metrics.extractPath(0, animLen);

    final animPaint = Paint()
      ..color = (isDark ? Colors.white : PremiumTheme.textTertiary)
          .withOpacity(0.06)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(animPath, animPaint);

    // 3. Completed (earned) portion — solid primary
    if (earnedCount > 0 && count > 1) {
      final ratio = (earnedCount - 1) / (count - 1);
      final completedLen = metrics.length * ratio;
      final completedPath = metrics.extractPath(0, completedLen);

      final completedPaint = Paint()
        ..color = PremiumTheme.primary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(completedPath, completedPaint);

      // Glow halo on completed path
      final glowPaint = Paint()
        ..color = PremiumTheme.primary.withOpacity(0.15)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(completedPath, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MilestonePathPainter old) =>
      old.drawProgress != drawProgress ||
      old.earnedCount != earnedCount ||
      old.count != count;
}
