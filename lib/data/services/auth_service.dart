import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class AuthService {
  final FirebaseAuth _auth;
  bool _googleSignInInitialized = false;

  AuthService({FirebaseAuth? auth})
    : _auth =
          auth ??
          (Firebase.apps.isNotEmpty
              ? FirebaseAuth.instance
              : MockFirebaseAuth());

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized && Firebase.apps.isNotEmpty) {
      await google.GoogleSignIn.instance.initialize();
      _googleSignInInitialized = true;
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final googleUser = await google.GoogleSignIn.instance.authenticate();

      final idToken = googleUser.authentication.idToken;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Authentication may be cancelled by the user, leading to a specific exception.
      rethrow;
    }
  }

  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      if (_googleSignInInitialized) {
        await google.GoogleSignIn.instance.signOut();
      }
    } catch (_) {
      // Ignore errors on Google sign out (e.g. if not signed in with Google)
    }
  }
}
