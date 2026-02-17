import 'package:equatable/equatable.dart';

/// Daily symptom check-in record persisted to DB
class CheckIn extends Equatable {
  final String id;
  final String date; // YYYY-MM-DD
  final int painLevel; // 1-5
  final int swallowingEase; // 1-5
  final int dryMouth; // 1-5
  final String? overallFeeling;
  final String? notes;
  final DateTime createdAt;

  const CheckIn({
    required this.id,
    required this.date,
    required this.painLevel,
    required this.swallowingEase,
    required this.dryMouth,
    this.overallFeeling,
    this.notes,
    required this.createdAt,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      painLevel: json['pain_level'] as int? ?? 3,
      swallowingEase: json['swallowing_ease'] as int? ?? 3,
      dryMouth: json['dry_mouth'] as int? ?? 3,
      overallFeeling: json['overall_feeling'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'pain_level': painLevel,
      'swallowing_ease': swallowingEase,
      'dry_mouth': dryMouth,
      'overall_feeling': overallFeeling,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Average symptom severity (lower = better)
  double get averageScore => (painLevel + swallowingEase + dryMouth) / 3;

  /// Whether this is a good day (all symptoms ≤ 2)
  bool get isGoodDay =>
      painLevel <= 2 && swallowingEase <= 2 && dryMouth <= 2;

  @override
  List<Object?> get props => [
        id,
        date,
        painLevel,
        swallowingEase,
        dryMouth,
        overallFeeling,
        notes,
        createdAt,
      ];
}
