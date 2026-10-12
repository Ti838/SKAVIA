import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../data/datasources/auth_remote_datasource.dart';

class AuthController extends ChangeNotifier {
  final AuthRemoteDataSource _dataSource = AuthRemoteDataSource();

  bool _isLoading = false;
  String? _errorMessage;
  fb.User? _user;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  fb.User? get user => _user ?? _dataSource.currentFirebaseUser;
  bool get isAuthenticated => user != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign In with Email & Password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _dataSource.signInWithEmail(
        email: email,
        password: password,
      );
      _user = credential.user;
      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Authentication failed.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) => login(email, password);

  /// Register new user with selected primary role
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String primaryRole = 'Individual Customer',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _dataSource.registerWithEmail(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        primaryRole: primaryRole,
      );
      _user = credential.user;
      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Registration failed.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign In with Google
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _dataSource.signInWithGoogle();
      if (credential != null) {
        _user = credential.user;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() => loginWithGoogle();

  String? _verificationId;
  String? get verificationId => _verificationId;

  /// Send SMS OTP to phone number
  Future<bool> sendPhoneOtp(String phoneNumber) async {
    _setLoading(true);
    _setError(null);
    try {
      await _dataSource.sendPhoneOtp(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
        },
        onVerificationFailed: (e) {
          _setError(e.message ?? 'Phone verification failed.');
          _setLoading(false);
        },
        onVerificationCompleted: (credential) async {
          _setLoading(false);
        },
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Verify 6-digit SMS code
  Future<bool> verifyPhoneOtp(String smsCode, {String? fullName}) async {
    if (_verificationId == null) {
      _setError('Verification session expired. Please request a new code.');
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _dataSource.verifyPhoneOtp(
        verificationId: _verificationId!,
        smsCode: smsCode,
        fullName: fullName,
      );
      _user = credential.user;
      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Invalid OTP code.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _dataSource.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Password reset request failed.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _dataSource.signOut();
    _user = null;
    _verificationId = null;
    notifyListeners();
  }
}
