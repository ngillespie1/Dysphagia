import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/premium_theme.dart';

/// Animated organic mesh gradient background for premium depth
/// Uses the SwallowSafe mint palette for both light and dark modes
class AnimatedMeshBackground extends StatefulWidget {
  final Widget child;

  const AnimatedMeshBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedMeshBackground> createState() =>
      _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? PremiumTheme.darkMeshGradient
                : PremiumTheme.meshGradient,
          ),
        ),

        // Animated organic blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: MeshBlobPainter(
                animation: _controller.value,
                isDark: isDark,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class MeshBlobPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  MeshBlobPainter({
    required this.animation,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Mint-based blobs instead of teal + gold
    final mintBase = isDark ? PremiumTheme.darkPrimary : PremiumTheme.primary;
    final mintLight =
        isDark ? PremiumTheme.darkPrimaryLight : PremiumTheme.primaryLight;
    final blobOpacity = isDark ? 0.04 : 0.07;
    final lightOpacity = isDark ? 0.03 : 0.05;

    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          mintBase.withOpacity(blobOpacity),
          mintBase.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * (0.2 + 0.1 * math.sin(animation * 2 * math.pi)),
          size.height * (0.15 + 0.08 * math.cos(animation * 2 * math.pi)),
        ),
        radius: size.width * 0.5,
      ));

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          mintLight.withOpacity(lightOpacity),
          mintLight.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width *
              (0.8 + 0.12 * math.cos(animation * 2 * math.pi + 1)),
          size.height *
              (0.35 + 0.1 * math.sin(animation * 2 * math.pi + 1)),
        ),
        radius: size.width * 0.6,
      ));

    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          mintBase.withOpacity(blobOpacity * 0.6),
          mintBase.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width *
              (0.5 + 0.15 * math.sin(animation * 2 * math.pi + 2)),
          size.height *
              (0.75 + 0.1 * math.cos(animation * 2 * math.pi + 2)),
        ),
        radius: size.width * 0.45,
      ));

    canvas.drawCircle(
      Offset(
        size.width * (0.2 + 0.1 * math.sin(animation * 2 * math.pi)),
        size.height * (0.15 + 0.08 * math.cos(animation * 2 * math.pi)),
      ),
      size.width * 0.5,
      paint1,
    );

    canvas.drawCircle(
      Offset(
        size.width *
            (0.8 + 0.12 * math.cos(animation * 2 * math.pi + 1)),
        size.height *
            (0.35 + 0.1 * math.sin(animation * 2 * math.pi + 1)),
      ),
      size.width * 0.6,
      paint2,
    );

    canvas.drawCircle(
      Offset(
        size.width *
            (0.5 + 0.15 * math.sin(animation * 2 * math.pi + 2)),
        size.height *
            (0.75 + 0.1 * math.cos(animation * 2 * math.pi + 2)),
      ),
      size.width * 0.45,
      paint3,
    );
  }

  @override
  bool shouldRepaint(MeshBlobPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.isDark != isDark;
}
