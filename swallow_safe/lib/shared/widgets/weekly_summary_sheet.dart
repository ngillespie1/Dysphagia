import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/ai_service.dart';
import '../../core/theme/premium_theme.dart';
import '../../data/models/check_in.dart';
import '../../data/models/streak_data.dart';

/// Data model for a week's aggregated stats.
class WeeklyStats {
  final int sessionsCompleted;
  final int totalMinutes;
  final int checkInsLogged;
  final StreakInfo streak;
  final List<CheckIn> checkIns; // This week's check-ins
  final ProactiveInsight? aiInsight;
  final DateTime weekStart;

  const WeeklyStats({
    required this.sessionsCompleted,
    required this.totalMinutes,
    required this.checkInsLogged,
    required this.streak,
    required this.checkIns,
    this.aiInsight,
    required this.weekStart,
  });

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  String get weekLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[weekStart.month - 1]} ${weekStart.day}'
        ' – ${months[weekEnd.month - 1]} ${weekEnd.day}';
  }

  /// Average pain level across check-ins (lower is better).
  double get avgPain =>
      checkIns.isEmpty ? 0 : checkIns.map((c) => c.painLevel).reduce((a, b) => a + b) / checkIns.length;

  /// Average swallowing ease (lower is better).
  double get avgSwallowing =>
      checkIns.isEmpty ? 0 : checkIns.map((c) => c.swallowingEase).reduce((a, b) => a + b) / checkIns.length;

  /// Simple trend: compare first-half avg to second-half avg.
  String trendForValues(List<double> values) {
    if (values.length < 3) return 'Stable';
    final mid = values.length ~/ 2;
    final recent = values.sublist(mid).reduce((a, b) => a + b) / (values.length - mid);
    final older = values.sublist(0, mid).reduce((a, b) => a + b) / mid;
    final diff = recent - older;
    if (diff < -0.3) return 'Improving';
    if (diff > 0.3) return 'Needs attention';
    return 'Stable';
  }

  /// Shareable text summary.
  String toShareText() {
    final buf = StringBuffer();
    buf.writeln('📊 My SwallowSafe Weekly Summary');
    buf.writeln('   $weekLabel\n');
    buf.writeln('💪 Sessions completed: $sessionsCompleted');
    buf.writeln('⏱ Total exercise time: $totalMinutes min');
    buf.writeln('🔥 Current streak: ${streak.currentStreak} days');
    buf.writeln('📋 Check-ins logged: $checkInsLogged');
    if (checkIns.isNotEmpty) {
      buf.writeln('\nSymptom averages:');
      buf.writeln('  Comfort: ${avgPain.toStringAsFixed(1)} / 5');
      buf.writeln('  Swallowing: ${avgSwallowing.toStringAsFixed(1)} / 5');
    }
    if (aiInsight != null) {
      buf.writeln('\n💡 ${aiInsight!.title}');
      buf.writeln('   ${aiInsight!.message}');
    }
    buf.writeln('\n— Shared from SwallowSafe');
    return buf.toString();
  }
}

/// A modal bottom sheet showing this week's exercise stats, symptom trends,
/// an optional AI insight, and a share button.
///
/// Launch with [showWeeklySummary].
class WeeklySummarySheet extends StatelessWidget {
  final WeeklyStats stats;

  const WeeklySummarySheet({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: PremiumTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Week in Review',
                      style: PremiumTheme.headlineLarge.copyWith(
                        color: isDark ? Colors.white : PremiumTheme.textPrimary,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stats.weekLabel,
                      style: PremiumTheme.bodySmall.copyWith(
                        color: PremiumTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Share button
              _ShareButton(
                onTap: () => _shareWeek(context),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats grid
          _StatsRow(stats: stats, isDark: isDark),

          const SizedBox(height: 20),

          // Symptom trend
          if (stats.checkIns.isNotEmpty) ...[
            _SymptomTrend(stats: stats, isDark: isDark),
            const SizedBox(height: 20),
          ],

          // AI Insight
          if (stats.aiInsight != null) ...[
            _InlineInsight(insight: stats.aiInsight!, isDark: isDark),
            const SizedBox(height: 20),
          ],

          // Encouragement
          _EncouragementBanner(stats: stats, isDark: isDark),
        ],
      ),
    );
  }

  void _shareWeek(BuildContext context) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: stats.toShareText()));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Weekly summary copied — share it with your team!'),
        backgroundColor: PremiumTheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Stats Row ───

class _StatsRow extends StatelessWidget {
  final WeeklyStats stats;
  final bool isDark;

