import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../shared/widgets/glass_card.dart';

/// Premium welcome screen with glassmorphic feature cards
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PremiumTheme.primaryLight,
                PremiumTheme.primary,
                PremiumTheme.primaryDark,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating particles
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _FloatingParticlesPainter(
                      progress: _particleController.value,
                    ),
                  );
                },
              ),

              // Content
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),

                        // Logo
                        _buildLogo(),

                        const SizedBox(height: 32),

                        // App name
                        Text(
                          'SwallowSafe',
                          style: PremiumTheme.displayLarge.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Your personal recovery companion',
                          style: PremiumTheme.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const Spacer(flex: 1),

                        // Feature cards
                        _buildFeatureCard(
                          Icons.play_circle_outline_rounded,
                          'Guided Exercises',
                          'Expert-designed video tutorials',
                          0,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons.timeline_rounded,
                          'Track Progress',
                          'Monitor your recovery journey',
                          1,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons.medical_services_outlined,
                          'Care Team Reports',
                          'Share progress with your doctor',
                          2,
                        ),

                        const Spacer(flex: 2),

                        // Get Started button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              context.go(AppRoutes.onboardingName);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: PremiumTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Get Started',
                              style: PremiumTheme.button,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sign in link
                        TextButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            context.go(AppRoutes.onboardingName);
                          },
                          child: Text(
                            'Already have an account? Sign in',
                            style: PremiumTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.water_drop_rounded,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + index * 100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PremiumTheme.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: PremiumTheme.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
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
}

class _FloatingParticlesPainter extends CustomPainter {
  final double progress;

  _FloatingParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(123);

    for (int i = 0; i < 20; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final radius = 2 + random.nextDouble() * 4;

      final phase = progress * 2 * math.pi + i * 0.5;
      final sway = math.sin(phase) * 20;
      final verticalMove = math.cos(phase * 0.5) * 30;

      final paint = Paint()
        ..color = Colors.white.withOpacity(0.1 + random.nextDouble() * 0.15)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(baseX + sway, baseY + verticalMove),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
