import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/dimensions.dart';
import '../../core/theme/premium_theme.dart';

/// Clean stat card with large number and subtle styling
/// PreHab-inspired metric display
class StatsCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color? valueColor;
  final String? trend; // e.g., "+5" or "-2"
  final bool isTrendPositive;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.trend,
    this.isTrendPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingCard),
        decoration: BoxDecoration(
          color: PremiumTheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: PremiumTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and trend row
            if (icon != null || trend != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (icon != null)
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingS),
                      decoration: BoxDecoration(
                        color: (iconColor ?? PremiumTheme.accent).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
                      ),
                      child: Icon(
                        icon,
                        size: AppDimensions.iconSizeS,
                        color: iconColor ?? PremiumTheme.accent,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingS,
                        vertical: AppDimensions.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: isTrendPositive
                            ? PremiumTheme.successLight
                            : PremiumTheme.errorLight,
                        borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTrendPositive
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 12,
                            color: isTrendPositive
                                ? PremiumTheme.success
                                : PremiumTheme.error,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            trend!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isTrendPositive
                                  ? PremiumTheme.success
                                  : PremiumTheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            
            if (icon != null || trend != null)
              const SizedBox(height: AppDimensions.spacingM),
            
            // Large value
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: AppDimensions.fontSizeStatLarge,
                fontWeight: FontWeight.bold,
                color: valueColor ?? PremiumTheme.textPrimary,
                letterSpacing: -1,
                height: 1.0,
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacingXS),
            
            // Label
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PremiumTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact horizontal stat for inline display
class StatInline extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  const StatInline({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: AppDimensions.iconSizeS,
            color: color ?? PremiumTheme.accent,
          ),
          const SizedBox(width: AppDimensions.spacingS),
        ],
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: AppDimensions.fontSizeStatSmall,
            fontWeight: FontWeight.bold,
            color: color ?? PremiumTheme.textPrimary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingXS),
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

/// Large hero stat for prominent display (e.g., streak count)
class StatHero extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  final Widget? icon;

  const StatHero({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(height: AppDimensions.spacingM),
        ],
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: AppDimensions.fontSizeStatHero,
            fontWeight: FontWeight.bold,
            color: color ?? PremiumTheme.textPrimary,
            letterSpacing: -2,
            height: 1.0,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: PremiumTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
