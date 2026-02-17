import 'package:equatable/equatable.dart';

import 'care_team_member.dart';

/// A scheduled appointment with a care team member
class Appointment extends Equatable {
  final String id;
  final String title;
  final DateTime dateTime;
  final String? careTeamMemberId;
  final CareRole? withRole;
  final String? location;
  final String? notes;
  final bool isCompleted;

  const Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    this.careTeamMemberId,
    this.withRole,
    this.location,
    this.notes,
    this.isCompleted = false,
  });

  bool get isUpcoming => dateTime.isAfter(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  String get timeDisplay {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get dateDisplay {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}';
  }

  Appointment copyWith({bool? isCompleted}) => Appointment(
        id: id,
        title: title,
        dateTime: dateTime,
        careTeamMemberId: careTeamMemberId,
        withRole: withRole,
        location: location,
        notes: notes,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateTime': dateTime.toIso8601String(),
        'careTeamMemberId': careTeamMemberId,
        'withRole': withRole?.name,
        'location': location,
        'notes': notes,
        'isCompleted': isCompleted ? 1 : 0,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        title: json['title'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        careTeamMemberId: json['careTeamMemberId'] as String?,
        withRole: json['withRole'] != null
            ? CareRole.values.byName(json['withRole'] as String)
            : null,
        location: json['location'] as String?,
        notes: json['notes'] as String?,
        isCompleted: (json['isCompleted'] as int? ?? 0) == 1,
      );

  @override
  List<Object?> get props => [id, title, dateTime];
}
