import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/premium_theme.dart';
import '../../data/models/educational_tip.dart';

/// Tip-of-the-day card with category icon, title, and expandable body.
/// Shows a fresh educational tip each day.
class TipOfDayCard extends StatefulWidget {
  final EducationalTip? tip;

  const TipOfDayCard({super.key, this.tip});

  @override
  State<TipOfDayCard> createState() => _TipOfDayCardState();
}

class _TipOfDayCardState extends State<TipOfDayCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late EducationalTip _tip;

  @override
  void initState() {
    super.initState();
    _tip = widget.tip ?? EducationalTipLibrary.tipOfTheDay();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _expanded = !_expanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
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
            // Header row: category badge + title + chevron
            Row(
              children: [
                // Category icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? PremiumTheme.primary.withOpacity(0.15)
                        : PremiumTheme.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _tip.category.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good to Know',
                        style: PremiumTheme.labelSmall.copyWith(
                          color: PremiumTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _tip.title,
                        style: PremiumTheme.headlineSmall.copyWith(
                          color: isDark
                              ? Colors.white
                              : PremiumTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: PremiumTheme.textTertiary,
                    size: 22,
                  ),
                ),
              ],
            ),

            // Expandable body
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tip.body,
                      style: PremiumTheme.bodyMedium.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.75)
                            : PremiumTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    if (_tip.source != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '— ${_tip.source}',
                        style: PremiumTheme.labelSmall.copyWith(
                          color: PremiumTheme.textTertiary,
                          fontStyle: FontStyle.italic,
                          fontSize: 10,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Category pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? PremiumTheme.primary.withOpacity(0.1)
                            : PremiumTheme.bgWarm,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _tip.category.label,
                        style: PremiumTheme.labelSmall.copyWith(
                          color: PremiumTheme.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
