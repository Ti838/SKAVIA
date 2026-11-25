import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/config/app_config.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../profile/data/datasources/profile_remote_datasource.dart';

class AuthRemoteDataSource {
  /// Cached OTP, delivery channel, and targets for OTP verification
  static String? latestSentOtp;
  static String? latestDeliveryChannel;
  static String? latestTargetPhone;
  static String? latestTargetEmail;
  fb.FirebaseAuth? get _firebaseAuth {
    try {
      return fb.FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient? get _supabase => tryGetSupabaseClient();

  static const String _googleWebClientId =
      '691596725478-qf8kcvtltvjh8mio4su339jh9iqp24s1.apps.googleusercontent.com';

  GoogleSignIn? _googleSignInInstance;
  GoogleSignIn get _googleSignIn => _googleSignInInstance ??= GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: kIsWeb ? null : _googleWebClientId,
  );

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
        await ProfileRemoteDataSource(supabase: supabase)
            .registerCurrentSession(userId);
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

      final firebasePhotoUrl = _firebaseAuth?.currentUser?.photoURL;

      final existingByPhone = (phone != null && phone.isNotEmpty)
          ? await supabase
                .from(DatabaseTables.users)
                .select('user_id, email')
                .eq('phone', phone)
                .maybeSingle()
          : null;

      // 1. Sync Base User Record for new user (including Google photoURL if present)
      await supabase.from(DatabaseTables.users).insert({
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        if (phone != null && phone.isNotEmpty && existingByPhone == null)
          'phone': phone,
        if (firebasePhotoUrl != null && firebasePhotoUrl.trim().isNotEmpty)
          'avatar_url': firebasePhotoUrl.trim(),
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

      // 3. Only create Worker Profile when the user explicitly signed up as a Worker
      //    (Strict Real Data & Role Integrity: never enroll pure customers as available workers)
      if (isWorker) {
        await supabase.from(DatabaseTables.workerProfiles).upsert({
          'user_id': userId,
          'title': 'Skilled Technician',
          'bio': '',
          'location': 'Dhaka',
          'expected_rate': 0.0,
          'verification_status': 'Unverified',
          'rating_average': 0.0,
          'total_reviews': 0,
          'completed_jobs': 0,
          'is_available': false,
        }, onConflict: 'user_id');
      }

      // 4. Register current device session
      await ProfileRemoteDataSource(supabase: supabase)
          .registerCurrentSession(userId);
    } catch (e) {
      debugPrint('[Supabase Sync Warning]: $e');
    }
  }

  /// Send Verification OTP via SKAVIA Cloud OTP Engine (Real Email via Resend/SMTP,
  /// Real SMS when gateway configured, or free in-app fallback without Firebase Blaze billing).
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    String? email,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(fb.FirebaseAuthException error) onVerificationFailed,
    required void Function(fb.PhoneAuthCredential credential)
    onVerificationCompleted,
    void Function(String verificationId)? onCodeAutoRetrievalTimeout,
  }) async {
    latestTargetPhone = phoneNumber;
    latestTargetEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim()
        : null;
    latestSentOtp = null;
    latestDeliveryChannel = null;

    try {
      final url = Uri.parse(
        '${AppConfig.releaseApiBaseUrl}/api/public/auth/phone/send-otp',
      );
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phoneNumber': phoneNumber,
              if (latestTargetEmail != null) 'email': latestTargetEmail,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final verificationId =
            data['verificationId']?.toString() ??
            'vid_${DateTime.now().millisecondsSinceEpoch}';
        final otp = data['otp']?.toString();
        latestDeliveryChannel = data['deliveryChannel']?.toString();
        final deliveredEmail = data['email']?.toString();
        if (deliveredEmail != null && deliveredEmail.isNotEmpty) {
          latestTargetEmail = deliveredEmail;
        }
        latestSentOtp = (otp != null && otp.isNotEmpty) ? otp : null;
        onCodeSent(verificationId, null);
        return;
      }

      final errorMsg =
          data['error']?.toString() ?? 'Failed to dispatch verification code.';
      final code = response.statusCode == 429
          ? 'too-many-requests'
          : (response.statusCode == 400
                ? 'invalid-phone-number'
                : 'otp-dispatch-failed');
      onVerificationFailed(
        fb.FirebaseAuthException(code: code, message: errorMsg),
      );
    } catch (e) {
      debugPrint('[Cloud OTP Dispatch Error]: $e');
      onVerificationFailed(
        fb.FirebaseAuthException(
          code: 'network-request-failed',
          message:
              'Unable to reach verification server. Please check your internet connection and try again.',
        ),
      );
    }
  }

  /// Send 6-digit OTP directly to user's Email via Resend/SMTP.
  Future<void> sendEmailOtp({
    required String email,
    required void Function(String verificationId) onCodeSent,
    required void Function(fb.FirebaseAuthException error) onVerificationFailed,
  }) async {
    final trimmed = email.trim();
    latestTargetPhone = null;
    latestTargetEmail = trimmed;
    latestSentOtp = null;
    latestDeliveryChannel = null;

    try {
      final url = Uri.parse(
        '${AppConfig.releaseApiBaseUrl}/api/public/auth/email/send-otp',
      );
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': trimmed}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        final verificationId =
            data['verificationId']?.toString() ??
            'vid_${DateTime.now().millisecondsSinceEpoch}';
        final otp = data['otp']?.toString();
        latestDeliveryChannel = data['deliveryChannel']?.toString() ?? 'email';
        latestSentOtp = (otp != null && otp.isNotEmpty) ? otp : null;
        onCodeSent(verificationId);
        return;
      }

      final errorMsg =
          data['error']?.toString() ?? 'Failed to send verification email.';
      onVerificationFailed(
        fb.FirebaseAuthException(
          code: response.statusCode == 429
              ? 'too-many-requests'
              : 'otp-dispatch-failed',
          message: errorMsg,
        ),
      );
    } catch (e) {
      debugPrint('[Email OTP Dispatch Error]: $e');
      onVerificationFailed(
        fb.FirebaseAuthException(
          code: 'network-request-failed',
          message:
              'Unable to reach verification server. Please check your internet connection.',
        ),
      );
    }
  }

  /// Verify 6-digit OTP code strictly on server, then authenticate into Firebase & Supabase.
  Future<fb.UserCredential> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    String? fullName,
  }) async {
    final phone = latestTargetPhone ?? '';
    final email = latestTargetEmail ?? '';
    final isEmailOnlyFlow = phone.isEmpty && email.isNotEmpty;
    final code = smsCode.trim();

    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      throw fb.FirebaseAuthException(
        code: 'invalid-verification-code',
        message: 'Please enter a valid 6-digit numeric verification code.',
      );
    }

    final url = Uri.parse(
      isEmailOnlyFlow
          ? '${AppConfig.releaseApiBaseUrl}/api/public/auth/email/verify-otp'
          : '${AppConfig.releaseApiBaseUrl}/api/public/auth/phone/verify-otp',
    );
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            if (isEmailOnlyFlow) 'email': email else 'phoneNumber': phone,
            'smsCode': code,
            'verificationId': verificationId,
            'fullName': fullName,
          }),
        )
        .timeout(const Duration(seconds: 15));

    Map<String, dynamic> data = <String, dynamic>{};
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}

    if (response.statusCode != 200 || data['success'] != true) {
      final serverMessage =
          data['error']?.toString() ??
          'Invalid or expired verification code. Please check the 6-digit OTP or tap Resend.';
      final codeStr = response.statusCode == 429
          ? 'too-many-requests'
          : 'invalid-verification-code';
      throw fb.FirebaseAuthException(code: codeStr, message: serverMessage);
    }

    final userMap = data['user'] as Map<String, dynamic>?;
    final existingEmail = userMap?['existingEmail']?.toString();
    if (existingEmail != null &&
        existingEmail.isNotEmpty &&
        !existingEmail.endsWith('@skavia.internal')) {
      throw fb.FirebaseAuthException(
        code: 'account-exists-with-different-credential',
        message:
            'This phone number is already linked to $existingEmail. Please sign in with Email or Google.',
      );
    }

    final bridgeEmail = userMap?['bridgeEmail']?.toString();
    final bridgePassword = userMap?['bridgePassword']?.toString();
    final resolvedName = userMap?['displayName']?.toString() ?? fullName;

    if (bridgeEmail == null ||
        bridgeEmail.isEmpty ||
        bridgePassword == null ||
        bridgePassword.isEmpty) {
      throw fb.FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Verification response incomplete. Please request a new OTP.',
      );
    }

    final auth = _requireFirebaseAuth();
    fb.UserCredential credential;
    try {
      credential = await auth.signInWithEmailAndPassword(
        email: bridgeEmail,
        password: bridgePassword,
      );
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'wrong-password') {
        credential = await auth.createUserWithEmailAndPassword(
          email: bridgeEmail,
          password: bridgePassword,
        );
      } else {
        rethrow;
      }
    }

    latestSentOtp = null;
    latestDeliveryChannel = null;
    latestTargetEmail = null;

    if (credential.user != null) {
      if (resolvedName != null && resolvedName.isNotEmpty) {
        await credential.user!.updateDisplayName(resolvedName);
      }
      await _syncUserToSupabase(
        userId: credential.user!.uid,
        fullName:
            credential.user!.displayName ?? resolvedName ?? 'SKAVIA Member',
        phone: phone,
      );
    }
    return credential;
  }

  /// Sign In directly with a PhoneAuthCredential (for auto-retrieval / instant verification)
  Future<fb.UserCredential> signInWithPhoneCredential(
    fb.AuthCredential credential, {
    String? fullName,
  }) async {
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
    latestSentOtp = null;
    latestDeliveryChannel = null;
    latestTargetEmail = null;
    latestTargetPhone = null;
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
