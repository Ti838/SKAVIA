import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_account_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final SupabaseClient _supabase;
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    SupabaseClient? supabaseClient,
    AuthRemoteDataSource? remoteDataSource,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _supabase = supabaseClient ?? Supabase.instance.client,
       _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

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
    await _remoteDataSource.sendPhoneOtp(
      phoneNumber: phone,
      onCodeSent: (_, _) {},
      onVerificationFailed: (error) => throw error,
      onVerificationCompleted: (_) {},
    );
  }

  @override
  Future<UserEntity?> verifyOtp(String verificationId, String smsCode) async {
    final userCred = await _remoteDataSource.verifyPhoneOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
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
