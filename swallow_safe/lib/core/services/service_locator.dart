import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';

import '../../data/repositories/program_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/video_cache_repository.dart';
import '../../data/repositories/symptoms_repository.dart';
import '../../data/providers/ai_provider.dart';
import '../../features/exercise/bloc/session_bloc.dart';
import '../../features/exercise/bloc/video_cache_bloc.dart';
import '../../features/tracking/bloc/symptoms_bloc.dart';
import '../../features/ai_assistant/bloc/ai_chat_bloc.dart';
import '../../features/gamification/bloc/gamification_bloc.dart';
import '../../features/progress/bloc/streak_bloc.dart';
import '../../features/program/bloc/program_bloc.dart';
import '../../features/onboarding/bloc/onboarding_bloc.dart';
import '../../features/auth/services/magic_link_service.dart';
import '../../features/doctor/services/report_generator.dart';
import '../../features/settings/cubit/theme_cubit.dart';
import '../../features/user/bloc/user_bloc.dart';
// Conditional import for database service (sqflite not available on web)
import '../database/database_service_stub.dart' if (dart.library.io) '../database/database_service.dart';
import 'ai_service.dart';
import 'audio_feedback_service.dart';
import 'data_sync_service.dart';
import 'haptic_service.dart';
import 'local_storage_service.dart';
import 'notification_service.dart';
import 'subscription_service.dart';
import 'user_data_service.dart';

final GetIt getIt = GetIt.instance;

/// Initialize all services and dependencies
Future<void> setupServiceLocator() async {
  // Initialize timezone for notifications (not on web)
  if (!kIsWeb) {
    NotificationService.initializeTimezone();
  }
  
  // Database service (must be initialized first for SQLite) - skip on web
  DatabaseService? dbService;
  if (!kIsWeb) {
    dbService = DatabaseService();
    getIt.registerSingleton<DatabaseService>(dbService);
  }
  
  // Data sync service (unified data access layer)
  // On web, it uses in-memory storage instead of SQLite
  final dataSyncService = DataSyncService(dbService);
  await dataSyncService.initialize();
  getIt.registerSingleton<DataSyncService>(dataSyncService);
  
  // Local storage for Hive (legacy, still used by some components)
  final localStorageService = LocalStorageService();
  await localStorageService.initialize();
  getIt.registerSingleton<LocalStorageService>(localStorageService);
  
  // User data service
  getIt.registerLazySingleton<UserDataService>(
    () => UserDataService(storage: getIt<LocalStorageService>()),
  );
  
  // Subscription service
  final subscriptionService = SubscriptionService();
  await subscriptionService.initialize();
  getIt.registerSingleton<SubscriptionService>(subscriptionService);
  
  // Services
  getIt.registerLazySingleton<HapticService>(() => HapticService());
  getIt.registerLazySingleton<AudioFeedbackService>(() => AudioFeedbackService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  
  // AI Provider (supports both OpenAI and Anthropic)
  getIt.registerLazySingleton<AIProvider>(() => DualAIProvider());
  getIt.registerLazySingleton<AIService>(
    () => AIService(provider: getIt<AIProvider>()),
  );
  
  // Repositories
  getIt.registerLazySingleton<ProgramRepository>(() => ProgramRepository());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());
  getIt.registerLazySingleton<VideoCacheRepository>(() => VideoCacheRepository());
  getIt.registerLazySingleton<SymptomsRepository>(() => SymptomsRepository());
  
  // BLoCs
  getIt.registerFactory<SessionBloc>(
    () => SessionBloc(
      programRepository: getIt<ProgramRepository>(),
      hapticService: getIt<HapticService>(),
      userRepository: getIt<UserRepository>(),
    ),
  );
  
  getIt.registerFactory<SymptomsBloc>(
    () => SymptomsBloc(
      repository: getIt<SymptomsRepository>(),
      hapticService: getIt<HapticService>(),
    ),
  );
  
  getIt.registerFactory<AIChatBloc>(
    () => AIChatBloc(
      aiService: getIt<AIService>(),
      subscriptionService: getIt<SubscriptionService>(),
      dataSyncService: getIt<DataSyncService>(),
    ),
  );
  
  getIt.registerFactory<StreakBloc>(
    () => StreakBloc(
      userRepository: getIt<UserRepository>(),
    ),
  );
  
  getIt.registerFactory<ProgramBloc>(
    () => ProgramBloc(programRepository: getIt<ProgramRepository>()),
  );

  // Video cache management
  getIt.registerFactory<VideoCacheBloc>(
    () => VideoCacheBloc(repository: getIt<VideoCacheRepository>()),
  );

  // Gamification
  getIt.registerFactory<GamificationBloc>(
    () => GamificationBloc(dataService: getIt<DataSyncService>()),
  );
  
  // Auth services
  getIt.registerLazySingleton<MagicLinkService>(() => MagicLinkService());
  
  // Onboarding
  getIt.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(),
  );
  
  // User
  getIt.registerFactory<UserBloc>(
    () => UserBloc(userDataService: getIt<UserDataService>()),
  );
  
  // Doctor report generator
  getIt.registerLazySingleton<ReportGenerator>(() => ReportGenerator());

  // Theme
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(storage: getIt<LocalStorageService>()),
  );
  
  // Initialize notification service (not on web)
  if (!kIsWeb) {
    await getIt<NotificationService>().initialize();
  }
}
