import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/constants/strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../core/utils/accessibility.dart';
import '../../../shared/widgets/glassmorphic_button.dart';
import '../../../shared/widgets/streak_flame.dart';
import '../../gamification/bloc/gamification_bloc.dart';
import '../bloc/session_bloc.dart';

/// Session complete celebration screen
/// Features confetti particle animation, milestone callout, and stats
class SessionCompleteScreen extends StatefulWidget {
  const SessionCompleteScreen({super.key});

  @override
  State<SessionCompleteScreen> createState() => _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends State<SessionCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Confetti particles
  late List<_ConfettiParticle> _particles;
  final _random = math.Random();

  bool _xpGranted = false;
  bool _didCheckInitialState = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    // Generate confetti particles
    _particles = List.generate(60, (_) => _ConfettiParticle.random(_random));

    _entranceController.forward();
    // Confetti started in didChangeDependencies (needs context for reduced motion check)

    // Celebration haptics
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didCheckInitialState) {
      _didCheckInitialState = true;

      // Start confetti only when reduced motion is off
      if (!A11y.shouldReduceMotion(context)) {
        _confettiController.repeat();
      }

      final state = context.read<SessionBloc>().state;
      if (state is SessionComplete) {
        _grantSessionXP(context, state);
      }
    }
  }

  void _grantSessionXP(BuildContext context, SessionComplete state) {
    if (_xpGranted) return;
    _xpGranted = true;

    final gamBloc = context.read<GamificationBloc>();

    // Grant base session XP
    gamBloc.add(const GrantXP(amount: 30, reason: 'Session complete'));

    // Check achievement milestones
    gamBloc.add(CheckAchievements(
      totalSessions: state.totalSessions,
      currentStreak: state.newStreak,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionComplete) {
          _grantSessionXP(context, state);
        }
      },
      child: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          if (state is SessionComplete) {
            return _buildCompletionView(context, state);
          }

        return Scaffold(
          backgroundColor: PremiumTheme.background,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: PremiumTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                Text(
                  AppStrings.sessionComplete,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppDimensions.spacingXL),
                PrimaryButton(
                  label: 'Back to today',
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, SessionComplete state) {
    final session = state.session;
    final totalSessions = state.totalSessions;

    // Milestone detection — coach voice from centralised constants
    final milestoneText = AppStrings.milestoneForCount(totalSessions);

    return Scaffold(
      backgroundColor: PremiumTheme.background,
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    PremiumTheme.primary.withOpacity(0.06),
                    PremiumTheme.background,
                    PremiumTheme.accent.withOpacity(0.03),
                  ],
                ),
              ),
            ),
          ),

          // Confetti particle system (CustomPainter)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingScreen),
                child: Column(
                  children: [
                    const Spacer(flex: 1),

                    // Success icon with glow
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              PremiumTheme.primary,
                              PremiumTheme.primaryDark,
                            ],
                          ),
                          shape: BoxShape.circle,
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
                    ),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // Title
                    Text(
                      AppStrings.sessionComplete,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingS),

                    Text(
                      AppStrings.greatWork,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),

                    // Milestone callout
                    if (milestoneText != null) ...[
                      const SizedBox(height: AppDimensions.spacingL),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                PremiumTheme.accent.withOpacity(0.12),
                                PremiumTheme.primary.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: PremiumTheme.accent.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏆',
                                  style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  milestoneText,
                                  style: PremiumTheme.bodyMedium.copyWith(
                                    color: PremiumTheme.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.spacingXXL),

                    // Streak display
                    StreakFlame(
                      streakCount: state.newStreak,
                      size: 56,
                    ),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // Session stats
                    _buildStatsRow(context, session),

                    const Spacer(flex: 2),

                    // Action buttons
                    PrimaryButton(
                      label: 'Quick check-in',
                      icon: Icons.edit_note_rounded,
                      onPressed: () {
                        context.read<SessionBloc>().add(const EndSession());
                        context.go(AppRoutes.home);
                      },
                    ),

                    const SizedBox(height: AppDimensions.spacingM),

                    TextButton(
                      onPressed: () {
                        context.read<SessionBloc>().add(const EndSession());
                        context.go(AppRoutes.home);
                      },
                      child: Text(
                        'Back to today',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: PremiumTheme.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingL),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, dynamic session) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      decoration: BoxDecoration(
        color: PremiumTheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: PremiumTheme.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.fitness_center_rounded,
            value: '${session.exercisesCompleted}',
            label: 'Exercises',
            color: PremiumTheme.primary,
          ),
          Container(
            width: 1,
            height: 60,
            color: PremiumTheme.surfaceVariant,
          ),
          _StatItem(
            icon: Icons.timer_rounded,
            value: session.durationDisplay,
            label: 'Duration',
            color: PremiumTheme.info,
          ),
        ],
      ),
    );
  }
}

// ─── Confetti Particle ───

class _ConfettiParticle {
  final double x; // 0..1 horizontal position
  final double speed; // fall speed multiplier
  final double size;
  final double rotation;
  final double rotationSpeed;
  final double drift; // horizontal drift
  final Color color;
  final int shape; // 0=circle, 1=square, 2=rectangle

  _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.drift,
    required this.color,
    required this.shape,
  });

  factory _ConfettiParticle.random(math.Random rng) {
    const colors = [
      PremiumTheme.primary,
      PremiumTheme.primaryLight,
      PremiumTheme.accent,
      PremiumTheme.accentLight,
      PremiumTheme.success,
      PremiumTheme.info,
      Color(0xFFFFD700), // gold
    ];

    return _ConfettiParticle(
      x: rng.nextDouble(),
      speed: 0.3 + rng.nextDouble() * 0.7,
      size: 4.0 + rng.nextDouble() * 6.0,
      rotation: rng.nextDouble() * math.pi * 2,
      rotationSpeed: (rng.nextDouble() - 0.5) * 4,
      drift: (rng.nextDouble() - 0.5) * 0.15,
      color: colors[rng.nextInt(colors.length)],
      shape: rng.nextInt(3),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress; // 0..1 repeating

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed + p.x) % 1.0;
      final y = t * (size.height + 40) - 20;
      final x = p.x * size.width + math.sin(t * math.pi * 4) * p.drift * size.width;

      final opacity = t < 0.1
          ? t / 0.1
          : t > 0.85
              ? (1.0 - t) / 0.15
              : 1.0;

      final paint = Paint()..color = p.color.withOpacity(opacity.clamp(0.0, 0.8));
      final angle = p.rotation + progress * p.rotationSpeed * math.pi * 2;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      switch (p.shape) {
        case 0: // circle
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;
        case 1: // square
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
            paint,
          );
          break;
        case 2: // rectangle (elongated)
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * 0.5,
              height: p.size * 1.5,
            ),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

// ─── Stat Item ───

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingS),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          ),
          child: Icon(
            icon,
            size: AppDimensions.iconSizeS,
            color: color,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: AppDimensions.fontSizeStatMedium,
            fontWeight: FontWeight.bold,
            color: PremiumTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXXS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: PremiumTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
