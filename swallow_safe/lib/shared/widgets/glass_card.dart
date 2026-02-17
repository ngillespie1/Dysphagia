import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/premium_theme.dart';

/// Premium glassmorphic card with blur, gradient overlay, and layered shadows
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double blur;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final double borderRadius;
  final bool showBorder;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.blur = 12,
    this.backgroundColor,
    this.shadows,
    this.borderRadius = PremiumTheme.radiusL,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows ?? PremiumTheme.glassShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (backgroundColor ?? Colors.white).withOpacity(0.85),
                    (backgroundColor ?? Colors.white).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: showBorder
                    ? Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1,
                      )
                    : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    // Wrap interactive cards with Semantics for accessibility
    if (onTap != null) {
      return Semantics(button: true, child: card);
    }
    return card;
  }
}

/// Hero card with gradient background and glow effect
class HeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  final double borderRadius;
  final VoidCallback? onTap;

  const HeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.borderRadius = PremiumTheme.radiusXL,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient ?? PremiumTheme.heroGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: PremiumTheme.heroShadow,
        ),
        child: child,
      ),
    );

    if (onTap != null) {
      return Semantics(button: true, child: card);
    }
    return card;
  }
}

/// Subtle elevated card for secondary content
class ElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const ElevatedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = PremiumTheme.radiusM,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: PremiumTheme.cardWhite,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: PremiumTheme.softShadow,
        ),
        child: child,
      ),
    );
  }
}

/// Accent colored card with gradient background (for summaries/CTAs)
class AccentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const AccentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = PremiumTheme.radiusXL,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient ?? PremiumTheme.heroGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: PremiumTheme.heroShadow,
        ),
        child: child,
      ),
    );
  }
}

/// Premium styled card with border and shadow
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool selected;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = PremiumTheme.radiusL,
    this.backgroundColor,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? PremiumTheme.cardWhite,
          borderRadius: BorderRadius.circular(borderRadius),
          border: selected 
              ? Border.all(color: PremiumTheme.primary, width: 2)
              : Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          boxShadow: selected 
              ? PremiumTheme.accentGlow 
              : PremiumTheme.softShadow,
        ),
        child: child,
      ),
    );
  }
}
