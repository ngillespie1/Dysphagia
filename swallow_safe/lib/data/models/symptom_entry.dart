import 'package:equatable/equatable.dart';

/// Daily symptom check-in entry
class SymptomEntry extends Equatable {
  final String id;
  final DateTime date;
  final int painLevel; // 1-5
  final int swallowingEase; // 1-5
  final int dryMouth; // 1-5
  final String? notes;
  final DateTime createdAt;
  
  const SymptomEntry({
    required this.id,
    required this.date,
    required this.painLevel,
    required this.swallowingEase,
    required this.dryMouth,
    this.notes,
    required this.createdAt,
  });
  
  /// Create from JSON (Firestore document)
  factory SymptomEntry.fromJson(Map<String, dynamic> json) {
    return SymptomEntry(
      id: json['id'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      painLevel: json['pain_level'] as int? ?? 3,
      swallowingEase: json['swallowing_ease'] as int? ?? 3,
      dryMouth: json['dry_mouth'] as int? ?? 3,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': _dateOnlyString(date),
      'pain_level': painLevel,
      'swallowing_ease': swallowingEase,
      'dry_mouth': dryMouth,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  /// Get date-only string for storage key
  static String _dateOnlyString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Get date key for this entry
  String get dateKey => _dateOnlyString(date);
  
  /// Calculate average symptom score
  double get averageScore => (painLevel + swallowingEase + dryMouth) / 3;
  
  /// Check if all symptoms are good (1-2)
  bool get isGoodDay => painLevel <= 2 && swallowingEase <= 2 && dryMouth <= 2;
  
  SymptomEntry copyWith({
    String? id,
    DateTime? date,
    int? painLevel,
    int? swallowingEase,
    int? dryMouth,
    String? notes,
    DateTime? createdAt,
  }) {
    return SymptomEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      painLevel: painLevel ?? this.painLevel,
      swallowingEase: swallowingEase ?? this.swallowingEase,
      dryMouth: dryMouth ?? this.dryMouth,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    date,
    painLevel,
    swallowingEase,
    dryMouth,
    notes,
    createdAt,
  ];
}
