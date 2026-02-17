import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/dimensions.dart';
import '../../core/theme/premium_theme.dart';

/// Large, accessible button with minimum 60x60dp touch target
/// Updated for PreHab-inspired design
class BigButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    if (!widget.isLoading) {
      HapticFeedback.mediumImpact();
      widget.onPressed();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? PremiumTheme.primary;
    final fgColor = widget.foregroundColor ?? Colors.white;

    if (widget.isOutlined) {
      return _buildOutlined(bgColor);
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              height: AppDimensions.buttonHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.isLoading ? bgColor.withOpacity(0.6) : bgColor,
                borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
                boxShadow: widget.isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: bgColor.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: _buildContent(fgColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutlined(Color color) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: AppDimensions.buttonHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
                border: Border.all(
                  color: PremiumTheme.surfaceVariant,
                  width: 2,
                ),
              ),
              child: Center(
                child: _buildContent(PremiumTheme.textPrimary),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color,
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: AppDimensions.iconSizeS, color: color),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Hold-to-complete button to prevent accidental taps
class HoldToCompleteButton extends StatefulWidget {
  final String label;
  final VoidCallback onComplete;
  final Duration holdDuration;
  final IconData? icon;
  final Color? backgroundColor;

  const HoldToCompleteButton({
    super.key,
    required this.label,
    required this.onComplete,
    this.holdDuration = const Duration(milliseconds: 500),
    this.icon,
    this.backgroundColor,
  });

  @override
  State<HoldToCompleteButton> createState() => _HoldToCompleteButtonState();
}

class _HoldToCompleteButtonState extends State<HoldToCompleteButton>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _isHolding = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isComplete) {
        setState(() => _isComplete = true);
        HapticFeedback.heavyImpact();
        _bounceController.forward().then((_) => _bounceController.reverse());
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_isComplete) return;
    setState(() => _isHolding = true);
    HapticFeedback.lightImpact();
    _progressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_isComplete) return;
    setState(() => _isHolding = false);
    if (_progressController.value < 1.0) {
      _progressController.reverse();
    }
  }

  void _onTapCancel() {
    if (_isComplete) return;
    setState(() => _isHolding = false);
    _progressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? PremiumTheme.accent;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressController, _bounceAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _isComplete ? _bounceAnimation.value : 1.0,
            child: Container(
              height: AppDimensions.buttonHeightLarge,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isComplete
                    ? PremiumTheme.success
                    : bgColor.withOpacity(_isHolding ? 0.9 : 1.0),
                borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: (_isComplete ? PremiumTheme.success : bgColor)
                        .withOpacity(0.4),
                    blurRadius: _isHolding ? 20 : 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Progress fill
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: double.infinity,
                        width: MediaQuery.of(context).size.width *
                            _progressController.value,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                  // Content
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isComplete
                              ? Icons.check_circle_rounded
                              : (widget.icon ?? Icons.check_rounded),
                          color: Colors.white,
                          size: AppDimensions.iconSizeM,
                        ),
                        const SizedBox(width: AppDimensions.spacingS),
                        Text(
                          _isComplete ? 'Done!' : widget.label,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Large Done button for exercise completion
class ExerciseDoneButton extends StatelessWidget {
  final VoidCallback onDone;
  final bool isVisible;

  const ExerciseDoneButton({
    super.key,
    required this.onDone,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonHeight = screenHeight * AppDimensions.doneButtonHeightRatio;

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        height: buttonHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingScreen),
            child: HoldToCompleteButton(
              label: 'Hold to Complete',
              icon: Icons.check_rounded,
              onComplete: onDone,
              backgroundColor: PremiumTheme.accent,
            ),
          ),
        ),
      ),
    );
  }
}
