/// Magic link authentication service
/// Handles passwordless email authentication
class MagicLinkService {
  /// Send a magic link to the user's email
  /// Returns true if the link was sent successfully
  Future<MagicLinkResult> sendMagicLink(String email) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      return MagicLinkResult.failure('Invalid email address');
    }

    try {
      // TODO: Integrate with Firebase Auth or custom backend
      // For now, simulate sending an email
      await Future.delayed(const Duration(seconds: 2));

      // In production, this would:
      // 1. Generate a unique token
      // 2. Store token with expiration in database
      // 3. Send email with link containing token
      // 4. Return success

      return MagicLinkResult.success();
    } catch (e) {
      return MagicLinkResult.failure('Failed to send magic link: $e');
    }
  }

  /// Verify a magic link token
  /// Returns the user email if valid
  Future<MagicLinkVerifyResult> verifyMagicLink(String token) async {
    try {
      // TODO: Implement token verification
      // For now, simulate verification
      await Future.delayed(const Duration(seconds: 1));

      // In production, this would:
      // 1. Look up token in database
      // 2. Check if token is expired
      // 3. Get associated email
      // 4. Mark token as used
      // 5. Create/return user session

      return MagicLinkVerifyResult.success('user@example.com');
    } catch (e) {
      return MagicLinkVerifyResult.failure('Invalid or expired link');
    }
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    // TODO: Check for valid session token
    return false;
  }

  /// Sign out the current user
  Future<void> signOut() async {
    // TODO: Clear session token
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
}

/// Result of sending a magic link
class MagicLinkResult {
  final bool isSuccess;
  final String? error;

  MagicLinkResult._({
    required this.isSuccess,
    this.error,
  });

  factory MagicLinkResult.success() {
    return MagicLinkResult._(isSuccess: true);
  }

  factory MagicLinkResult.failure(String error) {
    return MagicLinkResult._(isSuccess: false, error: error);
  }
}

/// Result of verifying a magic link
class MagicLinkVerifyResult {
  final bool isSuccess;
  final String? email;
  final String? error;

  MagicLinkVerifyResult._({
    required this.isSuccess,
    this.email,
    this.error,
  });

  factory MagicLinkVerifyResult.success(String email) {
    return MagicLinkVerifyResult._(isSuccess: true, email: email);
  }

  factory MagicLinkVerifyResult.failure(String error) {
    return MagicLinkVerifyResult._(isSuccess: false, error: error);
  }
}
