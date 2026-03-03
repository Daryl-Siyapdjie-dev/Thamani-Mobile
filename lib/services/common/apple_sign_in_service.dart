import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Apple Sign-In Service Provider
final appleSignInServiceProvider = Provider((ref) => AppleSignInService());

/// Service for handling Apple Sign-In operations
class AppleSignInService {
  /// Sign in with Apple
  Future<AuthorizationCredentialAppleID?> signIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      return credential;
    } catch (error) {
      // Silent error handling - return null on failure
      return null;
    }
  }

  /// Check if Apple Sign-In is available on the current platform
  Future<bool> isAvailable() async {
    return await SignInWithApple.isAvailable();
  }
}
