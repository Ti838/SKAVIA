import 'package:flutter/foundation.dart';

import '../../data/datasources/customer_remote_datasource.dart';
import '../../domain/entities/requirement_entity.dart';

/// Controller managing customer dashboard live state and bookings.
class CustomerDashboardController extends ChangeNotifier {
  final CustomerRemoteDataSource _dataSource;

  CustomerDashboardController({CustomerRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? CustomerRemoteDataSource();

  List<RequirementEntity> _requirements = [];
  List<RequirementEntity> get requirements => _requirements;

  List<Map<String, dynamic>> _activeBookings = [];
  List<Map<String, dynamic>> get activeBookings => _activeBookings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadDashboard(String clientId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _requirements = await _dataSource.getCustomerRequirements(clientId);
      _activeBookings = await _dataSource.getActiveBookings(clientId);
    } catch (e) {
      debugPrint('[CustomerDashboardController] loadDashboard notice: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
