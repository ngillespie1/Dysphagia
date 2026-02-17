import 'package:equatable/equatable.dart';

/// User level and XP tracking for gamification
class UserLevel extends Equatable {
  final int level;
  final int currentXP;
  final int xpToNext;
  final String title;

  const UserLevel({
    this.level = 1,
    this.currentXP = 0,
    this.xpToNext = 100,
    this.title = 'Beginner',
  });

  /// Progress within current level (0.0 to 1.0)
  double get levelProgress => xpToNext > 0 ? (currentXP / xpToNext).clamp(0.0, 1.0) : 1.0;

  /// Total XP across all levels
  int get totalXP {
    int total = currentXP;
    for (int i = 1; i < level; i++) {
      total += xpForLevel(i);
    }
    return total;
  }

  /// Add XP and handle level-ups. Returns new UserLevel and whether leveled up.
  ({UserLevel newLevel, bool leveledUp}) addXP(int amount) {
    int xp = currentXP + amount;
    int lvl = level;
    int threshold = xpToNext;
    bool leveledUp = false;

    while (xp >= threshold) {
      xp -= threshold;
      lvl++;
      threshold = xpForLevel(lvl);
      leveledUp = true;
    }

    return (
      newLevel: UserLevel(
        level: lvl,
        currentXP: xp,
        xpToNext: threshold,
        title: titleForLevel(lvl),
      ),
      leveledUp: leveledUp,
    );
  }

  /// XP needed to complete a given level
  static int xpForLevel(int level) {
    if (level <= 1) return 100;
    if (level <= 3) return 150;
    if (level <= 5) return 250;
    if (level <= 10) return 400;
    return 600;
  }

  /// Display title for each level
  static String titleForLevel(int level) {
    if (level <= 1) return 'Beginner';
    if (level <= 3) return 'Learner';
    if (level <= 5) return 'Consistent';
    if (level <= 7) return 'Dedicated';
    if (level <= 10) return 'Advanced';
    if (level <= 15) return 'Expert';
    return 'Recovery Champion';
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'currentXP': currentXP,
        'xpToNext': xpToNext,
        'title': title,
      };

  factory UserLevel.fromJson(Map<String, dynamic> json) => UserLevel(
        level: json['level'] as int? ?? 1,
        currentXP: json['currentXP'] as int? ?? 0,
        xpToNext: json['xpToNext'] as int? ?? 100,
        title: json['title'] as String? ?? 'Beginner',
      );

  @override
  List<Object?> get props => [level, currentXP, xpToNext, title];
}
