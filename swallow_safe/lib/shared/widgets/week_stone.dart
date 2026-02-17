import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/premium_theme.dart';
import '../../core/models/program_week.dart';

/// Interactive stepping stone marker for the journey timeline
/// Supports tap to expand, showing week details inline
class WeekStone extends StatefulWidget {
  final ProgramWeek week;
  final bool isCurrent;
  final bool isExpanded;
  final Alignment alignment;
  final VoidCallback? onTap;
  final VoidCallback? onContinue;

  const WeekStone({
    super.key,
    required this.week,
    this.isCurrent = false,
    this.isExpanded = false,
    this.alignment = Alignment.centerLeft,
    this.onTap,
    this.onContinue,
  });

  @override
  State<WeekStone> createState() => _WeekStoneState();
}

class _WeekStoneState extends State<WeekStone>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isCurrent) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(WeekStone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isCurrent && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLeft = widget.alignment == Alignment.centerLeft;
    final isAccessible = widget.week.status.isAccessible;

    return GestureDetector(
      onTap: isAccessible
          ? () {
              HapticFeedback.selectionClick();
              widget.onTap?.call();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          left: isLeft ? 0 : 60,
          right: isLeft ? 60 : 0,
        ),
        child: Column(
          crossAxisAlignment:
              isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            // Stone with label
            Row(
              mainAxisAlignment:
                  isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (!isLeft) _buildLabel(),
                if (!isLeft) const SizedBox(width: 16),
                _buildStone(),
                if (isLeft) const SizedBox(width: 16),
                if (isLeft) _buildLabel(),
              ],
            ),

            // Expanded content
            if (widget.isExpanded) _buildExpandedContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildStone() {
    final status = widget.week.status;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isCurrent ? _scaleAnimation.value : 1.0,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getBackgroundColor(status),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getBorderColor(status),
                width: widget.isCurrent ? 3 : 2,
              ),
              boxShadow: [
                if (widget.isCurrent)
                  BoxShadow(
                    color: PremiumTheme.primary.withOpacity(_glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: _buildStoneContent(status)),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(WeekStatus status) {
    switch (status) {
      case WeekStatus.completed:
        return PremiumTheme.primary;
      case WeekStatus.inProgress:
        return PremiumTheme.primaryLight;
      case WeekStatus.available:
        return Colors.white;
      case WeekStatus.locked:
        return const Color(0xFFF2F2F7);
    }
  }

  Color _getBorderColor(WeekStatus status) {
    if (widget.isCurrent) return PremiumTheme.primary;
    switch (status) {
      case WeekStatus.completed:
        return PremiumTheme.primaryDark;
      case WeekStatus.inProgress:
        return PremiumTheme.primary;
      case WeekStatus.available:
        return const Color(0xFFD1D1D6);
      case WeekStatus.locked:
        return const Color(0xFFE5E5EA);
    }
  }

  Widget _buildStoneContent(WeekStatus status) {
    switch (status) {
      case WeekStatus.completed:
        return const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 28,
        );
      case WeekStatus.inProgress:
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: widget.week.completionPercent,
                strokeWidth: 3,
                backgroundColor: Colors.white.withOpacity(0.5),
                valueColor: const AlwaysStoppedAnimation(PremiumTheme.primaryDark),
              ),
            ),
            Text(
              '${(widget.week.completionPercent * 100).round()}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: PremiumTheme.primaryDark,
              ),
            ),
          ],
        );
      case WeekStatus.available:
        return Text(
          '${widget.week.weekNumber}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8E8E93),
          ),
        );
      case WeekStatus.locked:
        return const Icon(
          Icons.lock_rounded,
          color: Color(0xFFC7C7CC),
          size: 24,
        );
    }
  }

  Widget _buildLabel() {
    final isLeft = widget.alignment == Alignment.centerLeft;

    return Expanded(
      child: Column(
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Week label
          Text(
            widget.week.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isCurrent
                  ? PremiumTheme.primary
                  : const Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 2),
          // Week title
          Text(
            widget.week.title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: widget.week.status.isAccessible
                  ? const Color(0xFF000000)
                  : const Color(0xFFC7C7CC),
            ),
            textAlign: isLeft ? TextAlign.left : TextAlign.right,
          ),
          // Current indicator
          if (widget.isCurrent) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: PremiumTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'YOU ARE HERE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: PremiumTheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isCurrent
                ? PremiumTheme.primary.withOpacity(0.3)
                : const Color(0xFFE5E5EA),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Focus
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PremiumTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Focus: ${widget.week.focus}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PremiumTheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Summary
            Text(
              widget.week.summary,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Progress bar
            if (widget.week.status.showProgress) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.week.completionPercent,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE5E5EA),
                        valueColor:
                            const AlwaysStoppedAnimation(PremiumTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(widget.week.completionPercent * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PremiumTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Continue button
            if (widget.week.status.isAccessible)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onContinue?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.week.status == WeekStatus.inProgress
                        ? 'Continue ${widget.week.label}'
                        : 'Start ${widget.week.label}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
