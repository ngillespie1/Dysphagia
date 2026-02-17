import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/exercise/bloc/session_bloc.dart';
import 'features/exercise/bloc/video_cache_bloc.dart';
import 'features/ai_assistant/bloc/ai_chat_bloc.dart';
import 'features/gamification/bloc/gamification_bloc.dart';
import 'features/progress/bloc/streak_bloc.dart';
import 'features/program/bloc/program_bloc.dart';
import 'features/onboarding/bloc/onboarding_bloc.dart';
import 'features/settings/cubit/theme_cubit.dart';
import 'features/user/bloc/user_bloc.dart';
import 'core/services/service_locator.dart';

class SwallowSafeApp extends StatelessWidget {
  const SwallowSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<SessionBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<AIChatBloc>()..add(const InitializeChat()),
        ),
        BlocProvider(
          create: (_) => getIt<StreakBloc>()..add(LoadStreakData()),
        ),
        BlocProvider(
          create: (_) => getIt<ProgramBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<GamificationBloc>()..add(const LoadGamification()),
        ),
        BlocProvider(
          create: (_) => getIt<OnboardingBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<UserBloc>()..add(const LoadUser()),
        ),
        BlocProvider(
          create: (_) => getIt<ThemeCubit>(),
        ),
        BlocProvider(
          create: (_) => getIt<VideoCacheBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'SwallowSafe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
