import '../../domain/entities/worker_profile_entity.dart';
import '../../domain/repositories/worker_repository.dart';
import '../datasources/worker_remote_datasource.dart';

class WorkerRepositoryImpl implements WorkerRepository {
  final WorkerRemoteDataSource _remoteDataSource;

  WorkerRepositoryImpl({WorkerRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? WorkerRemoteDataSource();

  @override
  Future<WorkerProfileEntity?> getWorkerProfile(String userId) {
    return _remoteDataSource.getWorkerProfile(userId);
  }

  @override
  Future<void> updateAvailability(String workerProfileId, bool isAvailable) {
    return _remoteDataSource.updateAvailability(workerProfileId, isAvailable);
  }

  @override
  Future<List<Map<String, dynamic>>> getIncomingRequests(
    String workerProfileId,
  ) {
    return _remoteDataSource.getIncomingRequests(workerProfileId);
  }

  @override
  Future<void> updateRequestStatus(String serviceRequestId, String status) {
    return _remoteDataSource.updateRequestStatus(serviceRequestId, status);
  }

  @override
  Future<double> getTotalEarnings(String workerProfileId) {
    return _remoteDataSource.getTotalEarnings(workerProfileId);
  }
}
