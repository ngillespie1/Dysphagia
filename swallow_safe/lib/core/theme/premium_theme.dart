import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Unified premium design system for SwallowSafe
/// Fresh Mint palette — calm, clean, medical-but-friendly
class PremiumTheme {
  // ============ Fresh Mint Color Palette ============
  
  /// Primary — fresh mint green
  static const Color primary = Color(0xFF3CBAA2);
  static const Color primaryLight = Color(0xFF7DD8C4);
  static const Color primaryDark = Color(0xFF2A9A84);
  static const Color primarySoft = Color(0xFFE8F8F4);
  static const Color primaryMuted = Color(0xFFE8F8F4);
  
  /// Accent — warm coral for pops of energy
  static const Color accent = Color(0xFFFF7F6B);
  static const Color accentLight = Color(0xFFFFB4A8);
  static const Color accentDark = Color(0xFFE8614E);
  static const Color accentSoft = Color(0xFFFFF0EE);
  
  /// Backgrounds — minty white, airy and clean
  static const Color bgCream = Color(0xFFF0FBF8);
  static const Color bgWarm = Color(0xFFE4F5F0);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardGlass = Color(0xE6FFFFFF);
  
  /// Backgrounds
  static const Color background = Color(0xFFF0FBF8);
  static const Color backgroundMint = Color(0xFFD5F2EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE4F0EC);
  
