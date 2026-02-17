import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/premium_theme.dart';

/// AI Companion orb state
enum OrbState {
  idle,
  greeting,
  speaking,
  celebrating,
}

/// Animated AI companion orb with gradient glow and pulse effects
class AIOrb extends StatefulWidget {
  final OrbState state;
  final double size;
  final VoidCallback? onTap;

  const AIOrb({
    super.key,
    this.state = OrbState.idle,
    this.size = 120,
    this.onTap,
  });

  @override
  State<AIOrb> createState() => _AIOrbState();
}

class _AIOrbState extends State<AIOrb> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _rippleController;
  late AnimationController _particleController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    // Breathing pulse (2 second cycle)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Gradient rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _rotationController,
    );

    // Ripple effect for speaking
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rippleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Particle burst for celebrating
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _updateStateAnimations();
  }

  @override
  void didUpdateWidget(AIOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateStateAnimations();
    }
  }

  void _updateStateAnimations() {
    switch (widget.state) {
      case OrbState.idle:
        _rippleController.stop();
        _particleController.stop();
        break;
      case OrbState.greeting:
        _rippleController.forward(from: 0);
        break;
      case OrbState.speaking:
        _rippleController.repeat();
        break;
      case OrbState.celebrating:
        _particleController.forward(from: 0);
        _rippleController.forward(from: 0);
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _rippleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size * 1.5,
        height: widget.size * 1.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow layer
            _buildGlow(),

            // Ripple effects
            if (widget.state == OrbState.speaking ||
                widget.state == OrbState.greeting ||
                widget.state == OrbState.celebrating)
              _buildRipples(),

            // Main orb
            _buildOrb(),

            // Particle effects for celebration
            if (widget.state == OrbState.celebrating) _buildParticles(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * 1.3 * _pulseAnimation.value,
          height: widget.size * 1.3 * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: PremiumTheme.primary.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: PremiumTheme.aiPrimary.withOpacity(0.2),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRipples() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // First ripple
            _RippleCircle(
              size: widget.size * (1 + _rippleAnimation.value * 0.5),
              opacity: (1 - _rippleAnimation.value) * 0.4,
              color: PremiumTheme.primary,
            ),
            // Second ripple (delayed)
            if (_rippleAnimation.value > 0.3)
              _RippleCircle(
                size: widget.size *
                    (1 + (_rippleAnimation.value - 0.3) * 0.7 * 0.5),
                opacity: (1 - (_rippleAnimation.value - 0.3) / 0.7) * 0.3,
                color: PremiumTheme.aiPrimary,
              ),
          ],
        );
      },
    );
  }

  Widget _buildOrb() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                transform: GradientRotation(_rotationAnimation.value),
                colors: const [
                  Color(0xFF7ECEC1), // Mint
                  Color(0xFF88C4E8), // Sky blue
                  Color(0xFF9B8FE8), // Lavender
                  Color(0xFFB8AFF0), // Light lavender
                  Color(0xFF7ECEC1), // Back to mint
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: PremiumTheme.primary.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                  center: const Alignment(-0.3, -0.3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size * 1.5, widget.size * 1.5),
          painter: _ParticlePainter(
            progress: _particleController.value,
            particleCount: 12,
          ),
        );
      },
    );
  }
}

class _RippleCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;

  const _RippleCircle({
    required this.size,
    required this.opacity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(opacity),
          width: 2,
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final int particleCount;

  _ParticlePainter({
    required this.progress,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final particleProgress = (progress + i * 0.05).clamp(0.0, 1.0);
      final radius = maxRadius * particleProgress * 0.8;
      final opacity = (1 - particleProgress) * 0.8;

      if (opacity <= 0) continue;

      final particleSize = 4 * (1 - particleProgress * 0.5);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      final paint = Paint()
        ..color = (i % 2 == 0 ? PremiumTheme.primary : PremiumTheme.aiPrimary)
            .withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Compact orb for inline use
class AICompactOrb extends StatelessWidget {
  final double size;
  final bool isActive;

  const AICompactOrb({
    super.key,
    this.size = 40,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7ECEC1),
            Color(0xFF9B8FE8),
          ],
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: PremiumTheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withOpacity(0.6),
              Colors.transparent,
            ],
            center: const Alignment(-0.3, -0.3),
          ),
        ),
      ),
    );
  }
}
