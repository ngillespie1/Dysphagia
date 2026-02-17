import 'package:flutter/material.dart';

/// Soft Mint Green palette - Headspace inspired
/// Calming, approachable, and healing
class AppColors {
  AppColors._();

  // ============ PRIMARY - SOFT MINT ============
  
  static const Color primary = Color(0xFF7ECEC1);      // Soft mint
  static const Color primaryLight = Color(0xFFA8DED4); // Lighter mint
  static const Color primaryDark = Color(0xFF5AB5A6);  // Deeper mint
  static const Color primaryMuted = Color(0xFFE8F6F4); // Very soft mint bg

  // ============ ACCENT - WARM PEACH ============
  
  static const Color accent = Color(0xFFFFB088);       // Warm peach
  static const Color accentLight = Color(0xFFFFD4BC);  // Light peach
  static const Color accentDark = Color(0xFFE8946A);   // Deeper peach

  // ============ BACKGROUNDS ============
  
  static const Color background = Color(0xFFF7FAFA);    // Soft mint-tinted white
  static const Color backgroundMint = Color(0xFFE8F6F4); // Light mint background
  static const Color surface = Color(0xFFFFFFFF);       // Pure white cards
  static const Color surfaceVariant = Color(0xFFF0F5F4); // Subtle mint tint

  // ============ TEXT ============
  
  static const Color textPrimary = Color(0xFF2D4A47);   // Deep teal-gray
  static const Color textSecondary = Color(0xFF6B8A86); // Muted teal
  static const Color textTertiary = Color(0xFF9CB3AF);  // Light teal
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF2D4A47);

  // ============ FEEDBACK ============
  
  static const Color success = Color(0xFF7ECEC1);       // Mint (same as primary)
  static const Color successLight = Color(0xFFE8F6F4);
  static const Color warning = Color(0xFFFFB088);       // Peach
  static const Color warningLight = Color(0xFFFFF4ED);
  static const Color error = Color(0xFFE88B8B);         // Soft coral
  static const Color errorLight = Color(0xFFFFF0F0);
  static const Color info = Color(0xFF88C4E8);          // Soft sky blue
  static const Color infoLight = Color(0xFFF0F8FF);

  // ============ PROGRESS & STREAKS ============
  
  static const Color progressRing = Color(0xFF7ECEC1);
  static const Color progressRingBackground = Color(0xFFE8F6F4);
  static const Color streakActive = Color(0xFFFFB088);
  static const Color streakInactive = Color(0xFFE0E8E6);
  static const Color streakGlow = Color(0x40FFB088);

  // ============ SYMPTOM SCALE ============
  
  static const List<Color> symptomScale = [
    Color(0xFF7ECEC1), // 1 - Excellent (mint)
    Color(0xFFA8DED4), // 2 - Good (light mint)
    Color(0xFFFFE5A0), // 3 - Okay (soft yellow)
    Color(0xFFFFB088), // 4 - Difficult (peach)
    Color(0xFFE88B8B), // 5 - Very difficult (soft coral)
  ];

  // ============ AI ASSISTANT ============
  
  static const Color aiPrimary = Color(0xFF9B8FE8);     // Soft lavender
  static const Color aiPrimaryLight = Color(0xFFB8AFF0);
  static const Color aiBackground = Color(0xFFF5F3FF);
  static const Color aiBubble = Color(0xFFEDE9FE);

  // ============ OVERLAYS & SHADOWS ============
  
  static const Color overlay = Color(0x60000000);
  static const Color overlayLight = Color(0x30000000);
  static const Color shadow = Color(0x0A2D4A47);
  static const Color shadowMedium = Color(0x152D4A47);
  static const Color shadowDark = Color(0x252D4A47);
  
  // Glassmorphism
  static const Color glassFill = Color(0x99FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);

  // ============ SPECIAL ============
  
  static const Color premium = Color(0xFFFFD700);
  static const Color premiumGlow = Color(0x40FFD700);
  static const Color locked = Color(0xFF9CB3AF);
  
  // Video player
  static const Color videoOverlay = Color(0x70000000);
  static const Color videoControlsBg = Color(0xD9000000);

  // ============ GRADIENTS ============
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7ECEC1), Color(0xFF5AB5A6)],
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB088), Color(0xFFFFD4BC)],
  );
  
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF7ECEC1),
      Color(0xFF5AB5A6),
      Color(0xFF4AA395),
    ],
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xD9000000)],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFA)],
  );

  // ============ HEADSPACE-STYLE ILLUSTRATION COLORS ============
  
  static const Color illustrationMint = Color(0xFF7ECEC1);
  static const Color illustrationPeach = Color(0xFFFFB088);
  static const Color illustrationLavender = Color(0xFF9B8FE8);
  static const Color illustrationSky = Color(0xFF88C4E8);
  static const Color illustrationCream = Color(0xFFFFF8F0);
}
