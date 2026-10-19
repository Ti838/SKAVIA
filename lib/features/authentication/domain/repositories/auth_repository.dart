import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<void> signInWithPhone(String phone);
  Future<UserEntity?> verifyOtp(String verificationId, String smsCode);
  Future<void> signOut();
  Future<void> switchRoleMode(String userId, String mode);
}
