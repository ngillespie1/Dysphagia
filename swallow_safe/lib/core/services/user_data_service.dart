import '../models/user_profile.dart';
import '../models/program.dart';
import 'local_storage_service.dart';

/// Service for managing user data operations
class UserDataService {
  final LocalStorageService _storage;

  UserDataService({required LocalStorageService storage}) : _storage = storage;

  /// Get current user profile
  UserProfile? getCurrentUser() {
    final data = _storage.getUserProfile();
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  /// Save user profile
  Future<void> saveUser(UserProfile user) async {
    await _storage.saveUserProfile(user.toJson());
  }

  /// Update user name
  Future<UserProfile?> updateUserName(String name) async {
    final current = getCurrentUser();
    if (current == null) return null;
    
    final updated = current.copyWith(name: name);
    await saveUser(updated);
    return updated;
  }

  /// Update selected program
  Future<UserProfile?> updateProgram(ProgramType type) async {
    final current = getCurrentUser();
    if (current == null) return null;
    
    final updated = current.copyWith(
      selectedProgramType: type,
      programStartDate: DateTime.now(),
    );
    await saveUser(updated);
    return updated;
  }

  /// Complete onboarding with user data
  Future<UserProfile> completeOnboarding({
    required String name,
    required String email,
    required ProgramType programType,
    bool disclaimerAccepted = false,
    DateTime? disclaimerAcceptedAt,
  }) async {
    final user = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      selectedProgramType: programType,
      programStartDate: DateTime.now(),
      onboardingComplete: true,
      disclaimerAccepted: disclaimerAccepted,
      disclaimerAcceptedAt: disclaimerAcceptedAt,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    await saveUser(user);
    await _storage.setOnboardingComplete(true);
    
    return user;
  }

  /// Update last active timestamp
  Future<void> updateLastActive() async {
    final current = getCurrentUser();
    if (current == null) return;
    
    final updated = current.copyWith(lastActiveAt: DateTime.now());
    await saveUser(updated);
  }

  /// Check if user exists and onboarding is complete
  bool isUserReady() {
    return _storage.hasUser() && _storage.isOnboardingComplete();
  }

  /// Clear all user data (logout)
  Future<void> logout() async {
    await _storage.clearUserProfile();
    await _storage.setOnboardingComplete(false);
  }
}