  /// Text — cool charcoal for contrast
  static const Color textPrimary = Color(0xFF1A2F2B);
  static const Color textSecondary = Color(0xFF4A6B64);
  static const Color textTertiary = Color(0xFF7A9B93);
  static const Color textMuted = Color(0xFFB0C8C2);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);
  
  /// Status colors — harmonised with mint
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFFE8FAF0);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFFF8E8);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFDECEA);
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFFEBF5FB);

  // ============ Progress & Streaks ============
  
  static const Color progressRing = Color(0xFF3CBAA2);
  static const Color progressRingBackground = Color(0xFFD5F2EA);
  static const Color streakActive = Color(0xFFFF7F6B);
  static const Color streakInactive = Color(0xFFD5E8E3);
  static const Color streakGlow = Color(0x40FF7F6B);

  // ============ Symptom Scale ============
  
  static const List<Color> symptomScale = [
    Color(0xFF2ECC71), // 1 - Excellent (green)
    Color(0xFF7DD8C4), // 2 - Good (soft mint)
    Color(0xFFF39C12), // 3 - Okay (amber)
    Color(0xFFFF7F6B), // 4 - Difficult (coral)
    Color(0xFFE74C3C), // 5 - Very difficult (red)
  ];

  // ============ AI Assistant ============
  
  static const Color aiPrimary = Color(0xFF6C5CE7);
  static const Color aiPrimaryLight = Color(0xFF9B8FE8);
  static const Color aiBackground = Color(0xFFF3F1FB);
  static const Color aiBubble = Color(0xFFEDE9FE);

  // ============ Overlays & Shadows (Colors) ============
  
  static const Color overlay = Color(0x60000000);
  static const Color overlayLight = Color(0x30000000);
  static const Color shadowColor = Color(0x0A1A2F2B);
  static const Color shadow = Color(0x0A1A2F2B);
  static const Color shadowMediumColor = Color(0x151A2F2B);
  static const Color shadowDarkColor = Color(0x251A2F2B);
  
  // Glassmorphism
  static const Color glassFill = Color(0x99FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);

  // ============ Special ============
  
  static const Color premium = Color(0xFFFFD700);
  static const Color premiumGlow = Color(0x40FFD700);
  static const Color locked = Color(0xFF7A9B93);
  
  // Video player
  static const Color videoOverlay = Color(0x70000000);
  static const Color videoControlsBg = Color(0xD9000000);

  // ============ Gradients ============
  
  /// Soft organic background gradient
  static const LinearGradient meshGradient = LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
    colors: [
      Color(0xFFF0FBF8),
      Color(0xFFE4F5F0),
      Color(0xFFD5F2EA),
      Color(0xFFE8F8F4),
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );
  
  /// Hero card gradient — vibrant mint
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5FCDB8),
      Color(0xFF3CBAA2),
      Color(0xFF2A9A84),
    ],
  );
  
  /// Accent warm gradient — coral pop
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB4A8),
      Color(0xFFFF7F6B),
    ],
  );
  
  /// Glass overlay gradient
  static LinearGradient glassOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.85),
      Colors.white.withOpacity(0.65),
    ],
  );
  
  /// Splash gradient
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF5FCDB8),
      Color(0xFF3CBAA2),
      Color(0xFF2A9A84),
    ],
  );
  
  /// Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5FCDB8),
      Color(0xFF3CBAA2),
    ],
  );
  
  /// Card gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF0FBF8)],
  );
  
  /// Video hero gradient overlay
  static const LinearGradient videoHeroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xD9000000)],
  );
  
  /// Alias for backward compatibility
  static const LinearGradient backgroundGradient = meshGradient;
  
  /// Card background color
  static const Color bgCard = Color(0xFFFFFFFF);

  // ============ Illustration Colors ============
  
  static const Color illustrationTeal = Color(0xFF3CBAA2);
  static const Color illustrationGold = Color(0xFFFF7F6B);
  static const Color illustrationLavender = Color(0xFF6C5CE7);
  static const Color illustrationSky = Color(0xFF3498DB);
  static const Color illustrationCream = Color(0xFFF0FBF8);

  // ============ Dark Mode Colors ============
  
  /// Dark primary palette — brighter mint for dark bg
  static const Color darkPrimary = Color(0xFF5FCDB8);
  static const Color darkPrimaryLight = Color(0xFF7DD8C4);
  static const Color darkPrimaryDark = Color(0xFF3CBAA2);
  static const Color darkPrimarySoft = Color(0xFF1A3630);
  
  /// Dark accent
  static const Color darkAccent = Color(0xFFFFB4A8);
  static const Color darkAccentSoft = Color(0xFF2A2020);
  
  /// Dark backgrounds
  static const Color darkBackground = Color(0xFF0F1A17);
  static const Color darkSurface = Color(0xFF1A2A25);
  static const Color darkSurfaceVariant = Color(0xFF253530);
  static const Color darkCardColor = Color(0xFF1E2D28);
  static const Color darkCardGlass = Color(0xE61E2D28);
  
  /// Dark text
  static const Color darkTextPrimary = Color(0xFFE8F0ED);
  static const Color darkTextSecondary = Color(0xFF9AB0A8);
  static const Color darkTextTertiary = Color(0xFF6B8580);
  static const Color darkTextMuted = Color(0xFF4B6560);
  
  /// Dark status colors
  static const Color darkSuccess = Color(0xFF2ECC71);
  static const Color darkSuccessLight = Color(0xFF1A2E22);
  static const Color darkWarning = Color(0xFFF39C12);
  static const Color darkWarningLight = Color(0xFF2A2618);
  static const Color darkError = Color(0xFFE74C3C);
  static const Color darkErrorLight = Color(0xFF2E1A1A);
  
  /// Dark shadows
  static const Color darkShadowColor = Color(0x40000000);
  
  /// Dark gradients
  static const LinearGradient darkMeshGradient = LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
    colors: [
      Color(0xFF0F1A17),
      Color(0xFF141F1C),
      Color(0xFF121D19),
      Color(0xFF131C18),
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );
  
  static const LinearGradient darkHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A4A40),
      Color(0xFF143D35),
      Color(0xFF0F302A),
    ],
  );
  
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2D28), Color(0xFF1A2A25)],
  );

  /// Dark mode shadow sets
  static List<BoxShadow> get darkSoftShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get darkElevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ============ Typography — Nunito + Plus Jakarta Sans ============
  
  /// Oversized display — friendly rounded sans
  static TextStyle get displayHero => GoogleFonts.nunito(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -1.5,
    height: 1.1,
  );
  
  static TextStyle get displayLarge => GoogleFonts.nunito(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -1.0,
    height: 1.15,
  );
  
  static TextStyle get displayMedium => GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  /// Headlines — Nunito for warmth
  static TextStyle get headlineLarge => GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.3,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );
  
  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  /// Body — Plus Jakarta Sans for readability
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.6,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.4,
  );
  
  /// Labels — precise and functional
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.3,
  );
  
  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textTertiary,
    letterSpacing: 0.5,
  );
  
  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: textTertiary,
    letterSpacing: 0.8,
  );
  
  static TextStyle get button => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // ============ Shadows (Layered) ============
  
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF1A2F2B).withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF1A2F2B).withOpacity(0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Alias for backward compatibility with AppTheme.cardShadow
  static List<BoxShadow> get cardShadow => softShadow;
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF1A2F2B).withOpacity(0.07),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: const Color(0xFF1A2F2B).withOpacity(0.03),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: const Color(0xFF1A2F2B).withOpacity(0.08),
      blurRadius: 40,
      offset: const Offset(0, 16),
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.8),
      blurRadius: 0,
      offset: const Offset(0, -1),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get heroShadow => [
    BoxShadow(
      color: primary.withOpacity(0.30),
      blurRadius: 40,
      offset: const Offset(0, 16),
      spreadRadius: -8,
    ),
    BoxShadow(
      color: primary.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> get innerShadow => [
    BoxShadow(
      color: const Color(0xFF1A2F2B).withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: -2,
    ),
  ];
  
  static List<BoxShadow> get accentGlow => [
    BoxShadow(
      color: primary.withOpacity(0.2),
      blurRadius: 20,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: primary.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Primary button shadow
  static List<BoxShadow> primaryButtonShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ============ Spacing ============
  
  static const double spacingXS = 4;
  static const double spacingS = 6;
  static const double spacingM = 10;
  static const double spacingL = 14;
  static const double spacingXL = 20;
  static const double spacingXXL = 28;
  static const double spacingHuge = 40;

  // ============ Border Radii ============
  
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 28;

  // ============ Input Decoration ============
  
  static InputDecoration inputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: bodyMedium.copyWith(color: textTertiary),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: bgWarm,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingL,
        vertical: spacingL,
      ),
    );
  }

  // ============ Button Styles ============
  
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXL,
      vertical: spacingL,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    textStyle: button,
  );
  
  static ButtonStyle get secondaryButton => ElevatedButton.styleFrom(
    backgroundColor: primarySoft,
    foregroundColor: primary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingXL,
      vertical: spacingL,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    textStyle: button,
  );
}
