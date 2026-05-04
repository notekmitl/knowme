import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// =========================
  /// Google Sign-In
  /// =========================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // user cancel
        return null;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception("Firebase Error: ${e.message}");
    } catch (e) {
      throw Exception("Google Sign-In Failed");
    }
  }

  /// =========================
  /// Email Sign-In
  /// =========================
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email and password cannot be empty");
    }

    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  /// =========================
  /// Register
  /// =========================
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email and password cannot be empty");
    }

    if (password.length < 6) {
      throw Exception("Password must be at least 6 characters");
    }

    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Register failed");
    }
  }

  /// =========================
  /// Sign Out
  /// =========================
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
