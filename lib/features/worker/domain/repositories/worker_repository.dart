import '../entities/worker_profile_entity.dart';

abstract class WorkerRepository {
  Future<WorkerProfileEntity?> getWorkerProfile(String userId);
  Future<void> updateAvailability(String workerProfileId, bool isAvailable);
  Future<List<Map<String, dynamic>>> getIncomingRequests(
    String workerProfileId,
  );
  Future<void> updateRequestStatus(String serviceRequestId, String status);
  Future<double> getTotalEarnings(String workerProfileId);
}
