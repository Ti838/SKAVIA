import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../notifications/presentation/controllers/notification_center_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class AuthController extends ChangeNotifier {
  final AuthRemoteDataSource _dataSource = AuthRemoteDataSource();

  static String? _globalVerificationId;

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
      // User cancelled the Google sign-in picker
      _setLoading(false);
      return false;
    } on fb.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'An account already exists with the same email. Try signing in with email/password.';
          break;
        case 'invalid-credential':
          message = 'Invalid credentials. Please try again.';
          break;
        case 'google-sign-in-missing-tokens':
          message =
              'Google Sign-In configuration issue. Please contact support.';
          break;
        default:
          message = e.message ?? 'Google Sign-In failed. Please try again.';
      }
      _setError(message);
      _setLoading(false);
      return false;
    } catch (e) {
      final errStr = e.toString();
      // PlatformException from google_sign_in plugin
      if (errStr.contains('sign_in_canceled') ||
          errStr.contains('sign_in_cancelled')) {
        _setLoading(false);
        return false; // User cancelled — don't show error
      }
      if (errStr.contains('network_error') ||
          errStr.contains('ApiException: 7')) {
        _setError('Network error. Please check your internet connection.');
      } else if (errStr.contains('ApiException: 10')) {
        _setError(
          'Google Sign-In is not configured correctly. '
          'SHA-1 fingerprint may need to be added to Firebase.',
        );
      } else {
        _setError('Google Sign-In failed. Please try again.');
      }
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() => loginWithGoogle();

  String? _verificationId;
  String? get verificationId => _verificationId ?? _globalVerificationId;
  set verificationId(String? val) {
    _verificationId = val;
    _globalVerificationId = val;
  }

  /// Send OTP to phone number (with optional email delivery via Resend/SMTP)
  Future<bool> sendPhoneOtp(String phoneNumber, {String? email}) async {
    _setLoading(true);
    _setError(null);
    final completer = Completer<bool>();

    try {
      await _dataSource.sendPhoneOtp(
        phoneNumber: phoneNumber,
        email: email,
        onCodeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _globalVerificationId = verificationId;
          _setLoading(false);
          if (!completer.isCompleted) completer.complete(true);
        },
        onVerificationFailed: (e) {
          debugPrint('[Firebase Phone Auth Error]: ${e.code} - ${e.message}');
          if (e.code == 'operation-not-allowed') {
            _setError(
              'Firebase Phone Authentication is disabled in Firebase Console (skavia-113a3). Please enable Phone sign-in in Firebase Console -> Authentication -> Sign-in method, or sign in using Email or Google.',
            );
          } else if (e.code == 'invalid-phone-number') {
            _setError(
              'Invalid phone number format. Please ensure the number includes a valid Bangladesh prefix (e.g. 017... or +8801...).',
            );
          } else if (e.code == 'quota-exceeded') {
            _setError(
              'Daily SMS quota exceeded. Please sign in using Email or Google, or use a test phone number in Firebase Console.',
            );
          } else if (e.code == 'too-many-requests') {
            _setError(
              'Too many attempts from this device. Please wait a few minutes before trying again, or use Email / Google sign-in.',
            );
          } else if (e.code == 'app-not-authorized' ||
              (e.message != null &&
                  (e.message!.toLowerCase().contains('region') ||
                      e.message!.toLowerCase().contains('blocked')))) {
            _setError(
              'SMS to Bangladesh (+880) is not enabled in Firebase Console. Please add Bangladesh (+880) to Authentication -> Settings -> SMS region policy.',
            );
          } else {
            _setError(e.message ?? 'Phone verification failed.');
          }
          _setLoading(false);
          if (!completer.isCompleted) completer.complete(false);
        },
        onVerificationCompleted: (credential) async {
          try {
            final userCred =
                await _dataSource.signInWithPhoneCredential(credential);
            _user = userCred.user;
          } catch (e) {
            debugPrint('[Phone Auth onVerificationCompleted auto-sign-in]: $e');
          }
          _setLoading(false);
          notifyListeners();
          if (!completer.isCompleted) completer.complete(true);
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
          _globalVerificationId = verificationId;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () {
        _setLoading(false);
        _setError(
          'Verification code request timed out. Please check phone number.',
        );
        return false;
      },
    );
  }

  /// Verify 6-digit SMS code
  Future<bool> verifyPhoneOtp(String smsCode, {String? fullName}) async {
    final activeId = verificationId;
    if (activeId == null) {
      _setError('Verification session expired. Please request a new code.');
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _dataSource.verifyPhoneOtp(
        verificationId: activeId,
        smsCode: smsCode,
        fullName: fullName,
      );
      _user = credential.user;
      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        _setError('Invalid verification code. Please check the 6-digit OTP.');
      } else if (e.code == 'session-expired') {
        _setError('Verification session expired. Please tap Resend Code.');
      } else {
        _setError(e.message ?? 'Invalid OTP code.');
      }
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

  /// Logout and wipe session caches & stale OTP verification state
  Future<void> logout() async {
    await _dataSource.signOut();
    _user = null;
    _verificationId = null;
    _globalVerificationId = null;
    _errorMessage = null;
    NotificationCenterController.instance.clearSession();
    ProfileController.shared.clearSession();
    notifyListeners();
  }
}
