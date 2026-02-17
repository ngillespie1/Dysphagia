import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/premium_theme.dart';

/// Animated flame icon with pulsing glow for streak visualization
class AnimatedStreakFlame extends StatefulWidget {
  final int streakDays;
  final double size;
  
  const AnimatedStreakFlame({
    super.key,
    required this.streakDays,
    this.size = 48,
  });

  @override
  State<AnimatedStreakFlame> createState() => _AnimatedStreakFlameState();
}

class _AnimatedStreakFlameState extends State<AnimatedStreakFlame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.streakDays > 0;
    final flameColor = isActive ? PremiumTheme.warning : PremiumTheme.textTertiary;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: isActive ? _pulseAnimation.value : 1.0,
          child: Container(
            width: widget.size + 20,
            height: widget.size + 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: flameColor.withOpacity(_glowAnimation.value),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: flameColor.withOpacity(_glowAnimation.value * 0.5),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow layer
                  if (isActive)
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: widget.size + 8,
                      color: flameColor.withOpacity(0.3),
                    ),
                  // Main flame
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: widget.size,
                    color: flameColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Streak counter with animated flame and count
class StreakCounter extends StatelessWidget {
  final int streakDays;
  
  const StreakCounter({
    super.key,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedStreakFlame(
          streakDays: streakDays,
          size: 36,
        ),
        const SizedBox(height: PremiumTheme.spacingS),
        Text(
          '$streakDays',
          style: PremiumTheme.headlineLarge.copyWith(
            color: streakDays > 0 
                ? PremiumTheme.textPrimary 
                : PremiumTheme.textTertiary,
          ),
        ),
        Text(
          streakDays == 1 ? 'day' : 'days',
          style: PremiumTheme.bodySmall,
        ),
      ],
    );
  }
}
