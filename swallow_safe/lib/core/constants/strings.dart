/// String constants for SwallowSafe
/// All user-facing text centralised for easy localisation.
///
/// Voice guidelines — Coach Persona:
///   • Warm and encouraging but never patronising
///   • Uses "you" and "your" (patient-first, not clinical)
///   • Short sentences, plain language
///   • Celebrates effort ("You showed up!") not just outcomes
///   • Acknowledges difficulty honestly ("Some days are harder")
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'SwallowSafe';
  static const String appTagline = 'Your personal recovery companion';

  // Navigation
  static const String navHome = 'Today';
  static const String navProgress = 'Journey';
  static const String navTracking = 'Check-in';
  static const String navAssistant = 'Coach';
  static const String navSettings = 'Me';

  // ─── Home Screen ───
  static const String welcomeBack = 'Welcome back';
  static const String startSession = 'Let\'s begin today\'s exercises';
  static const String sessionComplete = 'You did it!';
  static const String greatWork =
      'Every rep matters — your muscles are getting stronger.';
  static const String currentStreak = 'Your streak';
  static const String days = 'days';
  static const String todaysExercises = 'Today\'s exercises';
  static const String noSessionYet =
      'Your exercises are ready whenever you are.';
  static const String sessionAlreadyDone =
      'All done for today — rest and come back tomorrow 💛';

  // ─── Exercise Screen ───
  static const String exercise = 'Exercise';
  static const String of_ = 'of';
  static const String done = 'Done';
  static const String holdToDone = 'Hold to complete';
  static const String tutorVoice = 'Tutor voice';
  static const String reps = 'reps';
  static const String nextExercise = 'Up next';
  static const String skipExercise = 'Skip for now — no pressure';
  static const String getReady = 'Get ready…';
  static const String niceHold = 'Nice hold!';
  static const String takeABreath = 'Take a slow breath';
  static const String exerciseDone = 'Exercise complete!';
  static const String keepGoing = 'You\'re doing great — keep going!';

  // ─── Tracking Screen ───
  static const String dailyCheckIn = 'Quick check-in';
  static const String howAreYouFeeling =
      'How are you feeling right now?';
  static const String painLevel = 'Comfort level';
  static const String swallowingEase = 'Swallowing ease';
  static const String dryMouth = 'Dry mouth';
  static const String saveCheckIn = 'Save';
  static const String checkInSaved = 'Check-in saved — thank you 🙏';
  static const String checkInEncouragement =
      'Tracking helps you and your care team spot patterns.';

  // Symptom Labels (1-5 scale)
  static const List<String> symptomLabels = [
    'Great',
    'Good',
    'Okay',
    'Tough',
    'Really tough',
  ];

  // ─── Progress / Journey Screen ───
  static const String yourProgress = 'Your journey';
  static const String longestStreak = 'Best streak';
  static const String totalSessions = 'Total sessions';
  static const String thisWeek = 'This week';
  static const String thisMonth = 'This month';
  static const String keepItUp =
      'You\'re building real momentum — keep showing up.';

  // ─── AI Coach ───
  static const String aiAssistant = 'Your Coach';
  static const String aiGreeting =
      'Hey! I\'m here to help you with exercise tips, '
      'progress questions, or just a pep talk. What\'s on your mind?';
  static const String askQuestion = 'Ask me anything…';
  static const String typing = 'Thinking…';
  static const String unlockAI = 'Unlock personalised coaching';
  static const String proFeature = 'Pro';
  static const String aiProDescription =
      'Get tailored exercise modifications and one-on-one '
      'recovery guidance with SwallowSafe Pro.';

  // Safety Disclaimer - MUST be appended to all AI responses
  static const String aiSafetyDisclaimer =
      '\n\n⚠️ I\'m an AI coach, not a doctor. '
      'If you\'re choking or can\'t breathe, call emergency services right away.';

  // ─── Paywall ───
  static const String upgradeToPro = 'Go Pro';
  static const String monthlyPrice = '\$9.99/mo';
  static const String yearlyPrice = '\$79.99/yr';
  static const String bestValue = 'Best value';
  static const String startFreeTrial = 'Try 7 days free';
  static const String restorePurchases = 'Restore purchases';
  static const String termsOfService = 'Terms of Service';
  static const String privacyPolicy = 'Privacy Policy';

  // ─── Settings ───
  static const String settings = 'Me';
  static const String notifications = 'Reminders';
  static const String notificationTime = 'Reminder times';
  static const String account = 'Account';
  static const String signOut = 'Sign out';
  static const String about = 'About';
  static const String version = 'Version';
  static const String support = 'Need help?';
  static const String contactUs = 'Contact us';

  // ─── Notifications ───
  static const String notificationTitle = 'Time for your exercises 💪';
  static const String notificationBody =
      'A few minutes now can make a real difference. You\'ve got this!';
  static const String notificationActionDone = 'Done';
  static const String notificationActionRemind = 'Remind me later';

  // ─── Errors ───
  static const String errorGeneric =
      'Oops — something went wrong. Let\'s try that again.';
  static const String errorNetwork =
      'Looks like you\'re offline. Check your connection and try again.';
  static const String errorLoadingVideo =
      'We couldn\'t load the video right now. '
      'You can still follow the written instructions below.';

  // ─── Onboarding ───
  static const String onboardingTitle1 = 'Welcome to SwallowSafe';
  static const String onboardingBody1 =
      'Your personal companion for dysphagia recovery — '
      'guided exercises, progress tracking, and support all in one place.';
  static const String onboardingTitle2 = 'Guided exercises';
  static const String onboardingBody2 =
      'Follow along with short video tutorials '
      'designed by speech-language specialists.';
  static const String onboardingTitle3 = 'See your progress';
  static const String onboardingBody3 =
      'Simple daily check-ins help you and your care team '
      'spot improvements over time.';
  static const String getStarted = 'Let\'s get started';
  static const String next = 'Continue';
  static const String skip = 'Skip for now';

  // ─── Medical Disclaimer ───
  static const String disclaimerTitle = 'Before we begin';
  static const String disclaimerSubtitle =
      'Please read and accept so we can keep you safe';
  static const String medicalDisclaimerHeading = 'Medical disclaimer';
  static const String medicalDisclaimerBody =
      'SwallowSafe is a supportive tool designed to complement — '
      'never replace — your professional medical care.';
  static const String disclaimerAcceptLabel =
      'I understand that SwallowSafe does not replace '
      'professional medical advice, diagnosis, or treatment.';
  static const String tosAcceptLabel =
      'I agree to the Terms of Service and Privacy Policy.';
  static const String emergencyNotice =
      'If this is a medical emergency, call your local emergency '
      'number (e.g. 911) right away.';

  // ─── Doctor Report ───
  static const String doctorReport = 'Share with your doctor';
  static const String doctorReportSubtitle =
      'Generate a report your care team can use';
  static const String generateReport = 'Create PDF report';
  static const String shareReport = 'Share';
  static const String printReport = 'Print';
  static const String copyReportText = 'Copy as text';
  static const String reportPeriod = 'Report period';
  static const String reportIncludes = 'Include';
  static const String exerciseAdherence = 'Exercise consistency';
  static const String symptomTrends = 'Symptom trends';
  static const String checkInHistory = 'Check-in history';
  static const String clinicalNotes = 'Clinical notes';
  static const String reportDisclaimer =
      'This report is based on patient self-reported data '
      'and is intended to supplement clinical evaluation.';
  static const String reportCopied = 'Copied to clipboard';
  static const String reportSharePrompt =
      'Share this report with your healthcare team so '
      'they can see how you\'re doing.';

  // ─── Milestones (coach voice) ───
  static const String milestone1 =
      'Your very first session — you showed up, and that\'s everything!';
  static const String milestone10 =
      '10 sessions in! Your consistency is building real strength.';
  static const String milestone25 =
      '25 sessions — that\'s serious dedication. You should be proud.';
  static const String milestone50 =
      '50 sessions! You\'re proving to yourself what\'s possible.';
  static const String milestone100 =
      '100 sessions — an incredible milestone. Look how far you\'ve come.';

  /// Get the milestone text for a given session count, or null.
  static String? milestoneForCount(int count) {
    switch (count) {
      case 1:
        return milestone1;
      case 10:
        return milestone10;
      case 25:
        return milestone25;
      case 50:
        return milestone50;
      case 100:
        return milestone100;
      default:
        if (count > 0 && count % 25 == 0) {
          return '$count sessions and counting — amazing commitment!';
        }
        return null;
    }
  }
}
