import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_account_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final SupabaseClient _supabase;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    SupabaseClient? supabaseClient,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _supabase = supabaseClient ?? Supabase.instance.client;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;

    try {
      final res = await _supabase
          .from('users')
          .select('*')
          .eq('user_id', fbUser.uid)
          .maybeSingle();
      if (res != null) {
        return UserAccountModel.fromJson(res);
      }
    } catch (_) {}

    return UserEntity(
      userId: fbUser.uid,
      fullName: fbUser.displayName ?? 'SKAVIA Member',
      email: fbUser.email,
      phone: fbUser.phoneNumber,
      avatarUrl: fbUser.photoURL,
    );
  }

  @override
  Future<void> signInWithPhone(String phone) async {
    // Handled via Firebase verifyPhoneNumber in AuthRemoteDataSource
  }

  @override
  Future<UserEntity?> verifyOtp(String verificationId, String smsCode) async {
    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCred = await _firebaseAuth.signInWithCredential(cred);
    if (userCred.user != null) {
      return getCurrentUser();
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> switchRoleMode(String userId, String mode) async {
    try {
      await _supabase
          .from('users')
          .update({'active_mode': mode})
          .eq('user_id', userId);
    } catch (_) {}
  }
}
