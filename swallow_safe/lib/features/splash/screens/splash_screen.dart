import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../../onboarding/bloc/onboarding_bloc.dart';

/// Premium splash screen with staggered choreography,
/// composed logo mark, breathing progress ring, and refined particles.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Staggered entrance controllers ──────────────────────────────
  late AnimationController _bgFadeController;
  late AnimationController _logoController;
  late AnimationController _nameController;
  late AnimationController _taglineController;
  late AnimationController _ringController;

  // ── Looping controllers ─────────────────────────────────────────
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _ringPulseController;
  late AnimationController _ringSweepController;

  // ── Derived animations ──────────────────────────────────────────
  late Animation<double> _bgFade;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _nameFade;
  late Animation<Offset> _nameSlide;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _ringFade;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _initAnimations();
    _startChoreography();
  }

  void _initAnimations() {
    // ── Background fade (0ms, 600ms) ──
    _bgFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bgFade = CurvedAnimation(
      parent: _bgFadeController,
      curve: Curves.easeOut,
    );

    // ── Logo entrance (200ms delay, 1000ms duration) ──
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    // ── App name (700ms delay, 600ms duration) ──
    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _nameFade = CurvedAnimation(
      parent: _nameController,
      curve: Curves.easeOut,
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _nameController,
      curve: Curves.easeOutCubic,
    ));

    // ── Tagline (1000ms delay, 600ms duration) ──
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineFade = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeOut,
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeOutCubic,
    ));

    // ── Progress ring fade-in (1300ms delay, 500ms duration) ──
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ringFade = CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOut,
    );

    // ── Looping: particles ──
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // ── Looping: logo glow pulse (starts after logo entrance) ──
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // ── Looping: ring sweep (arc from 0° → 360°) ──
    _ringSweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // ── Looping: ring breathing pulse ──
    _ringPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  void _startChoreography() {
    // 0ms — background gradient fades in
    _bgFadeController.forward();

    // 200ms — logo scales up
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _logoController.forward();
    });

    // 700ms — app name slides up
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _nameController.forward();
    });

    // 1000ms — tagline slides up
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _taglineController.forward();
    });

    // 1200ms — logo glow starts pulsing
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _glowController.repeat(reverse: true);
    });

    // 1300ms — progress ring fades in
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      _ringController.forward();
      _ringSweepController.repeat();
    });

    // 1800ms — ring starts breathing
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _ringPulseController.repeat(reverse: true);
    });

    // 2200ms — navigate away
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _navigateBasedOnOnboardingStatus();
    });
  }

  void _navigateBasedOnOnboardingStatus() {
    final onboardingState = context.read<OnboardingBloc>().state;

    if (onboardingState is OnboardingComplete) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onboardingWelcome);
    }
  }

  @override
  void dispose() {
    _bgFadeController.dispose();
    _logoController.dispose();
    _nameController.dispose();
    _taglineController.dispose();
    _ringController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _ringSweepController.dispose();
    _ringPulseController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _bgFade,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PremiumTheme.primaryLight,
                PremiumTheme.primary,
                PremiumTheme.primaryDark,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Particle system background
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _ParticlePainter(
                      progress: _particleController.value,
                    ),
                  );
                },
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Composed logo with breathing glow
                    _buildLogo(),

                    const Spacer(flex: 1),

                    // App name — staggered slide-up
                    _buildAppName(),

                    const SizedBox(height: 12),

                    // Tagline — staggered slide-up
                    _buildTagline(),

                    const Spacer(flex: 2),

                    // Breathing progress ring
                    _buildBreathingRing(),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // COMPOSED LOGO MARK
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _glowController]),
      builder: (context, child) {
        final glowOpacity = _glowController.value * 0.15;
        final glowScale = 1.0 + _glowController.value * 0.05;

        return FadeTransition(
          opacity: _logoFade,
          child: Transform.scale(
            scale: _logoScale.value,
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Breathing glow halo
                  Transform.scale(
                    scale: glowScale,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(glowOpacity),
                            blurRadius: 40,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Outer frosted glass ring
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                  ),

                  // Inner frosted disc
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ),

                  // Composed icon: water drop + shield check
                  const SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Primary water drop
                        Icon(
                          Icons.water_drop_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                        // Shield-check badge (bottom-right)
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: _ShieldBadge(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TEXT ELEMENTS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAppName() {
    return SlideTransition(
      position: _nameSlide,
      child: FadeTransition(
        opacity: _nameFade,
        child: Text(
          'SwallowSafe',
          style: PremiumTheme.displayHero.copyWith(
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return SlideTransition(
      position: _taglineSlide,
      child: FadeTransition(
        opacity: _taglineFade,
        child: Text(
          'Every swallow matters',
          style: PremiumTheme.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BREATHING PROGRESS RING
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBreathingRing() {
    return FadeTransition(
      opacity: _ringFade,
      child: AnimatedBuilder(
        animation: Listenable.merge([_ringSweepController, _ringPulseController]),
        builder: (context, child) {
          final breathScale = 1.0 + _ringPulseController.value * 0.08;
          return Transform.scale(
            scale: breathScale,
            child: CustomPaint(
              size: const Size(24, 24),
              painter: _BreathingRingPainter(
                sweep: _ringSweepController.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SHIELD BADGE (stateless, const-constructible)
// ═══════════════════════════════════════════════════════════════════

class _ShieldBadge extends StatelessWidget {
  const _ShieldBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.25),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: const Icon(
        Icons.verified_rounded,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// BREATHING RING PAINTER
// ═══════════════════════════════════════════════════════════════════

class _BreathingRingPainter extends CustomPainter {
  final double sweep;

  _BreathingRingPainter({required this.sweep});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 2.5;

    // Track (translucent white)
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    // Arc sweep (solid white)
    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = sweep * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BreathingRingPainter oldDelegate) {
    return oldDelegate.sweep != sweep;
  }
}

// ═══════════════════════════════════════════════════════════════════
// REFINED PARTICLE PAINTER
// ═══════════════════════════════════════════════════════════════════

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);

    for (int i = 0; i < 18; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final baseRadius = 2.0 + random.nextDouble() * 1.5;
      final speed = 0.3 + random.nextDouble() * 0.7;

      // Animate Y position with looping
      final animatedY =
          (baseY - progress * size.height * speed) % size.height;

      // Gentle horizontal sway
      final sway = math.sin(progress * math.pi * 2 + i) * 15;

      // Soft size oscillation (twinkle)
      final twinkle = 1.0 +
          0.3 * math.sin(progress * math.pi * 4 + i * 1.7);
      final radius = baseRadius * twinkle;

      final opacity = 0.12 + random.nextDouble() * 0.4;
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(baseX + sway, animatedY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
