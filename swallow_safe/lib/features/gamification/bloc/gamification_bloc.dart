import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/data_sync_service.dart';
import '../../../data/models/achievement.dart';
import '../../../data/models/user_level.dart';

// ─── Events ───

abstract class GamificationEvent extends Equatable {
  const GamificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadGamification extends GamificationEvent {
  const LoadGamification();
}

/// Grant XP for an action (e.g. session complete, check-in)
class GrantXP extends GamificationEvent {
  final int amount;
  final String reason;

  const GrantXP({required this.amount, required this.reason});

  @override
  List<Object?> get props => [amount, reason];
}

/// Check and unlock achievements based on current stats
class CheckAchievements extends GamificationEvent {
  final int totalSessions;
  final int currentStreak;
  final int totalCheckIns;
  final double programProgress; // 0.0 to 1.0

  const CheckAchievements({
    this.totalSessions = 0,
    this.currentStreak = 0,
    this.totalCheckIns = 0,
    this.programProgress = 0.0,
  });

  @override
  List<Object?> get props =>
      [totalSessions, currentStreak, totalCheckIns, programProgress];
}

/// Dismiss the XP toast / badge overlay
class DismissGamificationToast extends GamificationEvent {
  const DismissGamificationToast();
}

// ─── States ───

abstract class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => [];
}

class GamificationInitial extends GamificationState {
  const GamificationInitial();
}

class GamificationLoaded extends GamificationState {
  final UserLevel userLevel;
  final List<Achievement> allAchievements;
  final List<Achievement> unlockedAchievements;

  /// Current progress stats so widgets can compute per-milestone progress
  final int totalSessions;
  final int currentStreak;
  final int totalCheckIns;
  final double programProgress; // 0.0 to 1.0

  /// Transient toast data (cleared after display)
  final int? xpJustEarned;
  final String? xpReason;
  final Achievement? badgeJustUnlocked;
  final bool leveledUp;

  const GamificationLoaded({
    required this.userLevel,
    required this.allAchievements,
    required this.unlockedAchievements,
    this.totalSessions = 0,
    this.currentStreak = 0,
    this.totalCheckIns = 0,
    this.programProgress = 0.0,
    this.xpJustEarned,
    this.xpReason,
    this.badgeJustUnlocked,
    this.leveledUp = false,
  });

  GamificationLoaded copyWith({
    UserLevel? userLevel,
    List<Achievement>? allAchievements,
    List<Achievement>? unlockedAchievements,
    int? totalSessions,
    int? currentStreak,
    int? totalCheckIns,
    double? programProgress,
    int? xpJustEarned,
    String? xpReason,
    Achievement? badgeJustUnlocked,
    bool? leveledUp,
    bool clearToast = false,
  }) {
    return GamificationLoaded(
      userLevel: userLevel ?? this.userLevel,
      allAchievements: allAchievements ?? this.allAchievements,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      totalSessions: totalSessions ?? this.totalSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      programProgress: programProgress ?? this.programProgress,
      xpJustEarned: clearToast ? null : (xpJustEarned ?? this.xpJustEarned),
      xpReason: clearToast ? null : (xpReason ?? this.xpReason),
      badgeJustUnlocked: clearToast
          ? null
          : (badgeJustUnlocked ?? this.badgeJustUnlocked),
      leveledUp: clearToast ? false : (leveledUp ?? this.leveledUp),
    );
  }

  @override
  List<Object?> get props => [
        userLevel,
        allAchievements,
        unlockedAchievements,
        totalSessions,
        currentStreak,
        totalCheckIns,
        programProgress,
        xpJustEarned,
        xpReason,
        badgeJustUnlocked,
        leveledUp,
      ];
}

// ─── BLoC ───

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final DataSyncService dataService;

  GamificationBloc({required this.dataService})
      : super(const GamificationInitial()) {
    on<LoadGamification>(_onLoad);
    on<GrantXP>(_onGrantXP);
    on<CheckAchievements>(_onCheckAchievements);
    on<DismissGamificationToast>(_onDismissToast);
  }

  void _onLoad(LoadGamification event, Emitter<GamificationState> emit) {
    emit(GamificationLoaded(
      userLevel: dataService.getUserLevel(),
      allAchievements: dataService.getAllAchievements(),
      unlockedAchievements: dataService.getUnlockedAchievements(),
    ));
  }

  void _onGrantXP(GrantXP event, Emitter<GamificationState> emit) {
    final current = state;
    if (current is! GamificationLoaded) return;

    final result = dataService.addXP(event.amount);

    emit(current.copyWith(
      userLevel: result.newLevel,
      xpJustEarned: event.amount,
      xpReason: event.reason,
      leveledUp: result.leveledUp,
    ));
  }

  Future<void> _onCheckAchievements(
    CheckAchievements event,
    Emitter<GamificationState> emit,
  ) async {
    final current = state;
    if (current is! GamificationLoaded) return;

    Achievement? justUnlocked;
    int totalXPEarned = 0;

    // Session milestones
    final sessionChecks = {
      'first_session': event.totalSessions >= 1,
      'sessions_10': event.totalSessions >= 10,
      'sessions_25': event.totalSessions >= 25,
      'sessions_50': event.totalSessions >= 50,
      'sessions_100': event.totalSessions >= 100,
    };

    // Streak milestones
    final streakChecks = {
      'streak_7': event.currentStreak >= 7,
      'streak_30': event.currentStreak >= 30,
    };

    // Check-in milestones
    final checkInChecks = {
      'first_checkin': event.totalCheckIns >= 1,
      'consistency_5_checkins': event.totalCheckIns >= 5,
    };

    // Program milestones
    final programChecks = {
      'program_25': event.programProgress >= 0.25,
      'program_50': event.programProgress >= 0.50,
      'program_75': event.programProgress >= 0.75,
      'program_100': event.programProgress >= 1.0,
    };

    // Merge all checks
    final allChecks = {
      ...sessionChecks,
      ...streakChecks,
      ...checkInChecks,
      ...programChecks,
    };

    for (final entry in allChecks.entries) {
      if (entry.value && !dataService.isAchievementUnlocked(entry.key)) {
        final unlocked = dataService.unlockAchievement(entry.key);
        if (unlocked != null) {
          totalXPEarned += unlocked.xpReward;
          justUnlocked ??= unlocked; // Show first unlocked badge
        }
      }
    }

    // Grant accumulated XP from unlocked achievements
    UserLevel? newLevel;
    bool leveledUp = false;
    if (totalXPEarned > 0) {
      final result = dataService.addXP(totalXPEarned);
      newLevel = result.newLevel;
      leveledUp = result.leveledUp;
    }

    emit(current.copyWith(
      userLevel: newLevel,
      allAchievements: dataService.getAllAchievements(),
      unlockedAchievements: dataService.getUnlockedAchievements(),
      totalSessions: event.totalSessions,
      currentStreak: event.currentStreak,
      totalCheckIns: event.totalCheckIns,
      programProgress: event.programProgress,
      badgeJustUnlocked: justUnlocked,
      xpJustEarned: totalXPEarned > 0 ? totalXPEarned : null,
      xpReason: justUnlocked != null ? 'Achievement: ${justUnlocked.name}' : null,
      leveledUp: leveledUp,
    ));
  }

  void _onDismissToast(
    DismissGamificationToast event,
    Emitter<GamificationState> emit,
  ) {
    final current = state;
    if (current is GamificationLoaded) {
      emit(current.copyWith(clearToast: true));
    }
  }
}
