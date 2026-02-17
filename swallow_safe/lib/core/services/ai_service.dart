import '../../data/providers/ai_provider.dart';
import '../../data/models/chat_message.dart';
import '../constants/strings.dart';

/// Context data injected into the system prompt so the AI can give
/// personalized, context-aware advice.
class AIContext {
  final String patientName;
  final String programName;
  final int currentWeek;
  final int totalWeeks;
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final double? recentPainAvg;
  final double? recentSwallowAvg;
  final double? recentDryMouthAvg;
  final String? painTrend; // "improving", "stable", "worsening"
  final String? swallowTrend;
  final String? dryMouthTrend;
  final bool completedToday;
  final String? lastCheckInNotes;

  const AIContext({
    this.patientName = 'Patient',
    this.programName = 'Recovery Program',
    this.currentWeek = 1,
    this.totalWeeks = 8,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.recentPainAvg,
    this.recentSwallowAvg,
    this.recentDryMouthAvg,
    this.painTrend,
    this.swallowTrend,
    this.dryMouthTrend,
    this.completedToday = false,
    this.lastCheckInNotes,
  });
}

/// Proactive insight generated from user data
class ProactiveInsight {
  final String id;
  final String title;
  final String message;
  final InsightType type;
  final String? suggestedQuestion;

  const ProactiveInsight({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.suggestedQuestion,
  });
}

enum InsightType {
  celebration,  // positive milestones
  warning,      // streak at risk, symptoms worsening
  tip,          // exercise tips, hydration reminders
  motivation,   // encouragement based on progress
}

/// AI Service for Recovery Assistant
/// Handles communication with AI providers, context injection, and safety disclaimers
class AIService {
  final AIProvider provider;

  AIService({required this.provider});

  /// Base system prompt for the AI Recovery Assistant
  static const String _baseSystemPrompt = '''
You are a helpful Recovery Assistant for SwallowSafe, an app designed to help patients with dysphagia (swallowing difficulties) recover through guided exercises.

Your role is to:
1. Answer questions about dysphagia exercises and recovery
2. Provide encouragement and support
3. Suggest exercise modifications when appropriate
4. Explain the purpose and benefits of different exercises
5. Help users understand their symptoms
6. Reference the patient's actual progress data when relevant

You should:
- Be warm, supportive, and encouraging
- Use simple, clear language (patients may have cognitive impairments)
- Keep responses concise but helpful (2-4 paragraphs max)
- Reference the patient by name when appropriate
- Acknowledge their specific program, streak, and symptom data
- Always emphasize the importance of following their healthcare provider's guidance
- Never diagnose conditions or prescribe treatments
- Redirect serious concerns to healthcare providers

You must NOT:
- Provide specific medical advice
- Diagnose conditions
- Recommend stopping prescribed exercises
- Replace professional medical guidance
''';

  /// Build a context-enriched system prompt
  String _buildContextualPrompt(AIContext? context) {
    if (context == null) return _baseSystemPrompt;

    final contextBlock = StringBuffer();
    contextBlock.writeln('\n--- PATIENT CONTEXT ---');
    contextBlock.writeln('Name: ${context.patientName}');
    contextBlock.writeln('Program: ${context.programName}');
    contextBlock.writeln(
        'Progress: Week ${context.currentWeek} of ${context.totalWeeks}');
    contextBlock.writeln('Current streak: ${context.currentStreak} days');
    contextBlock.writeln('Longest streak: ${context.longestStreak} days');
    contextBlock.writeln('Total sessions completed: ${context.totalSessions}');
    contextBlock.writeln(
        'Completed today: ${context.completedToday ? "Yes" : "Not yet"}');

    if (context.recentPainAvg != null) {
      contextBlock.writeln(
          '\nRecent symptom averages (1-5 scale, lower = better):');
      contextBlock.writeln(
          '  Pain: ${context.recentPainAvg!.toStringAsFixed(1)} (${context.painTrend ?? "unknown"})');
      contextBlock.writeln(
          '  Swallowing ease: ${context.recentSwallowAvg!.toStringAsFixed(1)} (${context.swallowTrend ?? "unknown"})');
      contextBlock.writeln(
          '  Dry mouth: ${context.recentDryMouthAvg!.toStringAsFixed(1)} (${context.dryMouthTrend ?? "unknown"})');
    }

    if (context.lastCheckInNotes != null &&
        context.lastCheckInNotes!.isNotEmpty) {
      contextBlock.writeln(
          '\nLatest check-in notes: "${context.lastCheckInNotes}"');
    }

    contextBlock.writeln('--- END CONTEXT ---');

    return _baseSystemPrompt + contextBlock.toString();
  }

