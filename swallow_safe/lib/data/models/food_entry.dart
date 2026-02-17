import 'package:equatable/equatable.dart';

/// IDDSI (International Dysphagia Diet Standardisation Initiative) framework levels
enum IDDSILevel {
  level0, // Thin
  level1, // Slightly thick
  level2, // Mildly thick
  level3, // Moderately thick / Liquidised
  level4, // Pureed
  level5, // Minced & moist
  level6, // Soft & bite-sized
  level7, // Regular / Easy to chew
}

extension IDDSILevelExt on IDDSILevel {
  int get number {
    switch (this) {
      case IDDSILevel.level0:
        return 0;
      case IDDSILevel.level1:
        return 1;
      case IDDSILevel.level2:
        return 2;
      case IDDSILevel.level3:
        return 3;
      case IDDSILevel.level4:
        return 4;
      case IDDSILevel.level5:
        return 5;
      case IDDSILevel.level6:
        return 6;
      case IDDSILevel.level7:
        return 7;
    }
  }

  String get label {
    switch (this) {
      case IDDSILevel.level0:
        return 'Thin';
      case IDDSILevel.level1:
        return 'Slightly Thick';
      case IDDSILevel.level2:
        return 'Mildly Thick';
      case IDDSILevel.level3:
        return 'Liquidised';
      case IDDSILevel.level4:
        return 'Pureed';
      case IDDSILevel.level5:
        return 'Minced & Moist';
      case IDDSILevel.level6:
        return 'Soft & Bite-Sized';
      case IDDSILevel.level7:
        return 'Regular';
    }
  }

  String get icon {
    switch (this) {
      case IDDSILevel.level0:
        return '💧';
      case IDDSILevel.level1:
        return '🥛';
      case IDDSILevel.level2:
        return '🍯';
      case IDDSILevel.level3:
        return '🥣';
      case IDDSILevel.level4:
        return '🍲';
      case IDDSILevel.level5:
        return '🥘';
      case IDDSILevel.level6:
        return '🍽️';
      case IDDSILevel.level7:
        return '🍴';
    }
  }

  /// IDDSI color coding
  String get colorHex {
    switch (this) {
      case IDDSILevel.level0:
        return '#FFFFFF'; // White
      case IDDSILevel.level1:
        return '#D4D4D4'; // Grey
      case IDDSILevel.level2:
        return '#FFB6C1'; // Pink
      case IDDSILevel.level3:
        return '#FFA500'; // Orange (liquid)
      case IDDSILevel.level4:
        return '#00FF00'; // Green
      case IDDSILevel.level5:
        return '#FF6600'; // Orange
      case IDDSILevel.level6:
        return '#0000FF'; // Blue
      case IDDSILevel.level7:
        return '#000000'; // Black (regular)
    }
  }
}

/// Meal time of day
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

extension MealTypeExt on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}

/// A single food diary entry
class FoodEntry extends Equatable {
  final String id;
  final DateTime timestamp;
  final MealType mealType;
  final String description; // Free-text description of food
  final IDDSILevel textureLevel;
  final int? difficultyRating; // 1-5 how hard to swallow
  final bool coughing; // Did they cough during eating?
  final String? notes;

  const FoodEntry({
    required this.id,
    required this.timestamp,
    required this.mealType,
    required this.description,
    required this.textureLevel,
    this.difficultyRating,
    this.coughing = false,
    this.notes,
  });

  String get dateKey =>
      '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'mealType': mealType.name,
        'description': description,
        'textureLevel': textureLevel.number,
        'difficultyRating': difficultyRating,
        'coughing': coughing ? 1 : 0,
        'notes': notes,
      };

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        mealType: MealType.values.byName(json['mealType'] as String),
        description: json['description'] as String,
        textureLevel: IDDSILevel.values.firstWhere(
          (l) => l.number == (json['textureLevel'] as int? ?? 7),
        ),
        difficultyRating: json['difficultyRating'] as int?,
        coughing: (json['coughing'] as int? ?? 0) == 1,
        notes: json['notes'] as String?,
      );

  @override
  List<Object?> get props => [id, timestamp, mealType, description, textureLevel];
}

/// Hydration tracking for a single day
class HydrationEntry extends Equatable {
  final String date; // YYYY-MM-DD
  final int glassesDrunk; // Each "glass" ~250ml
  final int targetGlasses;

  const HydrationEntry({
    required this.date,
    this.glassesDrunk = 0,
    this.targetGlasses = 8,
  });

  double get progress =>
      targetGlasses > 0 ? (glassesDrunk / targetGlasses).clamp(0.0, 1.0) : 0.0;

  int get mlDrunk => glassesDrunk * 250;
  int get mlTarget => targetGlasses * 250;

  HydrationEntry addGlass() => HydrationEntry(
        date: date,
        glassesDrunk: glassesDrunk + 1,
        targetGlasses: targetGlasses,
      );

  HydrationEntry removeGlass() => HydrationEntry(
        date: date,
        glassesDrunk: (glassesDrunk - 1).clamp(0, 99),
        targetGlasses: targetGlasses,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'glassesDrunk': glassesDrunk,
        'targetGlasses': targetGlasses,
      };

  factory HydrationEntry.fromJson(Map<String, dynamic> json) => HydrationEntry(
        date: json['date'] as String,
        glassesDrunk: json['glassesDrunk'] as int? ?? 0,
        targetGlasses: json['targetGlasses'] as int? ?? 8,
      );

  @override
  List<Object?> get props => [date, glassesDrunk, targetGlasses];
}
