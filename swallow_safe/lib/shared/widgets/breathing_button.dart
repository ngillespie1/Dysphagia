import 'package:flutter/material.dart';
import '../../core/theme/premium_theme.dart';

/// Play button with slow breathing/pulsing animation to draw attention
class BreathingPlayButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final double size;
  
  const BreathingPlayButton({
    super.key,
    this.onPressed,
    this.size = 64,
  });

  @override
  State<BreathingPlayButton> createState() => _BreathingPlayButtonState();
}

class _BreathingPlayButtonState extends State<BreathingPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _shadowAnimation = Tween<double>(
      begin: 16,
      end: 28,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.4),
                    blurRadius: _shadowAnimation.value,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: widget.size * 0.55,
                  color: PremiumTheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Primary CTA button with subtle glow animation
class AnimatedCTAButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  
  const AnimatedCTAButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  State<AnimatedCTAButton> createState() => _AnimatedCTAButtonState();
}

class _AnimatedCTAButtonState extends State<AnimatedCTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glowOpacity = 0.15 + (_controller.value * 0.15);
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PremiumTheme.radiusM),
            boxShadow: [
              BoxShadow(
                color: PremiumTheme.primary.withOpacity(glowOpacity),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: PremiumTheme.primaryButton,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20),
                  const SizedBox(width: PremiumTheme.spacingM),
                ],
                Text(widget.label),
              ],
            ),
          ),
        );
      },
    );
  }
}
