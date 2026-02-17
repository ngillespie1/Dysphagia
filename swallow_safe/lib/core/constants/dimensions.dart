/// Premium dimension constants for SwallowSafe
/// PreHab-inspired spacing with generous whitespace and accessible touch targets
class AppDimensions {
  AppDimensions._();

  // ============ TOUCH TARGETS ============
  
  // Minimum 60dp for tremor accommodation (WCAG AAA)
  static const double minTouchTarget = 60.0;
  static const double largeTouchTarget = 80.0;
  static const double extraLargeTouchTarget = 100.0;

  // ============ BUTTONS ============
  
  static const double buttonHeight = 64.0;
  static const double buttonHeightLarge = 80.0;
  static const double buttonHeightXL = 96.0;
  static const double buttonRadius = 16.0;
  static const double buttonRadiusLarge = 24.0;
  static const double buttonRadiusPill = 100.0;
  
  // FAB sizes
  static const double fabSize = 72.0;
  static const double fabSizeLarge = 88.0;
  
  // "Done" button overlay ratio
  static const double doneButtonHeightRatio = 0.22;

  // ============ SPACING ============
  
  static const double spacingXXS = 2.0;
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;

  // ============ PADDING ============
  
  static const double paddingScreen = 24.0;
  static const double paddingScreenLarge = 32.0;
  static const double paddingCard = 24.0;
  static const double paddingCardCompact = 16.0;

  // ============ TYPOGRAPHY ============
  
  // Premium sizing - larger for elegance
  static const double fontSizeXS = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeBodyLarge = 18.0;
  static const double fontSizeLabel = 18.0;
  static const double fontSizeTitle = 22.0;
  static const double fontSizeTitleLarge = 28.0;
  static const double fontSizeHeading = 36.0;
  static const double fontSizeDisplay = 48.0;
  static const double fontSizeHero = 64.0;
  
  // Numbers and stats (Space Grotesk)
  static const double fontSizeStatSmall = 24.0;
  static const double fontSizeStatMedium = 36.0;
  static const double fontSizeStatLarge = 56.0;
  static const double fontSizeStatHero = 72.0;

  // ============ ICONS ============
  
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 24.0;
  static const double iconSizeM = 32.0;
  static const double iconSizeL = 48.0;
  static const double iconSizeXL = 64.0;
  static const double iconSizeXXL = 96.0;

  // ============ CARDS ============
  
  static const double cardRadius = 24.0;
  static const double cardRadiusSmall = 16.0;
  static const double cardRadiusLarge = 32.0;
  static const double cardElevation = 0.0; // Using shadows instead
  
  // Card heights
  static const double cardHeightSmall = 80.0;
  static const double cardHeightMedium = 120.0;
  static const double cardHeightLarge = 180.0;
  static const double cardHeightHero = 240.0;

  // ============ PROGRESS RING ============
  
  static const double progressRingSizeSmall = 48.0;
  static const double progressRingSizeMedium = 80.0;
  static const double progressRingSizeLarge = 160.0;
  static const double progressRingSizeHero = 220.0;
  static const double progressRingStrokeSmall = 4.0;
  static const double progressRingStrokeMedium = 8.0;
  static const double progressRingStrokeLarge = 12.0;

  // ============ VIDEO PLAYER ============
  
  static const double videoOverlayPadding = 24.0;
  static const double videoThumbnailHeight = 200.0;
  static const double videoThumbnailHeightLarge = 280.0;
  static const double playButtonSize = 72.0;
  static const double playButtonSizeLarge = 96.0;

  // ============ PROGRESS & STREAKS ============
  
  static const double progressHeight = 8.0;
  static const double progressHeightLarge = 12.0;
  static const double streakDotSize = 12.0;
  static const double streakDotSizeLarge = 16.0;
  static const double weekDayRingSize = 40.0;

  // ============ SYMPTOM SCALE ============
  
  static const double symptomIconSize = 56.0;
  static const double symptomButtonSize = 72.0;

  // ============ AI CHAT ============
  
  static const double chatBubbleRadius = 20.0;
  static const double chatBubbleRadiusLarge = 24.0;
  static const double chatInputHeight = 56.0;
  static const double chatAvatarSize = 40.0;

  // ============ BOTTOM SHEET ============
  
  static const double bottomSheetRadius = 32.0;
  static const double bottomSheetHandleWidth = 40.0;
  static const double bottomSheetHandleHeight = 4.0;

  // ============ AVATAR ============
  
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;

  // ============ SHADOWS ============
  
  static const double shadowBlurSmall = 8.0;
  static const double shadowBlurMedium = 16.0;
  static const double shadowBlurLarge = 24.0;
  static const double shadowOffsetY = 4.0;

  // ============ ANIMATION DURATIONS ============
  
  static const int animationInstant = 100;
  static const int animationFast = 200;
  static const int animationNormal = 300;
  static const int animationSlow = 500;
  static const int animationVerySlow = 800;
  static const int pageTransition = 350;
  static const int celebrationDuration = 2000;
  
  // Hold-to-complete (prevents accidental taps)
  static const int holdDurationMs = 500;

  // ============ EXERCISE SESSION ============
  
  static const double exerciseDotSize = 10.0;
  static const double exerciseDotSpacing = 8.0;
  static const double exerciseProgressDotsHeight = 40.0;
}
