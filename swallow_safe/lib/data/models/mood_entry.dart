import 'package:equatable/equatable.dart';

/// A single day's mood data for the weekly mood tracker
class MoodEntry extends Equatable {
  final String date; // YYYY-MM-DD
  final String? mood;
  final bool hasCheckIn;

  const MoodEntry({
    required this.date,
    this.mood,
    this.hasCheckIn = false,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: json['date'] as String? ?? '',
      mood: json['mood'] as String?,
      hasCheckIn: json['hasCheckIn'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'mood': mood,
        'hasCheckIn': hasCheckIn,
      };

  @override
  List<Object?> get props => [date, mood, hasCheckIn];
}
