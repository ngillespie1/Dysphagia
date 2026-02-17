import 'package:flutter/material.dart';

import '../../core/theme/premium_theme.dart';
import '../../data/models/user_level.dart';

/// Animated XP progress bar showing current level and progress to next
class XPProgressBar extends StatelessWidget {
  final UserLevel userLevel;
  final bool compact;

  const XPProgressBar({
    super.key,
    required this.userLevel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (compact) {
      return _buildCompact(isDark);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : PremiumTheme.surfaceVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level + title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PremiumTheme.primary, PremiumTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${userLevel.level}',
                    style: PremiumTheme.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userLevel.title,
                      style: PremiumTheme.headlineSmall.copyWith(
                        color: isDark ? Colors.white : PremiumTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${userLevel.currentXP} / ${userLevel.xpToNext} XP',
                      style: PremiumTheme.labelSmall.copyWith(
                        color: PremiumTheme.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Total XP badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PremiumTheme.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${userLevel.totalXP} XP',
                  style: PremiumTheme.labelSmall.copyWith(
                    color: PremiumTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // XP progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: userLevel.levelProgress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : PremiumTheme.primarySoft,
                  valueColor: const AlwaysStoppedAnimation(PremiumTheme.primary),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(bool isDark) {
    return Row(
      children: [
        // Level badge
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [PremiumTheme.primary, PremiumTheme.primaryDark],
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              '${userLevel.level}',
              style: PremiumTheme.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Title
        Text(
          userLevel.title,
          style: PremiumTheme.labelSmall.copyWith(
            color: isDark ? Colors.white.withOpacity(0.7) : PremiumTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Animated "+XP" toast that pops in and fades
class XPToast extends StatefulWidget {
  final int amount;
  final String? reason;
  final VoidCallback? onDismiss;

  const XPToast({
    super.key,
    required this.amount,
    this.reason,
    this.onDismiss,
  });

  @override
  State<XPToast> createState() => _XPToastState();
}

class _XPToastState extends State<XPToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_controller);

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onDismiss?.call());
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumTheme.primary,
              PremiumTheme.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: PremiumTheme.primary.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              '+${widget.amount} XP',
              style: PremiumTheme.headlineSmall.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            if (widget.reason != null) ...[
              const SizedBox(width: 6),
              Text(
                widget.reason!,
                style: PremiumTheme.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
