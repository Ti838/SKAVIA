import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../profile/data/datasources/profile_remote_datasource.dart';

class AuthRemoteDataSource {
  fb.FirebaseAuth? get _firebaseAuth {
    try {
      return fb.FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient? get _supabase => tryGetSupabaseClient();

  GoogleSignIn? _googleSignInInstance;
  GoogleSignIn get _googleSignIn =>
      _googleSignInInstance ??= GoogleSignIn(scopes: ['email', 'profile']);

  fb.User? get currentFirebaseUser => _firebaseAuth?.currentUser;
  Session? get currentSupabaseSession => _supabase?.auth.currentSession;

  fb.FirebaseAuth _requireFirebaseAuth() {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw fb.FirebaseAuthException(
        code: 'firebase-not-initialized',
        message: 'Authentication service is not initialized yet.',
      );
    }
    return auth;
  }

  /// Sign In with Email & Password
  Future<fb.UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _requireFirebaseAuth().signInWithEmailAndPassword(
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
    final credential = await _requireFirebaseAuth()
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

    if (credential.user != null) {
      await credential.user!.updateDisplayName(fullName);

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
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw fb.FirebaseAuthException(
          code: 'google-sign-in-missing-tokens',
          message:
              'Google Sign-In returned no tokens. '
              'Please add your debug SHA-1 fingerprint to Firebase Console.',
        );
      }

      final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _requireFirebaseAuth().signInWithCredential(
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
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('[Google Auth FirebaseException]: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[Google Auth Error]: $e');
      rethrow;
    }
  }

  /// Synchronize User Record into Supabase `users`, `customer_profiles`, `worker_profiles` & `user_sessions`
  Future<void> _syncUserToSupabase({
    required String userId,
    required String fullName,
    String? email,
    String? phone,
    String primaryRole = 'Individual Customer',
  }) async {
    final supabase = _supabase;
    if (supabase == null) return;

    try {
      final existingUser = await supabase
          .from(DatabaseTables.users)
          .select('user_id, active_mode, full_name')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingUser != null) {
        final updateMap = <String, dynamic>{
          'updated_at': DateTime.now().toIso8601String(),
        };
        if (email != null && email.isNotEmpty) updateMap['email'] = email;
        if (phone != null && phone.isNotEmpty) updateMap['phone'] = phone;
        await supabase
            .from(DatabaseTables.users)
            .update(updateMap)
            .eq('user_id', userId);
        await ProfileRemoteDataSource(
          supabase: supabase,
        ).registerCurrentSession(userId);
        return;
      }

      final lowerRole = primaryRole.toLowerCase();
      final isWorker = lowerRole.contains('worker');
      final isBusiness =
          lowerRole.contains('business') || lowerRole.contains('enterprise');
      final isOrg = lowerRole.contains('organization');
      final customerType = isBusiness
          ? 'Business Client'
          : (isOrg ? 'Organization' : 'Individual');
      final defaultMode = isWorker
          ? 'worker'
          : ((isBusiness || isOrg) ? 'enterprise' : 'client');

      // 1. Sync Base User Record for new user
      await supabase.from(DatabaseTables.users).insert({
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'status': 'Active',
        'active_mode': defaultMode,
        'location': 'Dhaka, Bangladesh',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Ensure Customer Profile exists
      await supabase.from(DatabaseTables.customerProfiles).upsert({
        'user_id': userId,
        'customer_type': customerType,
      }, onConflict: 'user_id');

      // 3. Ensure Worker Profile exists for dual-mode switching
      await supabase.from(DatabaseTables.workerProfiles).upsert({
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

      // 4. Register current device session
      await ProfileRemoteDataSource(
        supabase: supabase,
      ).registerCurrentSession(userId);
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
    await _requireFirebaseAuth().verifyPhoneNumber(
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
    final userCredential = await _requireFirebaseAuth().signInWithCredential(
      credential,
    );
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
    await _requireFirebaseAuth().sendPasswordResetEmail(email: email.trim());
  }

  /// Sign Out from all sessions
  Future<void> signOut() async {
    final futures = <Future<void>>[];
    if (_firebaseAuth != null) {
      futures.add(_firebaseAuth!.signOut());
    }
    futures.add(_googleSignIn.signOut().catchError((_) => null));
    if (_supabase != null) {
      futures.add(_supabase!.auth.signOut().catchError((_) {}));
    }
    await Future.wait(futures);
  }
}
