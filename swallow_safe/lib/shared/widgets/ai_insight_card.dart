import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/ai_service.dart';
import '../../core/theme/premium_theme.dart';

/// A calm, inline card that displays a single AI-generated contextual insight.
///
/// Used on the Today and Journey screens. Warm background, subtle icon,
/// optional expansion for details.
class AIInsightCard extends StatefulWidget {
  final ProactiveInsight insight;
  final VoidCallback? onDismiss;

  const AIInsightCard({
    super.key,
    required this.insight,
    this.onDismiss,
  });

  @override
  State<AIInsightCard> createState() => _AIInsightCardState();
}

class _AIInsightCardState extends State<AIInsightCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    HapticFeedback.selectionClick();
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  IconData get _insightIcon {
    switch (widget.insight.type) {
      case InsightType.celebration:
        return Icons.celebration_rounded;
      case InsightType.motivation:
        return Icons.favorite_rounded;
      case InsightType.tip:
        return Icons.lightbulb_rounded;
      case InsightType.warning:
        return Icons.info_outline_rounded;
    }
  }

  Color get _iconColor {
    switch (widget.insight.type) {
      case InsightType.celebration:
        return PremiumTheme.accent;
      case InsightType.motivation:
        return PremiumTheme.primary;
      case InsightType.tip:
        return PremiumTheme.aiPrimary;
      case InsightType.warning:
        return PremiumTheme.warning;
    }
  }

  Color get _bgColor {
    switch (widget.insight.type) {
      case InsightType.celebration:
        return PremiumTheme.accentSoft;
      case InsightType.motivation:
        return PremiumTheme.primarySoft;
      case InsightType.tip:
        return PremiumTheme.aiBackground;
      case InsightType.warning:
        return PremiumTheme.warningLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Insight: ${widget.insight.title}',
      child: GestureDetector(
        onTap: _toggleExpand,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? PremiumTheme.darkCardColor : _bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _iconColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _insightIcon,
                      color: _iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.insight.title,
                      style: PremiumTheme.headlineSmall.copyWith(
                        fontSize: 15,
                        color: isDark ? Colors.white : PremiumTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (widget.onDismiss != null)
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: PremiumTheme.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.insight.message,
                style: PremiumTheme.bodyMedium.copyWith(
                  color: isDark
                      ? Colors.white.withOpacity(0.8)
                      : PremiumTheme.textSecondary,
                  height: 1.5,
                ),
                maxLines: _expanded ? null : 2,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: widget.insight.suggestedQuestion != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : _iconColor)
                                .withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.insight.suggestedQuestion!,
                            style: PremiumTheme.bodySmall.copyWith(
                              color: _iconColor,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
