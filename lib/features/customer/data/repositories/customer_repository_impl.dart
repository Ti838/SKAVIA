import '../../domain/entities/requirement_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;

  CustomerRepositoryImpl({CustomerRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? CustomerRemoteDataSource();

  @override
  Future<List<RequirementEntity>> getCustomerRequirements(String clientId) {
    return _remoteDataSource.getCustomerRequirements(clientId);
  }

  @override
  Future<String> createRequirement(RequirementEntity requirement) {
    return _remoteDataSource.createRequirement(requirement);
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveBookings(String clientId) {
    return _remoteDataSource.getActiveBookings(clientId);
  }
}
