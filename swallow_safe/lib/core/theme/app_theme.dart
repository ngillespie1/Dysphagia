import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/dimensions.dart';
import 'premium_theme.dart';

/// Unified theme for SwallowSafe - wraps PremiumTheme into Material ThemeData
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme - uses PremiumTheme palette
      colorScheme: const ColorScheme.light(
        primary: PremiumTheme.primary,
        onPrimary: PremiumTheme.textOnPrimary,
        secondary: PremiumTheme.accent,
        onSecondary: PremiumTheme.textOnAccent,
        tertiary: PremiumTheme.aiPrimary,
        surface: PremiumTheme.surface,
        onSurface: PremiumTheme.textPrimary,
        surfaceContainerHighest: PremiumTheme.surfaceVariant,
        error: PremiumTheme.error,
        onError: PremiumTheme.textOnPrimary,
      ),

      // Background
      scaffoldBackgroundColor: PremiumTheme.background,

      // Typography
      textTheme: _buildTextTheme(),

      // AppBar - Clean and minimal
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: PremiumTheme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeTitle,
          fontWeight: FontWeight.w700,
          color: PremiumTheme.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: PremiumTheme.textPrimary,
          size: AppDimensions.iconSizeS,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PremiumTheme.primary,
          foregroundColor: PremiumTheme.textOnPrimary,
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXL,
            vertical: AppDimensions.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppDimensions.fontSizeLabel,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PremiumTheme.primary,
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppDimensions.fontSizeBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PremiumTheme.textPrimary,
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXL,
            vertical: AppDimensions.spacingM,
          ),
          side: const BorderSide(color: PremiumTheme.primaryLight, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppDimensions.fontSizeLabel,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PremiumTheme.primary,
          foregroundColor: PremiumTheme.textOnPrimary,
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXL,
            vertical: AppDimensions.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppDimensions.fontSizeLabel,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // Card
      cardTheme: CardTheme(
        color: PremiumTheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: PremiumTheme.surface,
        selectedItemColor: PremiumTheme.primary,
        unselectedItemColor: PremiumTheme.textTertiary,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PremiumTheme.surface,
        indicatorColor: PremiumTheme.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: PremiumTheme.primary);
          }
          return GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: PremiumTheme.textTertiary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: PremiumTheme.primary, size: 24);
          }
          return const IconThemeData(color: PremiumTheme.textTertiary, size: 24);
        }),
        height: 80,
        elevation: 0,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PremiumTheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          borderSide: const BorderSide(color: PremiumTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          borderSide: const BorderSide(color: PremiumTheme.error, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeBody,
          color: PremiumTheme.textTertiary,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: PremiumTheme.textSecondary,
        size: AppDimensions.iconSizeS,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PremiumTheme.primary,
        linearTrackColor: PremiumTheme.progressRingBackground,
        circularTrackColor: PremiumTheme.progressRingBackground,
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: PremiumTheme.primary,
        inactiveTrackColor: PremiumTheme.progressRingBackground,
        thumbColor: PremiumTheme.primary,
        overlayColor: PremiumTheme.primary.withOpacity(0.2),
        trackHeight: AppDimensions.progressHeight,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PremiumTheme.surface;
          }
          return PremiumTheme.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PremiumTheme.primary;
          }
          return PremiumTheme.surfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: PremiumTheme.surfaceVariant,
        thickness: 1,
        space: AppDimensions.spacingM,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PremiumTheme.primary,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeBody,
          color: PremiumTheme.textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PremiumTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.bottomSheetRadius),
          ),
        ),
        elevation: 0,
        dragHandleColor: PremiumTheme.surfaceVariant,
        dragHandleSize: Size(AppDimensions.bottomSheetHandleWidth, AppDimensions.bottomSheetHandleHeight),
        showDragHandle: true,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: PremiumTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusLarge),
        ),
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeTitle,
          fontWeight: FontWeight.w700,
          color: PremiumTheme.textPrimary,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeBody,
          color: PremiumTheme.textSecondary,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PremiumTheme.primary,
        foregroundColor: PremiumTheme.textOnPrimary,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
        ),
        extendedTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeLabel,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: PremiumTheme.primarySoft,
        selectedColor: PremiumTheme.primary,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: AppDimensions.fontSizeSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Dark color scheme
      colorScheme: const ColorScheme.dark(
        primary: PremiumTheme.darkPrimary,
        onPrimary: PremiumTheme.darkBackground,
        secondary: PremiumTheme.darkAccent,
        onSecondary: PremiumTheme.darkBackground,
        tertiary: PremiumTheme.aiPrimaryLight,
        surface: PremiumTheme.darkSurface,
        onSurface: PremiumTheme.darkTextPrimary,
        surfaceContainerHighest: PremiumTheme.darkSurfaceVariant,
        error: PremiumTheme.darkError,
        onError: PremiumTheme.darkBackground,
      ),

      // Background
      scaffoldBackgroundColor: PremiumTheme.darkBackground,

      // Typography
      textTheme: _buildDarkTextTheme(),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: PremiumTheme.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeTitle,
          fontWeight: FontWeight.w700,
          color: PremiumTheme.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: PremiumTheme.darkTextPrimary,
          size: AppDimensions.iconSizeS,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PremiumTheme.darkPrimary,
          foregroundColor: PremiumTheme.darkBackground,
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXL,
            vertical: AppDimensions.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppDimensions.fontSizeLabel,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PremiumTheme.darkPrimary,
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppDimensions.fontSizeBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PremiumTheme.darkTextPrimary,
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXL,
            vertical: AppDimensions.spacingM,
          ),
          side: const BorderSide(color: PremiumTheme.darkPrimaryLight, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppDimensions.fontSizeLabel,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PremiumTheme.darkPrimary,
          foregroundColor: PremiumTheme.darkBackground,
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXL,
            vertical: AppDimensions.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppDimensions.fontSizeLabel,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // Card
      cardTheme: CardTheme(
        color: PremiumTheme.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: PremiumTheme.darkSurface,
        selectedItemColor: PremiumTheme.darkPrimary,
        unselectedItemColor: PremiumTheme.darkTextTertiary,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PremiumTheme.darkSurface,
        indicatorColor: PremiumTheme.darkPrimarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: PremiumTheme.darkPrimary);
          }
          return GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: PremiumTheme.darkTextTertiary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: PremiumTheme.darkPrimary, size: 24);
          }
          return const IconThemeData(color: PremiumTheme.darkTextTertiary, size: 24);
        }),
        height: 80,
        elevation: 0,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PremiumTheme.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          borderSide: const BorderSide(color: PremiumTheme.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
          borderSide: const BorderSide(color: PremiumTheme.darkError, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeBody,
          color: PremiumTheme.darkTextTertiary,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: PremiumTheme.darkTextSecondary,
        size: AppDimensions.iconSizeS,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PremiumTheme.darkPrimary,
        linearTrackColor: PremiumTheme.darkSurfaceVariant,
        circularTrackColor: PremiumTheme.darkSurfaceVariant,
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: PremiumTheme.darkPrimary,
        inactiveTrackColor: PremiumTheme.darkSurfaceVariant,
        thumbColor: PremiumTheme.darkPrimary,
        overlayColor: PremiumTheme.darkPrimary.withOpacity(0.2),
        trackHeight: AppDimensions.progressHeight,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PremiumTheme.darkBackground;
          }
          return PremiumTheme.darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PremiumTheme.darkPrimary;
          }
          return PremiumTheme.darkSurfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: PremiumTheme.darkSurfaceVariant,
        thickness: 1,
        space: AppDimensions.spacingM,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PremiumTheme.darkPrimary,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeBody,
          color: PremiumTheme.darkBackground,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PremiumTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.bottomSheetRadius),
          ),
        ),
        elevation: 0,
        dragHandleColor: PremiumTheme.darkSurfaceVariant,
        dragHandleSize: Size(AppDimensions.bottomSheetHandleWidth, AppDimensions.bottomSheetHandleHeight),
        showDragHandle: true,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: PremiumTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusLarge),
        ),
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeTitle,
          fontWeight: FontWeight.w700,
          color: PremiumTheme.darkTextPrimary,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeBody,
          color: PremiumTheme.darkTextSecondary,
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PremiumTheme.darkPrimary,
        foregroundColor: PremiumTheme.darkBackground,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
        ),
        extendedTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppDimensions.fontSizeLabel,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: PremiumTheme.darkPrimarySoft,
        selectedColor: PremiumTheme.darkPrimary,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: AppDimensions.fontSizeSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.nunito(
        fontSize: AppDimensions.fontSizeHero,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.textPrimary,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: AppDimensions.fontSizeDisplay,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.textPrimary,
        letterSpacing: -1.0,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: AppDimensions.fontSizeHeading,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),

      // Headlines
      headlineLarge: GoogleFonts.nunito(
        fontSize: AppDimensions.fontSizeTitleLarge,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.textPrimary,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: AppDimensions.fontSizeTitle,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.textPrimary,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeBodyLarge,
        fontWeight: FontWeight.w600,
        color: PremiumTheme.textPrimary,
      ),

      // Titles
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeLabel,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.textPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeBody,
        fontWeight: FontWeight.w600,
        color: PremiumTheme.textPrimary,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeSmall,
        fontWeight: FontWeight.w600,
        color: PremiumTheme.textPrimary,
      ),

      // Body
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeBodyLarge,
        fontWeight: FontWeight.w500,
        color: PremiumTheme.textPrimary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeBody,
        fontWeight: FontWeight.w500,
        color: PremiumTheme.textPrimary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeSmall,
        fontWeight: FontWeight.w500,
        color: PremiumTheme.textSecondary,
        height: 1.4,
      ),

      // Labels
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeLabel,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.textPrimary,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeSmall,
        fontWeight: FontWeight.w600,
        color: PremiumTheme.textPrimary,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeXS,
        fontWeight: FontWeight.w600,
        color: PremiumTheme.textTertiary,
      ),
    );
  }

  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.nunito(
        fontSize: AppDimensions.fontSizeHero,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.darkTextPrimary,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: AppDimensions.fontSizeDisplay,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.darkTextPrimary,
        letterSpacing: -1.0,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: AppDimensions.fontSizeHeading,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.darkTextPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),

      // Headlines
      headlineLarge: GoogleFonts.nunito(
        fontSize: AppDimensions.fontSizeTitleLarge,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.darkTextPrimary,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: AppDimensions.fontSizeTitle,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.darkTextPrimary,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeBodyLarge,
        fontWeight: FontWeight.w600,
        color: PremiumTheme.darkTextPrimary,
      ),

      // Titles
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeLabel,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.darkTextPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeBody,
        fontWeight: FontWeight.w600,
        color: PremiumTheme.darkTextPrimary,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeSmall,
        fontWeight: FontWeight.w600,
        color: PremiumTheme.darkTextPrimary,
      ),

      // Body
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeBodyLarge,
        fontWeight: FontWeight.w500,
        color: PremiumTheme.darkTextPrimary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeBody,
        fontWeight: FontWeight.w500,
        color: PremiumTheme.darkTextPrimary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeSmall,
        fontWeight: FontWeight.w500,
        color: PremiumTheme.darkTextSecondary,
        height: 1.4,
      ),

      // Labels
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeLabel,
        fontWeight: FontWeight.w700,
        color: PremiumTheme.darkTextPrimary,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeSmall,
        fontWeight: FontWeight.w600,
        color: PremiumTheme.darkTextPrimary,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: AppDimensions.fontSizeXS,
        fontWeight: FontWeight.w600,
        color: PremiumTheme.darkTextTertiary,
      ),
    );
  }

  /// Soft shadow for cards - delegates to PremiumTheme
  static List<BoxShadow> get cardShadow => PremiumTheme.cardShadow;

  /// Elevated shadow - delegates to PremiumTheme
  static List<BoxShadow> get elevatedShadow => PremiumTheme.elevatedShadow;

  /// Primary button shadow
  static List<BoxShadow> primaryButtonShadow(Color color) =>
      PremiumTheme.primaryButtonShadow(color);
}
