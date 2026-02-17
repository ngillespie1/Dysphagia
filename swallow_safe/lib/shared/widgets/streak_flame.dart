import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/dimensions.dart';
import '../../core/theme/premium_theme.dart';

/// Animated streak display with flame icon
/// Shows current streak count with premium styling
class StreakFlame extends StatefulWidget {
  final int streakCount;
  final bool animate;
  final bool showLabel;
  final double? size;

  const StreakFlame({
    super.key,
    required this.streakCount,
    this.animate = true,
    this.showLabel = true,
    this.size,
  });

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate && widget.streakCount > 0) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakFlame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streakCount > 0 && widget.animate) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.streakCount > 0;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flame with glow
            Transform.scale(
              scale: isActive ? _scaleAnimation.value : 1.0,
              child: Container(
                decoration: isActive
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: PremiumTheme.streakActive.withOpacity(
                              _glowAnimation.value,
                            ),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      )
                    : null,
                child: _FlameIcon(
                  size: widget.size ?? 48,
                  isActive: isActive,
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacingS),
            
            // Streak count
            Text(
              '${widget.streakCount}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: widget.size != null
                    ? widget.size! * 0.6
                    : AppDimensions.fontSizeStatMedium,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? PremiumTheme.streakActive
                    : PremiumTheme.textTertiary,
              ),
            ),
            
            // Label
            if (widget.showLabel)
              Text(
                widget.streakCount == 1 ? 'day streak' : 'day streak',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PremiumTheme.textSecondary,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FlameIcon extends StatelessWidget {
  final double size;
  final bool isActive;

  const _FlameIcon({
    required this.size,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        if (isActive) {
          return const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFFFF6B35), // Orange at bottom
              Color(0xFFFFD700), // Yellow at top
            ],
          ).createShader(bounds);
        }
        return LinearGradient(
          colors: [
            PremiumTheme.textTertiary,
            PremiumTheme.textTertiary,
          ],
        ).createShader(bounds);
      },
      child: Icon(
        Icons.local_fire_department_rounded,
        size: size,
        color: Colors.white,
      ),
    );
  }
}

/// Compact streak badge for header
class StreakBadge extends StatelessWidget {
  final int streakCount;

  const StreakBadge({
    super.key,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = streakCount > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? PremiumTheme.streakActive.withOpacity(0.1)
            : PremiumTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusPill),
        boxShadow: isActive ? PremiumTheme.cardShadow : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              if (isActive) {
                return const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFFFF6B35),
                    Color(0xFFFFD700),
                  ],
                ).createShader(bounds);
              }
              return LinearGradient(
                colors: [
                  PremiumTheme.textTertiary,
                  PremiumTheme.textTertiary,
                ],
              ).createShader(bounds);
            },
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingXS),
          Text(
            '$streakCount',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? PremiumTheme.streakActive
                  : PremiumTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
