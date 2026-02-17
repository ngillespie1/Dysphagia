import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/exercise/screens/exercise_screen.dart';
import '../../features/exercise/screens/session_complete_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/program/screens/program_selector_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/name_screen.dart';
import '../../features/onboarding/screens/baseline_symptom_screen.dart';
import '../../features/onboarding/screens/goals_screen.dart';
import '../../features/onboarding/screens/disclaimer_screen.dart';
import '../../features/onboarding/screens/program_select_screen.dart';
import '../../features/doctor/screens/doctor_report_screen.dart';
import '../../features/tracking/screens/food_diary_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

/// Route paths
class AppRoutes {
  static const String splash = '/splash';

  // Onboarding flow (6 steps)
  static const String onboardingWelcome = '/onboarding';
  static const String onboardingName = '/onboarding/name';
  static const String onboardingBaseline = '/onboarding/baseline';
  static const String onboardingGoals = '/onboarding/goals';
  static const String onboardingDisclaimer = '/onboarding/disclaimer';
  static const String onboardingProgram = '/onboarding/program';

  // Main app — 3 tabs
  static const String home = '/';
  static const String journey = '/journey';
  static const String settings = '/settings';

  // Full-screen flows
  static const String exercise = '/exercise';
  static const String sessionComplete = '/session-complete';
  static const String programSelector = '/program-selector';
  static const String doctorReport = '/doctor-report';
  static const String foodDiary = '/food-diary';
}

/// App router configuration
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash screen
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
        transitionDuration: Duration.zero,
      ),
    ),

    // Onboarding flow (6 steps)
    GoRoute(
      path: AppRoutes.onboardingWelcome,
      pageBuilder: (context, state) => _buildPage(
        const WelcomeScreen(),
        state,
      ),
    ),
    GoRoute(
      path: AppRoutes.onboardingName,
      pageBuilder: (context, state) => _buildSlideTransition(
        const NameScreen(),
        state,
      ),
    ),
    GoRoute(
      path: AppRoutes.onboardingBaseline,
      pageBuilder: (context, state) => _buildSlideTransition(
        const BaselineSymptomScreen(),
        state,
      ),
    ),
    GoRoute(
      path: AppRoutes.onboardingGoals,
      pageBuilder: (context, state) => _buildSlideTransition(
        const GoalsScreen(),
        state,
      ),
    ),
    GoRoute(
      path: AppRoutes.onboardingDisclaimer,
      pageBuilder: (context, state) => _buildSlideTransition(
        const DisclaimerScreen(),
        state,
      ),
    ),
    GoRoute(
      path: AppRoutes.onboardingProgram,
      pageBuilder: (context, state) => _buildSlideTransition(
        const ProgramSelectScreen(),
        state,
      ),
    ),

    // Program selector (from settings or change program)
    GoRoute(
      path: AppRoutes.programSelector,
      pageBuilder: (context, state) => _buildModalTransition(
        const ProgramSelectorScreen(),
        state,
      ),
    ),

    // Main shell with 3-tab bottom navigation
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        // Today tab
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => _buildPage(
            const HomeScreen(),
            state,
          ),
        ),

        // Journey tab
        GoRoute(
          path: AppRoutes.journey,
          pageBuilder: (context, state) => _buildPage(
            const ProgressScreen(),
            state,
          ),
        ),

        // Me tab
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => _buildPage(
            const SettingsScreen(),
            state,
          ),
        ),
      ],
    ),

    // Doctor report (full screen)
    GoRoute(
      path: AppRoutes.doctorReport,
      pageBuilder: (context, state) => _buildSlideTransition(
        const DoctorReportScreen(),
        state,
      ),
    ),

    // Food diary (full screen)
    GoRoute(
      path: AppRoutes.foodDiary,
      pageBuilder: (context, state) => _buildSlideTransition(
        const FoodDiaryScreen(),
        state,
      ),
    ),

    // Exercise flow (full screen — no bottom nav)
    GoRoute(
      path: AppRoutes.exercise,
      pageBuilder: (context, state) => _buildSlideTransition(
        const ExerciseScreen(),
        state,
      ),
    ),

    // Session complete
    GoRoute(
      path: AppRoutes.sessionComplete,
      pageBuilder: (context, state) => _buildSlideTransition(
        const SessionCompleteScreen(),
        state,
      ),
    ),
  ],
);

/// Build page with fade-through transition (shared axis feel)
/// Incoming fades in while scaling up slightly; outgoing fades out with scale down
CustomTransitionPage<void> _buildPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade-through: outgoing fades/scales down, incoming fades/scales up
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      );
      final scaleIn = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        ),
      );
      final fadeOut = CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      );

      return FadeTransition(
        opacity: fadeIn,
        child: ScaleTransition(
          scale: scaleIn,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
            child: child,
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Build page with slide transition
CustomTransitionPage<void> _buildSlideTransition(
    Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// Build page with modal/sheet-like transition (slide up)
CustomTransitionPage<void> _buildModalTransition(
    Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}
