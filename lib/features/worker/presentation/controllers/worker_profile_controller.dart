import 'package:flutter/foundation.dart';

import '../../data/datasources/worker_remote_datasource.dart';
import '../../domain/entities/worker_profile_entity.dart';

/// Controller managing worker profile data, skills, and verification status.
class WorkerProfileController extends ChangeNotifier {
  final WorkerRemoteDataSource _dataSource;

  WorkerProfileController({WorkerRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? WorkerRemoteDataSource();

  WorkerProfileEntity? _profile;
  WorkerProfileEntity? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _dataSource.getWorkerProfile(userId);
    } catch (e) {
      debugPrint('[WorkerProfileController] loadProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
