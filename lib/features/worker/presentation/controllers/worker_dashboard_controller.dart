import 'package:flutter/foundation.dart';

import '../../data/datasources/worker_remote_datasource.dart';

/// Controller managing worker dashboard metrics and real-time availability state.
class WorkerDashboardController extends ChangeNotifier {
  final WorkerRemoteDataSource _dataSource;

  WorkerDashboardController({WorkerRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? WorkerRemoteDataSource();

  bool _isAvailable = true;
  bool get isAvailable => _isAvailable;

  double _totalEarnings = 0.0;
  double get totalEarnings => _totalEarnings;

  List<Map<String, dynamic>> _incomingRequests = [];
  List<Map<String, dynamic>> get incomingRequests => _incomingRequests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadDashboard(String workerProfileId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _totalEarnings = await _dataSource.getTotalEarnings(workerProfileId);
      _incomingRequests = await _dataSource.getIncomingRequests(
        workerProfileId,
      );
    } catch (e) {
      debugPrint('[WorkerDashboardController] loadDashboard error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(
    String workerProfileId,
    bool available,
  ) async {
    _isAvailable = available;
    notifyListeners();
    await _dataSource.updateAvailability(workerProfileId, available);
  }
}
