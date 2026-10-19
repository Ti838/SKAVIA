import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl({AdminRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AdminRemoteDataSource();

  @override
  Future<Map<String, dynamic>> getPlatformMetrics() {
    return _remoteDataSource.getPlatformMetrics();
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingVerifications() {
    return _remoteDataSource.getPendingVerifications();
  }

  @override
  Future<void> reviewVerification(String verificationId, bool isApproved) {
    return _remoteDataSource.reviewVerification(verificationId, isApproved);
  }

  @override
  Future<List<Map<String, dynamic>>> getOpenDisputes() {
    return _remoteDataSource.getOpenDisputes();
  }

  @override
  Future<void> resolveDispute(String disputeId, String resolution) {
    return _remoteDataSource.resolveDispute(disputeId, resolution);
  }
}
