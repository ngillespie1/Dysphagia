import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../data/models/exercise.dart';

/// The phase of guided exercise execution.
enum _GuidedPhase {
  countdown,   // 3-2-1 before starting
  hold,        // Active hold with timer ring
  rest,        // Rest between reps
  complete,    // All reps finished
}

/// A full-screen guided exercise overlay that replaces the basic "Done" button.
///
/// Flow:  3-2-1 Countdown → Hold Phase (ring fills) → Rest → next rep → … → Complete
/// Supports exercises with [holdDuration] and [reps].
/// Falls back to a simple rep-tap mode when holdDuration is zero.
class GuidedExerciseOverlay extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const GuidedExerciseOverlay({
    super.key,
    required this.exercise,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<GuidedExerciseOverlay> createState() => _GuidedExerciseOverlayState();
}

class _GuidedExerciseOverlayState extends State<GuidedExerciseOverlay>
    with TickerProviderStateMixin {
  _GuidedPhase _phase = _GuidedPhase.countdown;
  int _countdownValue = 3;
  int _currentRep = 0;

  // Countdown tick
  late AnimationController _countdownController;
  late Animation<double> _countdownScale;

  // Hold ring
  late AnimationController _holdController;

  // Rest breathing
  late AnimationController _restController;
  late Animation<double> _breathAnimation;

  // Completion pulse
  late AnimationController _completeController;
  late Animation<double> _completeScale;

  int get _totalReps => widget.exercise.reps;
  Duration get _holdDuration => widget.exercise.holdDuration;
  bool get _isTimedExercise => _holdDuration.inMilliseconds > 0;
  static const _restDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCountdown();
  }

  void _setupAnimations() {
    // Countdown bounce
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _countdownScale = Tween<double>(begin: 1.8, end: 1.0).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.elasticOut),
    );

    // Hold ring fill
    _holdController = AnimationController(
      vsync: this,
      duration: _isTimedExercise ? _holdDuration : const Duration(seconds: 3),
    );
    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onHoldComplete();
      }
    });

    // Rest breathing ring
    _restController = AnimationController(
      vsync: this,
      duration: _restDuration,
    );
    _breathAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _restController, curve: Curves.easeInOut),
    );
    _restController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onRestComplete();
      }
    });

    // Completion celebration
    _completeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _completeScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _completeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _holdController.dispose();
    _restController.dispose();
    _completeController.dispose();
    super.dispose();
  }

  // ── Countdown ──

  void _startCountdown() {
    setState(() {
      _phase = _GuidedPhase.countdown;
      _countdownValue = 3;
    });
    _tickCountdown();
  }

  void _tickCountdown() {
    HapticFeedback.lightImpact();
    _countdownController.forward(from: 0);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_countdownValue > 1) {
        setState(() => _countdownValue--);
        _tickCountdown();
      } else {
        _startHold();
      }
    });
  }

  // ── Hold Phase ──

  void _startHold() {
    setState(() {
      _phase = _GuidedPhase.hold;
      _currentRep++;
    });
    HapticFeedback.mediumImpact();
    _holdController.forward(from: 0);
  }

  void _onHoldComplete() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 80), () {
      HapticFeedback.heavyImpact();
    });

    if (_currentRep >= _totalReps) {
      _startComplete();
    } else {
      _startRest();
    }
  }

  // ── Manual Rep Tap (non-timed exercises) ──

  void _onRepTap() {
    if (_phase != _GuidedPhase.hold) return;
    HapticFeedback.mediumImpact();

    if (_currentRep >= _totalReps) {
      _startComplete();
    } else {
      _startRest();
    }
  }

  // ── Rest Phase ──

  void _startRest() {
    setState(() => _phase = _GuidedPhase.rest);
    _restController.forward(from: 0);
  }

  void _onRestComplete() {
    _startHold();
  }

  // ── Complete ──

  void _startComplete() {
    setState(() => _phase = _GuidedPhase.complete);
    _completeController.forward();
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      HapticFeedback.mediumImpact();
    });

    // Auto-advance after celebration
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _buildPhase(),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case _GuidedPhase.countdown:
        return _buildCountdown();
      case _GuidedPhase.hold:
        return _isTimedExercise ? _buildTimedHold() : _buildTapRep();
      case _GuidedPhase.rest:
        return _buildRest();
      case _GuidedPhase.complete:
        return _buildComplete();
    }
  }

  // ════════════════════════════════════════════════════════
  // COUNTDOWN VIEW
  // ════════════════════════════════════════════════════════

  Widget _buildCountdown() {
    return Center(
      key: const ValueKey('countdown'),
      child: AnimatedBuilder(
        animation: _countdownScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _countdownScale.value,
            child: Opacity(
              opacity: _countdownController.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Get ready…',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTheme.primary.withOpacity(0.15),
                border: Border.all(
                  color: PremiumTheme.primary.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  '$_countdownValue',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // TIMED HOLD VIEW — ring fills over holdDuration
  // ════════════════════════════════════════════════════════

  Widget _buildTimedHold() {
    return Center(
      key: const ValueKey('timed_hold'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rep counter
          _RepBadge(current: _currentRep, total: _totalReps),

          const SizedBox(height: 24),

          // Timer ring
          AnimatedBuilder(
            animation: _holdController,
            builder: (context, _) {
              final remaining = (_holdDuration.inMilliseconds *
                      (1 - _holdController.value)) ~/
                  1000;

              return SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background ring
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: _TimerRingPainter(
                        progress: 1.0,
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 10,
                      ),
                    ),
                    // Progress ring
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: _TimerRingPainter(
                        progress: _holdController.value,
                        color: PremiumTheme.primary,
                        strokeWidth: 10,
                        glow: true,
                      ),
                    ),
                    // Center text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'HOLD',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: PremiumTheme.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${remaining + 1}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'seconds',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Rep progress dots
          _RepProgressDots(current: _currentRep, total: _totalReps),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // TAP REP VIEW — for exercises without holdDuration
  // ════════════════════════════════════════════════════════

  Widget _buildTapRep() {
    return Center(
      key: const ValueKey('tap_rep'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RepBadge(current: _currentRep, total: _totalReps),

          const SizedBox(height: 32),

          // Large tap button
          GestureDetector(
            onTap: _onRepTap,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: PremiumTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: PremiumTheme.primary.withOpacity(0.4),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.touch_app_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TAP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'when done',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          _RepProgressDots(current: _currentRep, total: _totalReps),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // REST VIEW — breathing animation between reps
  // ════════════════════════════════════════════════════════

  Widget _buildRest() {
    return Center(
      key: const ValueKey('rest'),
      child: AnimatedBuilder(
        animation: _breathAnimation,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Take a slow breath',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 32),

              // Breathing ring
              Transform.scale(
                scale: _breathAnimation.value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PremiumTheme.primary.withOpacity(0.08),
                    border: Border.all(
                      color: PremiumTheme.primary.withOpacity(0.25),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PremiumTheme.primary.withOpacity(0.12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.air_rounded,
                          size: 44,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Rest countdown
              AnimatedBuilder(
                animation: _restController,
                builder: (context, _) {
                  final remaining =
                      (_restDuration.inSeconds * (1 - _restController.value))
                          .ceil();
                  return Text(
                    'Next rep in ${remaining}s',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // COMPLETE VIEW
  // ════════════════════════════════════════════════════════

  Widget _buildComplete() {
    return Center(
      key: const ValueKey('complete'),
      child: AnimatedBuilder(
        animation: _completeScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _completeScale.value,
            child: Opacity(
              opacity: _completeScale.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: PremiumTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: PremiumTheme.primary.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nice work!',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_totalReps reps — you crushed it',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ════════════════════════════════════════════════════════════════

class _RepBadge extends StatelessWidget {
  final int current;
  final int total;

  const _RepBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusPill),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
      ),
      child: Text(
        'Rep $current of $total',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _RepProgressDots extends StatelessWidget {
  final int current;
  final int total;

  const _RepProgressDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    // Show max 15 dots; above that, use a progress bar
    if (total > 15) {
      return SizedBox(
        width: 200,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: current / total,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation(PremiumTheme.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$current / $total reps',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      children: List.generate(total, (i) {
        final done = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: done ? 12 : 10,
          height: done ? 12 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? PremiumTheme.primary
                : Colors.white.withOpacity(0.15),
            boxShadow: done
                ? [
                    BoxShadow(
                      color: PremiumTheme.primary.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// TIMER RING PAINTER
// ════════════════════════════════════════════════════════════════

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool glow;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 8,
    this.glow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (glow) {
      // Draw glow behind
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = strokeWidth + 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color;
}
