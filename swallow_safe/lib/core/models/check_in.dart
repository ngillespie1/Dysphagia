import 'package:equatable/equatable.dart';

import 'daily_progress.dart';

/// Represents a daily check-in with symptoms and mood
class CheckIn extends Equatable {
  final String id;
  final DateTime date;
  final Mood overallFeeling;
  final int swallowingDifficulty; // 1-10 scale
  final List<Symptom> symptoms;
  final String? notes;
  final DateTime createdAt;

  const CheckIn({
    required this.id,
    required this.date,
    required this.overallFeeling,
    this.swallowingDifficulty = 5,
    this.symptoms = const [],
    this.notes,
    required this.createdAt,
  });

  /// Is this from today?
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Friendly date string
  String get dateLabel {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    if (date.year == now.year && 
        date.month == now.month && 
        date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year && 
               date.month == yesterday.month && 
               date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  /// Summary text for display
  String get summary {
    if (notes != null && notes!.isNotEmpty) {
      return notes!;
    }
    return 'Swallowing: $swallowingDifficulty/10';
  }

  CheckIn copyWith({
    String? id,
    DateTime? date,
    Mood? overallFeeling,
    int? swallowingDifficulty,
    List<Symptom>? symptoms,
    String? notes,
    DateTime? createdAt,
  }) {
    return CheckIn(
      id: id ?? this.id,
      date: date ?? this.date,
      overallFeeling: overallFeeling ?? this.overallFeeling,
      swallowingDifficulty: swallowingDifficulty ?? this.swallowingDifficulty,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'overallFeeling': overallFeeling.name,
      'swallowingDifficulty': swallowingDifficulty,
      'symptoms': symptoms.map((s) => s.name).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      overallFeeling: Mood.values.firstWhere(
        (m) => m.name == json['overallFeeling'],
        orElse: () => Mood.okay,
      ),
      swallowingDifficulty: json['swallowingDifficulty'] as int? ?? 5,
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((s) => Symptom.values.firstWhere(
                    (sym) => sym.name == s,
                    orElse: () => Symptom.other,
                  ))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Create a new check-in for now
  factory CheckIn.create({
    required Mood overallFeeling,
    required int swallowingDifficulty,
    List<Symptom> symptoms = const [],
    String? notes,
  }) {
    final now = DateTime.now();
    return CheckIn(
      id: 'checkin_${now.millisecondsSinceEpoch}',
      date: now,
      overallFeeling: overallFeeling,
      swallowingDifficulty: swallowingDifficulty,
      symptoms: symptoms,
      notes: notes,
      createdAt: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        overallFeeling,
        swallowingDifficulty,
        symptoms,
        notes,
        createdAt,
      ];
}

/// Common dysphagia symptoms
enum Symptom {
  coughing,
  choking,
  drooling,
  painSwallowing,
  foodSticking,
  regurgitation,
  weightLoss,
  voiceChanges,
  fatigue,
  other,
}

extension SymptomExtension on Symptom {
  String get label {
    switch (this) {
      case Symptom.coughing:
        return 'Coughing during meals';
      case Symptom.choking:
        return 'Choking sensation';
      case Symptom.drooling:
        return 'Drooling';
      case Symptom.painSwallowing:
        return 'Pain when swallowing';
      case Symptom.foodSticking:
        return 'Food sticking in throat';
      case Symptom.regurgitation:
        return 'Regurgitation';
      case Symptom.weightLoss:
        return 'Weight loss';
      case Symptom.voiceChanges:
        return 'Voice changes';
      case Symptom.fatigue:
        return 'Eating fatigue';
      case Symptom.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case Symptom.coughing:
        return '😮‍💨';
      case Symptom.choking:
        return '😰';
      case Symptom.drooling:
        return '💧';
      case Symptom.painSwallowing:
        return '😣';
      case Symptom.foodSticking:
        return '🍽️';
      case Symptom.regurgitation:
        return '🔄';
      case Symptom.weightLoss:
        return '⚖️';
      case Symptom.voiceChanges:
        return '🗣️';
      case Symptom.fatigue:
        return '😴';
      case Symptom.other:
        return '📋';
    }
  }
}
