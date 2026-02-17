import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/services/data_sync_service.dart';
import '../../../core/services/subscription_service.dart';

// ============ Events ============

abstract class AIChatEvent extends Equatable {
  const AIChatEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers context gathering and insight generation.
class InitializeChat extends AIChatEvent {
  const InitializeChat();
}

/// Refreshes insights (e.g. after exercise or check-in).
class RefreshInsights extends AIChatEvent {
  const RefreshInsights();
}

class DismissInsight extends AIChatEvent {
  final String insightId;

  const DismissInsight(this.insightId);

  @override
  List<Object?> get props => [insightId];
}

// ============ States ============

abstract class AIChatState extends Equatable {
  const AIChatState();

  @override
  List<Object?> get props => [];
}

class AIChatInitial extends AIChatState {
  const AIChatInitial();
}

class AIChatLoading extends AIChatState {
  const AIChatLoading();
}

class AIChatReady extends AIChatState {
  final AIContext? context;
  final List<ProactiveInsight> insights;
  final List<String> dismissedInsightIds;

  const AIChatReady({
    this.context,
    this.insights = const [],
    this.dismissedInsightIds = const [],
  });

  /// Active insights (not dismissed)
  List<ProactiveInsight> get activeInsights =>
      insights.where((i) => !dismissedInsightIds.contains(i.id)).toList();

  AIChatReady copyWith({
    AIContext? context,
    List<ProactiveInsight>? insights,
    List<String>? dismissedInsightIds,
  }) {
    return AIChatReady(
      context: context ?? this.context,
      insights: insights ?? this.insights,
      dismissedInsightIds: dismissedInsightIds ?? this.dismissedInsightIds,
    );
  }

  @override
  List<Object?> get props => [context, insights, dismissedInsightIds];
}

class AIChatError extends AIChatState {
  final String message;

  const AIChatError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ============ BLoC ============

/// Generates contextual AI insights from user data.
///
/// No longer manages a chat conversation — insights are displayed inline
/// on the Today and Journey screens via [AIInsightCard].
class AIChatBloc extends Bloc<AIChatEvent, AIChatState> {
  final AIService aiService;
  final SubscriptionService subscriptionService;
  final DataSyncService? dataSyncService;

  /// Optional overrides for user data
  String? userName;
  String? programName;
  int? currentWeek;
  int? totalWeeks;

  AIChatBloc({
    required this.aiService,
    required this.subscriptionService,
    this.dataSyncService,
  }) : super(const AIChatInitial()) {
    on<InitializeChat>(_onInitialize);
    on<RefreshInsights>(_onRefresh);
    on<DismissInsight>(_onDismissInsight);
  }

  Future<void> _onInitialize(
    InitializeChat event,
    Emitter<AIChatState> emit,
  ) async {
    emit(const AIChatLoading());

    try {
      final aiContext = await _gatherContext();
      final insights = aiService.generateInsights(aiContext);

      emit(AIChatReady(
        context: aiContext,
        insights: insights,
      ));
    } catch (_) {
      emit(const AIChatReady());
    }
  }

  Future<void> _onRefresh(
    RefreshInsights event,
    Emitter<AIChatState> emit,
  ) async {
    final current = state;
    final dismissed =
        current is AIChatReady ? current.dismissedInsightIds : <String>[];

    try {
      final aiContext = await _gatherContext();
      final insights = aiService.generateInsights(aiContext);

      emit(AIChatReady(
        context: aiContext,
        insights: insights,
        dismissedInsightIds: dismissed,
      ));
    } catch (_) {
      // Keep current state on refresh failure
    }
  }

  Future<AIContext> _gatherContext() async {
    final ds = dataSyncService;
    if (ds == null) {
      return AIContext(
        patientName: userName ?? 'Patient',
        programName: programName ?? 'Recovery Program',
        currentWeek: currentWeek ?? 1,
        totalWeeks: totalWeeks ?? 8,
      );
    }

    // Streak data
    final streakData = await ds.getStreakData();

    // Today's progress
    final todayProgress = await ds.getTodayProgress();
    final completedToday = todayProgress?.sessionCompleted ?? false;

    // Recent check-ins for symptom averages & trends
    final checkIns = await ds.getRecentCheckIns(limit: 14);

    double? avgPain, avgSwallow, avgDry;
    String? painTrend, swallowTrend, dryMouthTrend;
    String? lastNotes;

    if (checkIns.isNotEmpty) {
      avgPain = checkIns
              .map((c) => c.painLevel)
              .reduce((a, b) => a + b) /
          checkIns.length;
      avgSwallow = checkIns
              .map((c) => c.swallowingEase)
              .reduce((a, b) => a + b) /
          checkIns.length;
      avgDry = checkIns
              .map((c) => c.dryMouth)
              .reduce((a, b) => a + b) /
          checkIns.length;

      lastNotes = checkIns.first.notes;

      if (checkIns.length >= 4) {
        final mid = checkIns.length ~/ 2;
        final recent = checkIns.sublist(0, mid);
        final older = checkIns.sublist(mid);

        painTrend = _trend(
          recent.map((c) => c.painLevel),
          older.map((c) => c.painLevel),
        );
        swallowTrend = _trend(
          recent.map((c) => c.swallowingEase),
          older.map((c) => c.swallowingEase),
        );
        dryMouthTrend = _trend(
          recent.map((c) => c.dryMouth),
          older.map((c) => c.dryMouth),
        );
      }
    }

    final user = await ds.getCurrentUser();
    final name = user?['name'] as String? ?? userName ?? 'Patient';

    return AIContext(
      patientName: name,
      programName: programName ?? 'Recovery Program',
      currentWeek: currentWeek ?? 1,
      totalWeeks: totalWeeks ?? 8,
      currentStreak: streakData.currentStreak,
      longestStreak: streakData.longestStreak,
      totalSessions: streakData.totalSessions,
      recentPainAvg: avgPain,
      recentSwallowAvg: avgSwallow,
      recentDryMouthAvg: avgDry,
      painTrend: painTrend,
      swallowTrend: swallowTrend,
      dryMouthTrend: dryMouthTrend,
      completedToday: completedToday,
      lastCheckInNotes: lastNotes,
    );
  }

  String _trend(Iterable<int> recent, Iterable<int> older) {
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    final diff = recentAvg - olderAvg;
    if (diff < -0.3) return 'improving';
    if (diff > 0.3) return 'worsening';
    return 'stable';
  }

  void _onDismissInsight(
    DismissInsight event,
    Emitter<AIChatState> emit,
  ) {
    final currentState = state;
    if (currentState is AIChatReady) {
      emit(currentState.copyWith(
        dismissedInsightIds: [
          ...currentState.dismissedInsightIds,
          event.insightId,
        ],
      ));
    }
  }
}
