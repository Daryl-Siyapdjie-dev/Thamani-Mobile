import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// GoogleSignIn singleton instance
/// Configured with OAuth 2.0 Client ID for Android
/// Following official google_sign_in package documentation
final GoogleSignIn _googleSignIn = GoogleSignIn(
  // OAuth 2.0 scopes
  scopes: <String>[
    'email',
    'profile',
  ],
  // CRITICAL: serverClientId is required for Android to avoid ApiException: 10
  // This is the OAuth 2.0 Web Client ID from Google Cloud Console
  serverClientId: '1075135380266-qhr6qhoc5jiqo7uab2fqih22n71ovpdp.apps.googleusercontent.com',
);

/// Provider for GoogleSignInService
final googleSignInServiceProvider = Provider((ref) => GoogleSignInService(ref));

/// Service class to handle Google Sign-In operations
/// Following the existing service pattern with Ref injection
/// Based on official google_sign_in package documentation:
/// https://pub.dev/packages/google_sign_in
class GoogleSignInService {
  final Ref ref;

  GoogleSignInService(this.ref);

  /// Initiates Google Sign-In flow
  /// Returns GoogleSignInAccount if successful, null if user cancels or error occurs
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      // Disconnect any previous account first (recommended by docs)
      await _googleSignIn.signOut();

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return null;
      }

      return account;
    } catch (error) {
      return null;
    }
  }

  /// Gets the access token from the Google account
  /// Required to send to backend for authentication
  /// Returns access token string if successful, null otherwise
  Future<String?> getGoogleAccessToken(GoogleSignInAccount account) async {
    try {
      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.accessToken;
    } catch (error) {
      return null;
    }
  }

  /// Signs out the user from Google
  /// Call this when user logs out from the app
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      // Silent error handling
    }
  }

  /// Disconnects the user from Google (revokes access)
  /// More complete than signOut - removes all permissions
  Future<void> disconnectGoogle() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      // Silent error handling
    }
  }

  /// Checks if user is currently signed in with Google
  /// Useful for checking auth state on app startup
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (error) {
      return false;
    }
  }

  /// Silently signs in if user was previously signed in
  /// Useful for auto-login on app startup
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (error) {
      return null;
    }
  }

  /// Gets the current signed-in account
  /// Returns null if no user is signed in
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
