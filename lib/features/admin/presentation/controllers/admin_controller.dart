import 'package:flutter/foundation.dart';

import '../../data/datasources/admin_remote_datasource.dart';

/// Controller managing platform governance, verifications, and disputes.
class AdminController extends ChangeNotifier {
  final AdminRemoteDataSource _dataSource;

  AdminController({AdminRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? AdminRemoteDataSource();

  Map<String, dynamic> _metrics = {
    'totalUsers': 0,
    'activeRequests': 0,
    'totalVolume': 0.0,
    'isLive': false,
  };
  Map<String, dynamic> get metrics => _metrics;

  bool get isLive => _metrics['isLive'] == true;

  List<Map<String, dynamic>> _verifications = [];
  List<Map<String, dynamic>> get verifications => _verifications;

  List<Map<String, dynamic>> _disputes = [];
  List<Map<String, dynamic>> get disputes => _disputes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _metrics = await _dataSource.getPlatformMetrics();
      _verifications = await _dataSource.getPendingVerifications();
      _disputes = await _dataSource.getOpenDisputes();
    } catch (e) {
      debugPrint('[AdminController] loadDashboard error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reviewVerification(String id, bool approved) async {
    _verifications.removeWhere(
      (v) => (v['verification_id']?.toString() ?? v['id']?.toString()) == id,
    );
    notifyListeners();
    await _dataSource.reviewVerification(id, approved);
  }

  Future<void> resolveDispute(String id, String resolution) async {
    _disputes.removeWhere(
      (d) => (d['dispute_id']?.toString() ?? d['id']?.toString()) == id,
    );
    notifyListeners();
    await _dataSource.resolveDispute(id, resolution);
  }
}