  /// Generate proactive insights from the user's context data
  List<ProactiveInsight> generateInsights(AIContext context) {
    final insights = <ProactiveInsight>[];

    // Streak celebrations
    if (context.currentStreak >= 7) {
      insights.add(ProactiveInsight(
        id: 'streak_week',
        title: '🔥 ${context.currentStreak}-Day Streak!',
        message:
            'Amazing consistency, ${context.patientName}! You\'re building great habits.',
        type: InsightType.celebration,
      ));
    } else if (context.currentStreak >= 3) {
      insights.add(ProactiveInsight(
        id: 'streak_growing',
        title: '🌱 Streak Growing',
        message:
            '${context.currentStreak} days in a row — keep it going!',
        type: InsightType.motivation,
      ));
    }

    // Streak risk
    if (context.currentStreak > 0 && !context.completedToday) {
      insights.add(ProactiveInsight(
        id: 'streak_risk',
        title: '⏰ Don\'t Lose Your Streak',
        message:
            'Complete today\'s session to keep your ${context.currentStreak}-day streak alive!',
        type: InsightType.warning,
        suggestedQuestion: 'What exercises should I do today?',
      ));
    }

    // Symptom trends
    if (context.painTrend == 'worsening') {
      insights.add(ProactiveInsight(
        id: 'pain_up',
        title: '📈 Pain Trending Up',
        message:
            'Your pain levels have been increasing. Consider discussing this with your healthcare provider.',
        type: InsightType.warning,
        suggestedQuestion: 'My pain has been getting worse — what should I do?',
      ));
    } else if (context.painTrend == 'improving') {
      insights.add(ProactiveInsight(
        id: 'pain_down',
        title: '📉 Pain Improving',
        message:
            'Great news — your pain levels are trending down. Your exercises are helping!',
        type: InsightType.celebration,
        suggestedQuestion: 'Why is my pain improving?',
      ));
    }

    if (context.swallowTrend == 'worsening') {
      insights.add(ProactiveInsight(
        id: 'swallow_up',
        title: '⚠️ Swallowing Difficulty Rising',
        message:
            'Your swallowing ease scores are going up. This may warrant a check-in with your SLP.',
        type: InsightType.warning,
        suggestedQuestion:
            'My swallowing has been harder lately — any tips?',
      ));
    }

    // Program progress milestones
    if (context.currentWeek == context.totalWeeks) {
      insights.add(ProactiveInsight(
        id: 'final_week',
        title: '🎯 Final Week!',
        message:
            'You\'ve reached the last week of your program. Incredible dedication!',
        type: InsightType.celebration,
        suggestedQuestion: 'I\'m finishing my program — what\'s next?',
      ));
    } else if (context.currentWeek == (context.totalWeeks / 2).ceil()) {
      insights.add(ProactiveInsight(
        id: 'halfway',
        title: '🏁 Halfway There',
        message:
            'You\'re at the midpoint of your program. Keep up the great work!',
        type: InsightType.motivation,
        suggestedQuestion: 'How should I adjust my exercises at this point?',
      ));
    }

    // Total sessions milestone
    if (context.totalSessions == 10 ||
        context.totalSessions == 25 ||
        context.totalSessions == 50 ||
        context.totalSessions == 100) {
      insights.add(ProactiveInsight(
        id: 'session_milestone',
        title: '🏆 ${context.totalSessions} Sessions Complete!',
        message:
            'What an achievement! Every session strengthens your recovery.',
        type: InsightType.celebration,
      ));
    }

    // Hydration tip (always shown if no other strong insights)
    if (insights.isEmpty || insights.length < 2) {
      insights.add(const ProactiveInsight(
        id: 'hydration_tip',
        title: '💧 Hydration Reminder',
        message:
            'Staying hydrated supports swallowing function. Aim for small, frequent sips throughout the day.',
        type: InsightType.tip,
        suggestedQuestion: 'How does hydration affect my swallowing?',
      ));
    }

    return insights.take(3).toList();
  }

  /// Send a message to the AI with optional context
  /// Automatically appends safety disclaimer to all responses
  Future<String> sendMessage({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
    AIContext? context,
  }) async {
    final systemPrompt = _buildContextualPrompt(context);

    try {
      final response = await provider.chat(
        systemPrompt: systemPrompt,
        messages: conversationHistory,
        userMessage: userMessage,
      );

      // Always append safety disclaimer
      return response + AppStrings.aiSafetyDisclaimer;
    } catch (e) {
      return 'I apologize, but I\'m having trouble connecting right now. Please try again in a moment.${AppStrings.aiSafetyDisclaimer}';
    }
  }
}
