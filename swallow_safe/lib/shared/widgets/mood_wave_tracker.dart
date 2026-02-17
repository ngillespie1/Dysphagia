import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/premium_theme.dart';

/// Expressive mood wave visualization for weekly activity
class MoodWaveTracker extends StatefulWidget {
  final List<DayMood> weekData;
  
  const MoodWaveTracker({
    super.key,
    required this.weekData,
  });

  @override
  State<MoodWaveTracker> createState() => _MoodWaveTrackerState();
}

class _MoodWaveTrackerState extends State<MoodWaveTracker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: MoodWavePainter(
              weekData: widget.weekData,
              animation: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class MoodWavePainter extends CustomPainter {
  final List<DayMood> weekData;
  final double animation;
  
  MoodWavePainter({
    required this.weekData,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final dayWidth = size.width / 7;
    final centerY = size.height / 2;
    
    // Draw wave background
    final wavePath = Path();
    wavePath.moveTo(0, centerY);
    
    for (int i = 0; i < 7; i++) {
      final x = dayWidth * (i + 0.5);
      final mood = i < weekData.length ? weekData[i] : DayMood.none;
      final moodOffset = _getMoodOffset(mood) * 20;
      final waveOffset = math.sin((animation * 2 * math.pi) + (i * 0.8)) * 3;
      
      final y = centerY - moodOffset + waveOffset;
      
      if (i == 0) {
        wavePath.lineTo(x, y);
      } else {
        final prevX = dayWidth * (i - 0.5);
        wavePath.quadraticBezierTo(
          (prevX + x) / 2,
          y + 5,
          x,
          y,
        );
      }
    }
    
    wavePath.lineTo(size.width, centerY);
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();
    
    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          PremiumTheme.primary.withOpacity(0.15),
          PremiumTheme.primary.withOpacity(0.03),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(wavePath, fillPaint);
    
    // Draw wave line
    final linePath = Path();
    linePath.moveTo(0, centerY);
    
    for (int i = 0; i < 7; i++) {
      final x = dayWidth * (i + 0.5);
      final mood = i < weekData.length ? weekData[i] : DayMood.none;
      final moodOffset = _getMoodOffset(mood) * 20;
      final waveOffset = math.sin((animation * 2 * math.pi) + (i * 0.8)) * 3;
      
      final y = centerY - moodOffset + waveOffset;
      
      if (i == 0) {
        linePath.lineTo(x, y);
      } else {
        final prevX = dayWidth * (i - 0.5);
        linePath.quadraticBezierTo(
          (prevX + x) / 2,
          y + 5,
          x,
          y,
        );
      }
    }
    
    final linePaint = Paint()
      ..color = PremiumTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(linePath, linePaint);
    
    // Draw day dots with personality
    for (int i = 0; i < 7; i++) {
      final x = dayWidth * (i + 0.5);
      final mood = i < weekData.length ? weekData[i] : DayMood.none;
      final moodOffset = _getMoodOffset(mood) * 20;
      final waveOffset = math.sin((animation * 2 * math.pi) + (i * 0.8)) * 3;
      final y = centerY - moodOffset + waveOffset;
      
      _drawMoodDot(canvas, Offset(x, y), mood, i);
    }
  }
  
  void _drawMoodDot(Canvas canvas, Offset center, DayMood mood, int dayIndex) {
    if (mood == DayMood.none) {
      // Empty day - subtle ring
      final ringPaint = Paint()
        ..color = PremiumTheme.textMuted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, 8, ringPaint);
      return;
    }
    
    final color = _getMoodColor(mood);
    
    // Outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, 12, glowPaint);
    
    // Main dot
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(center, 10, dotPaint);
    
    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(center.translate(-3, -3), 3, highlightPaint);
    
    // Draw mood emoji/icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getMoodEmoji(mood),
        style: const TextStyle(fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
  
  double _getMoodOffset(DayMood mood) {
    switch (mood) {
      case DayMood.great:
        return 1.0;
      case DayMood.good:
        return 0.5;
      case DayMood.okay:
        return 0.0;
      case DayMood.difficult:
        return -0.5;
      case DayMood.struggling:
        return -1.0;
      case DayMood.none:
        return 0.0;
    }
  }
  
  Color _getMoodColor(DayMood mood) {
    switch (mood) {
      case DayMood.great:
        return PremiumTheme.success;
      case DayMood.good:
        return PremiumTheme.primaryLight;
      case DayMood.okay:
        return PremiumTheme.accent;
      case DayMood.difficult:
        return PremiumTheme.warning;
      case DayMood.struggling:
        return PremiumTheme.error;
      case DayMood.none:
        return PremiumTheme.textMuted;
    }
  }
  
  String _getMoodEmoji(DayMood mood) {
    switch (mood) {
      case DayMood.great:
        return '😊';
      case DayMood.good:
        return '🙂';
      case DayMood.okay:
        return '😐';
      case DayMood.difficult:
        return '😕';
      case DayMood.struggling:
        return '😢';
      case DayMood.none:
        return '';
    }
  }
  
  @override
  bool shouldRepaint(MoodWavePainter oldDelegate) => 
      oldDelegate.animation != animation || 
      oldDelegate.weekData != weekData;
}

enum DayMood {
  great,
  good,
  okay,
  difficult,
  struggling,
  none,
}

class DayMoodData {
  final DayMood mood;
  final String dayLabel;
  final bool isToday;
  
  const DayMoodData({
    required this.mood,
    required this.dayLabel,
    this.isToday = false,
  });
}
