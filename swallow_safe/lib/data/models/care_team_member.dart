import 'package:equatable/equatable.dart';

/// Role of a care team member
enum CareRole {
  speechPathologist,
  doctor,
  nurse,
  dietitian,
  occupationalTherapist,
  familyCaregiver,
  other,
}

extension CareRoleExt on CareRole {
  String get label {
    switch (this) {
      case CareRole.speechPathologist:
        return 'Speech Pathologist';
      case CareRole.doctor:
        return 'Doctor';
      case CareRole.nurse:
        return 'Nurse';
      case CareRole.dietitian:
        return 'Dietitian';
      case CareRole.occupationalTherapist:
        return 'Occupational Therapist';
      case CareRole.familyCaregiver:
        return 'Family / Caregiver';
      case CareRole.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case CareRole.speechPathologist:
        return '🗣️';
      case CareRole.doctor:
        return '🩺';
      case CareRole.nurse:
        return '👩‍⚕️';
      case CareRole.dietitian:
        return '🥗';
      case CareRole.occupationalTherapist:
        return '🤲';
      case CareRole.familyCaregiver:
        return '❤️';
      case CareRole.other:
        return '👤';
    }
  }
}

/// A member of the user's care team
class CareTeamMember extends Equatable {
  final String id;
  final String name;
  final CareRole role;
  final String? phone;
  final String? email;
  final String? clinic;

  const CareTeamMember({
    required this.id,
    required this.name,
    required this.role,
    this.phone,
    this.email,
    this.clinic,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'phone': phone,
        'email': email,
        'clinic': clinic,
      };

  factory CareTeamMember.fromJson(Map<String, dynamic> json) =>
      CareTeamMember(
        id: json['id'] as String,
        name: json['name'] as String,
        role: CareRole.values.byName(json['role'] as String),
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        clinic: json['clinic'] as String?,
      );

  @override
  List<Object?> get props => [id, name, role];
}
