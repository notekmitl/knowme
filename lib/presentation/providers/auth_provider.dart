import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';

import '../../services/user_service.dart';

import '../../services/astrology_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final UserService _userService = UserService();

  bool _isLoading = false;

  String? _error;

  bool get isLoading => _isLoading;

  String? get error => _error;

  /// REGISTER

  Future<void> register({
    required String email,

    required String password,

    required String birthDate,

    required String birthTime,

    required double latitude,

    required double longitude,
  }) async {
    try {
      _setLoading(true);

      _clearError();

      final credential = await _authService.registerWithEmail(email, password);

      final user = credential?.user;

      if (user == null) {
        throw Exception("User is null");
      }

      await _userService.saveUser(user);

      /// GENERATE ASTROLOGY

      await AstrologyApiService.generateChart(
        uid: user.uid,

        birthDate: birthDate,

        birthTime: birthTime,

        latitude: latitude,

        longitude: longitude,
      );
    } on FirebaseAuthException catch (e) {
      _error = e.message;

      rethrow;
    } catch (e) {
      _error = e.toString();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// GOOGLE LOGIN

  Future<void> loginWithGoogle() async {
    try {
      _setLoading(true);

      _clearError();

      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider.addScope('email');

      googleProvider.addScope('profile');

      final userCredential = await FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      );

      final user = userCredential.user;

      if (user != null) {
        await _userService.saveUser(user);
      }
    } on FirebaseAuthException catch (e) {
      _error = e.message;

      rethrow;
    } catch (e) {
      _error = e.toString();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// FACEBOOK LOGIN

  Future<void> loginWithFacebook() async {
    try {
      _setLoading(true);

      _clearError();

      final facebookProvider = FacebookAuthProvider();

      final userCredential = await FirebaseAuth.instance.signInWithPopup(
        facebookProvider,
      );

      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,

          'name': user.displayName,

          'photoUrl': user.photoURL,

          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } on FirebaseAuthException catch (e) {
      _error = e.message;

      rethrow;
    } catch (e) {
      _error = e.toString();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// LOGOUT

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  /// HELPERS

  void _setLoading(bool value) {
    _isLoading = value;

    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
