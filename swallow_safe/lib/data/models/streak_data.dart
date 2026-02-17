import 'package:equatable/equatable.dart';

/// Standalone streak data returned by DataSyncService
/// (Separate from UserProfile.StreakData for DB-layer usage)
class StreakInfo extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;

  const StreakInfo({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
  });

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalSessions: json['totalSessions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalSessions': totalSessions,
      };

  @override
  List<Object?> get props => [currentStreak, longestStreak, totalSessions];
}
