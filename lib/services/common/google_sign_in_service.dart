import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google Sign-In Service Provider
final googleSignInServiceProvider = Provider((ref) => GoogleSignInService());

/// Service for handling Google Sign-In operations
/// Following the existing service pattern in the project
class GoogleSignInService {
  // Google Sign-In instance configured for access token authentication
  // OAuth client configured in google-services.json with SHA-1: BA:EF:A0:EB:C0:BD:5F:8C:66:8B:EB:8F:D1:1B:F3:35:BB:8B:7B:D9
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google
  /// Uses signInSilently first to avoid UI flash, falls back to interactive
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Try silent sign-in first (no UI, faster, no black bar)
      // Falls back to interactive sign-in if silent fails
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();
      return account;
    } catch (error) {
      // Silent error handling - return null on failure
      return null;
    }
  }

  /// Get Google access token from account
  /// Returns access token string if successful, null otherwise
  Future<String?> getAccessToken(GoogleSignInAccount account) async {
    try {
      final auth = await account.authentication;
      return auth.accessToken;
    } catch (error) {
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      // Silent error handling
    }
  }

  /// Disconnect Google account (revoke access)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      // Silent error handling
    }
  }

  /// Check if user is currently signed in
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (error) {
      return false;
    }
  }

  /// Get current signed-in user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