  const _StatsRow({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          icon: Icons.fitness_center_rounded,
          iconColor: PremiumTheme.primary,
          value: '${stats.sessionsCompleted}',
          label: 'Sessions',
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatTile(
          icon: Icons.timer_rounded,
          iconColor: PremiumTheme.accent,
          value: '${stats.totalMinutes}',
          label: 'Minutes',
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatTile(
          icon: Icons.local_fire_department_rounded,
          iconColor: PremiumTheme.warning,
          value: '${stats.streak.currentStreak}',
          label: 'Day streak',
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatTile(
          icon: Icons.checklist_rounded,
          iconColor: PremiumTheme.success,
          value: '${stats.checkInsLogged}',
          label: 'Check-ins',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : iconColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: PremiumTheme.headlineLarge.copyWith(
                fontSize: 20,
                color: isDark ? Colors.white : PremiumTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: PremiumTheme.labelSmall.copyWith(
                fontSize: 10,
                color: PremiumTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Symptom Trend ───

class _SymptomTrend extends StatelessWidget {
  final WeeklyStats stats;
  final bool isDark;

  const _SymptomTrend({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final painValues = stats.checkIns.map((c) => c.painLevel.toDouble()).toList();
    final swallowValues = stats.checkIns.map((c) => c.swallowingEase.toDouble()).toList();
    final painTrend = stats.trendForValues(painValues);
    final swallowTrend = stats.trendForValues(swallowValues);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : PremiumTheme.bgWarm,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How you\'re trending',
            style: PremiumTheme.headlineSmall.copyWith(
              color: isDark ? Colors.white : PremiumTheme.textPrimary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _TrendPill(label: 'Comfort', trend: painTrend, lowerIsBetter: true, isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(child: _TrendPill(label: 'Swallowing', trend: swallowTrend, lowerIsBetter: true, isDark: isDark)),
            ],
          ),
          if (stats.checkIns.length >= 3) ...[
            const SizedBox(height: 12),
            // Mini sparkline row
            SizedBox(
              height: 32,
              child: CustomPaint(
                size: const Size(double.infinity, 32),
                painter: _MiniSparklinePainter(
                  painValues: painValues,
                  swallowValues: swallowValues,
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  final String label;
  final String trend;
  final bool lowerIsBetter;
  final bool isDark;

  const _TrendPill({
    required this.label,
    required this.trend,
    required this.lowerIsBetter,
    required this.isDark,
  });

  Color get _color {
    if (trend == 'Improving') return PremiumTheme.success;
    if (trend == 'Needs attention') return PremiumTheme.warning;
    return PremiumTheme.textTertiary;
  }

  IconData get _icon {
    if (trend == 'Improving') return Icons.trending_down_rounded;
    if (trend == 'Needs attention') return Icons.trending_up_rounded;
    return Icons.trending_flat_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(_icon, size: 16, color: _color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PremiumTheme.labelSmall.copyWith(
                    fontSize: 10,
                    color: PremiumTheme.textTertiary,
                  ),
                ),
                Text(
                  trend,
                  style: PremiumTheme.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  final List<double> painValues;
  final List<double> swallowValues;
  final bool isDark;

  _MiniSparklinePainter({
    required this.painValues,
    required this.swallowValues,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawLine(canvas, size, painValues, PremiumTheme.error);
    _drawLine(canvas, size, swallowValues, PremiumTheme.primary);
  }

  void _drawLine(Canvas canvas, Size size, List<double> values, Color color) {
    if (values.length < 2) return;
    const maxVal = 5.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - (values[i] / maxVal) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter old) =>
      old.painValues != painValues || old.swallowValues != swallowValues;
}

// ─── AI Insight ───

class _InlineInsight extends StatelessWidget {
  final ProactiveInsight insight;
  final bool isDark;

  const _InlineInsight({required this.insight, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? PremiumTheme.darkCardColor
            : PremiumTheme.aiBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PremiumTheme.aiPrimary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: PremiumTheme.aiPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: PremiumTheme.aiPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Coach's Insight",
                  style: PremiumTheme.labelSmall.copyWith(
                    color: PremiumTheme.aiPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.title,
                  style: PremiumTheme.headlineSmall.copyWith(
                    color: isDark ? Colors.white : PremiumTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: PremiumTheme.bodySmall.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : PremiumTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Encouragement ───

class _EncouragementBanner extends StatelessWidget {
  final WeeklyStats stats;
  final bool isDark;

  const _EncouragementBanner({required this.stats, required this.isDark});

  String get _message {
    if (stats.sessionsCompleted >= 5) {
      return 'What an incredible week! You showed up almost every day. 🎉';
    }
    if (stats.sessionsCompleted >= 3) {
      return 'Solid week — you\'re building real momentum. Keep it up! 💪';
    }
    if (stats.sessionsCompleted >= 1) {
      return 'You made time for your recovery this week. That matters. 🌱';
    }
    return 'Every week is a fresh start. You\'ve got this! 💛';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? PremiumTheme.darkHeroGradient : PremiumTheme.heroGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        _message,
        style: PremiumTheme.bodyMedium.copyWith(
          color: Colors.white,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─── Share Button ───

class _ShareButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _ShareButton({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Share weekly summary',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : PremiumTheme.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.share_rounded,
                size: 16,
                color: PremiumTheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Share',
                style: PremiumTheme.labelSmall.copyWith(
                  color: PremiumTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Launcher ───

/// Show the weekly summary as a modal bottom sheet.
///
/// Call from any screen that has access to [WeeklyStats].
void showWeeklySummary(BuildContext context, WeeklyStats stats) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => WeeklySummarySheet(stats: stats),
  );
}
