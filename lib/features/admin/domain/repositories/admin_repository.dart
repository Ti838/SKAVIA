abstract class AdminRepository {
  Future<Map<String, dynamic>> getPlatformMetrics();
  Future<List<Map<String, dynamic>>> getPendingVerifications();
  Future<void> reviewVerification(String verificationId, bool isApproved);
  Future<List<Map<String, dynamic>>> getOpenDisputes();
  Future<void> resolveDispute(String disputeId, String resolution);
}
