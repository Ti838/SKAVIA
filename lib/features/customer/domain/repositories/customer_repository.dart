import '../entities/requirement_entity.dart';

abstract class CustomerRepository {
  Future<List<RequirementEntity>> getCustomerRequirements(String clientId);
  Future<String> createRequirement(RequirementEntity requirement);
  Future<List<Map<String, dynamic>>> getActiveBookings(String clientId);
}
