import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/dimensions.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/premium_theme.dart';

/// Displays the user's current streak with animation - PreHab inspired
class StreakDisplay extends StatefulWidget {
  final int currentStreak;
  final bool animate;

  const StreakDisplay({
    super.key,
    required this.currentStreak,
    this.animate = true,
  });

  @override
  State<StreakDisplay> createState() => _StreakDisplayState();
}

class _StreakDisplayState extends State<StreakDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate && widget.currentStreak > 0) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStreak > 0 && widget.animate) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentStreak > 0;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingCard),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [
                      PremiumTheme.streakActive.withOpacity(0.15),
                      PremiumTheme.accent.withOpacity(0.1),
                    ]
                  : [
                      PremiumTheme.surfaceVariant,
                      PremiumTheme.surfaceVariant,
                    ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: isActive
                  ? PremiumTheme.streakActive.withOpacity(0.3)
                  : PremiumTheme.surfaceVariant,
              width: 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: PremiumTheme.streakActive.withOpacity(
                        _glowAnimation.value * 0.3,
                      ),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : PremiumTheme.cardShadow,
          ),
          child: Row(
            children: [
              // Fire icon with glow
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                decoration: BoxDecoration(
                  color: isActive
                      ? PremiumTheme.streakActive.withOpacity(0.1)
                      : PremiumTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
                ),
                child: ShaderMask(
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
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    size: AppDimensions.iconSizeL,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.spacingM),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.currentStreak,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${widget.currentStreak}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: AppDimensions.fontSizeStatLarge,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? PremiumTheme.streakActive
                                : PremiumTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingS),
                        Text(
                          AppStrings.days,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: PremiumTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trophy for milestones
              if (widget.currentStreak >= 7)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    color: PremiumTheme.premium.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: AppDimensions.iconSizeS,
                    color: PremiumTheme.premium,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Weekly streak dots showing which days were completed - updated design
class WeeklyStreakDots extends StatelessWidget {
  final List<bool> completedDays;

  const WeeklyStreakDots({
    super.key,
    required this.completedDays,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final isCompleted = index < completedDays.length && completedDays[index];
        final isToday = index == today;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: AppDimensions.weekDayRingSize,
              height: AppDimensions.weekDayRingSize,
              decoration: BoxDecoration(
                color: isCompleted ? PremiumTheme.accent : PremiumTheme.surfaceVariant,
                shape: BoxShape.circle,
                border: isToday && !isCompleted
                    ? Border.all(color: PremiumTheme.accent, width: 2)
                    : null,
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: PremiumTheme.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: Colors.white,
                    )
                  : isToday
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: PremiumTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              dayLabels[index],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isToday
                    ? PremiumTheme.accent
                    : isCompleted
                        ? PremiumTheme.textPrimary
                        : PremiumTheme.textTertiary,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }
}
