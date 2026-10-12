import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/tables/database_tables.dart';

class AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  fb.User? get currentFirebaseUser => _firebaseAuth.currentUser;
  Session? get currentSupabaseSession => _supabase.auth.currentSession;

  /// Sign In with Email & Password
  Future<fb.UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (credential.user != null) {
      await _syncUserToSupabase(
        userId: credential.user!.uid,
        fullName: credential.user!.displayName ?? 'SKAVIA Member',
        email: credential.user!.email,
        phone: credential.user!.phoneNumber,
      );
    }
    return credential;
  }

  /// Register new user with Email, Password & Full Name, and selected Primary Role
  Future<fb.UserCredential> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String primaryRole = 'Individual Customer',
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user != null) {
      // Update display name in Firebase
      await credential.user!.updateDisplayName(fullName);

      // Sync user profile to Supabase database with SRS primary role
      await _syncUserToSupabase(
        userId: credential.user!.uid,
        fullName: fullName,
        email: email.trim(),
        phone: phone,
        primaryRole: primaryRole,
      );
    }
    return credential;
  }

  /// Sign In with Google & Sync to Supabase
  Future<fb.UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        await _syncUserToSupabase(
          userId: userCredential.user!.uid,
          fullName:
              userCredential.user!.displayName ??
              googleUser.displayName ??
              'Google User',
          email: userCredential.user!.email ?? googleUser.email,
          phone: userCredential.user!.phoneNumber,
        );
      }
      return userCredential;
    } catch (e) {
      debugPrint('[Google Auth Error]: $e');
      rethrow;
    }
  }

  /// Synchronize User Record into Supabase `users`, `customer_profiles`, and `worker_profiles` Tables
  Future<void> _syncUserToSupabase({
    required String userId,
    required String fullName,
    String? email,
    String? phone,
    String primaryRole = 'Individual Customer',
  }) async {
    try {
      final isWorker = primaryRole.toLowerCase().contains('worker');
      final isBusiness = primaryRole.toLowerCase().contains('business');
      final isOrg = primaryRole.toLowerCase().contains('organization');
      final customerType = isBusiness
          ? 'Business'
          : (isOrg ? 'Organization' : 'Individual');
      final defaultMode = isWorker ? 'worker' : 'client';

      // 1. Sync Base User Record
      await _supabase.from(DatabaseTables.users).upsert({
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'status': 'Active',
        'active_mode': defaultMode,
        'location': 'Dhaka, Bangladesh',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      // 2. Ensure Customer Profile exists
      await _supabase.from(DatabaseTables.customerProfiles).upsert({
        'user_id': userId,
        'customer_type': customerType,
      }, onConflict: 'user_id');

      // 3. Ensure Worker Profile exists for dual-mode switching
      await _supabase.from(DatabaseTables.workerProfiles).upsert({
        'user_id': userId,
        'title': isWorker
            ? 'Registered Skill Provider'
            : 'Skilled Professional',
        'bio': 'Available for on-demand & scheduled services across Dhaka.',
        'location': 'Dhaka',
        'working_area': 'All Dhaka City',
        'expected_rate': 500.00,
        'verification_status': 'Pending',
        'rating_average': 5.0,
        'total_reviews': 0,
        'completed_jobs': 0,
        'is_available': true,
      }, onConflict: 'user_id');
    } catch (e) {
      debugPrint('[Supabase Sync Warning]: $e');
    }
  }

  /// Send SMS OTP to phone number (e.g. +8801700000000)
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(fb.FirebaseAuthException error) onVerificationFailed,
    required void Function(fb.PhoneAuthCredential credential)
    onVerificationCompleted,
    void Function(String verificationId)? onCodeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout ?? (_) {},
    );
  }

  /// Verify 6-digit OTP code and sync to Supabase
  Future<fb.UserCredential> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    String? fullName,
  }) async {
    final credential = fb.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    if (userCredential.user != null) {
      if (fullName != null && fullName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(fullName);
      }
      await _syncUserToSupabase(
        userId: userCredential.user!.uid,
        fullName:
            userCredential.user!.displayName ?? fullName ?? 'SKAVIA Member',
        phone: userCredential.user!.phoneNumber,
      );
    }
    return userCredential;
  }

  /// Send password reset link to user email
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign Out from all sessions
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      _supabase.auth.signOut(),
    ]);
  }
}
