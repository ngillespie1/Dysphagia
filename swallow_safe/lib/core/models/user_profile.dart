import 'package:equatable/equatable.dart';

import 'program.dart';

/// User profile data model
class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final ProgramType? selectedProgramType;
  final DateTime? programStartDate;
  final bool onboardingComplete;
  final bool disclaimerAccepted;
  final DateTime? disclaimerAcceptedAt;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.selectedProgramType,
    this.programStartDate,
    this.onboardingComplete = false,
    this.disclaimerAccepted = false,
    this.disclaimerAcceptedAt,
    required this.createdAt,
    this.lastActiveAt,
  });

  /// Check if user has selected a program
  bool get hasProgram => selectedProgramType != null && programStartDate != null;

  /// Get user's first name for greeting
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isNotEmpty ? parts.first : name;
  }

  /// Days since program started
  int get daysSinceProgramStart {
    if (programStartDate == null) return 0;
    return DateTime.now().difference(programStartDate!).inDays;
  }

  /// Current week number (1-based)
  int get currentWeekNumber {
    if (programStartDate == null) return 1;
    return (daysSinceProgramStart ~/ 7) + 1;
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    ProgramType? selectedProgramType,
    DateTime? programStartDate,
    bool? onboardingComplete,
    bool? disclaimerAccepted,
    DateTime? disclaimerAcceptedAt,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      selectedProgramType: selectedProgramType ?? this.selectedProgramType,
      programStartDate: programStartDate ?? this.programStartDate,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      disclaimerAcceptedAt: disclaimerAcceptedAt ?? this.disclaimerAcceptedAt,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  /// Create an empty profile for new users
  factory UserProfile.empty() {
    return UserProfile(
      id: '',
      name: '',
      email: '',
      onboardingComplete: false,
      disclaimerAccepted: false,
      createdAt: DateTime.now(),
    );
  }

  /// Create a sample profile for testing
  factory UserProfile.sample() {
    return UserProfile(
      id: 'user_123',
      name: 'Sarah Johnson',
      email: 'sarah@example.com',
      selectedProgramType: ProgramType.postStroke,
      programStartDate: DateTime.now().subtract(const Duration(days: 14)),
      onboardingComplete: true,
      disclaimerAccepted: true,
      disclaimerAcceptedAt: DateTime.now().subtract(const Duration(days: 14)),
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      lastActiveAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        selectedProgramType,
        programStartDate,
        onboardingComplete,
        disclaimerAccepted,
        disclaimerAcceptedAt,
        createdAt,
        lastActiveAt,
      ];

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'selectedProgramType': selectedProgramType?.name,
      'programStartDate': programStartDate?.toIso8601String(),
      'onboardingComplete': onboardingComplete,
      'disclaimerAccepted': disclaimerAccepted,
      'disclaimerAcceptedAt': disclaimerAcceptedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      selectedProgramType: json['selectedProgramType'] != null
          ? ProgramType.values.firstWhere(
              (e) => e.name == json['selectedProgramType'],
              orElse: () => ProgramType.postStroke,
            )
          : null,
      programStartDate: json['programStartDate'] != null
          ? DateTime.parse(json['programStartDate'] as String)
          : null,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      disclaimerAccepted: json['disclaimerAccepted'] as bool? ?? false,
      disclaimerAcceptedAt: json['disclaimerAcceptedAt'] != null
          ? DateTime.parse(json['disclaimerAcceptedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
    );
  }
}
