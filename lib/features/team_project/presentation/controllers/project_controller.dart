import 'package:flutter/foundation.dart';

import '../../data/datasources/project_remote_datasource.dart';
import '../../data/models/task_item_model.dart';
import '../../domain/entities/project_entity.dart';

/// Controller managing projects, team task boards, and assignment flows.
class ProjectController extends ChangeNotifier {
  final ProjectRemoteDataSource _dataSource;

  ProjectController({ProjectRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? ProjectRemoteDataSource();

  List<ProjectEntity> _projects = [];
  List<ProjectEntity> get projects => _projects;

  List<TaskItemModel> _tasks = [];
  List<TaskItemModel> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadProjectsForUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _projects = await _dataSource.getProjectsForUser(userId);
    } catch (e) {
      debugPrint('[ProjectController] loadProjectsForUser error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProjectTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _dataSource.getProjectTasks(projectId);
    } catch (e) {
      debugPrint('[ProjectController] loadProjectTasks error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    final idx = _tasks.indexWhere((t) => t.taskId == taskId);
    if (idx != -1) {
      _tasks[idx] = _tasks[idx].copyWith(status: newStatus);
      notifyListeners();
      await _dataSource.updateTaskStatus(taskId, newStatus);
    }
  }

  Future<void> assignTask(
    String taskId,
    String assignedWorkerId,
    String workerName,
  ) async {
    final idx = _tasks.indexWhere((t) => t.taskId == taskId);
    if (idx != -1) {
      _tasks[idx] = _tasks[idx].copyWith(
        assignedWorkerId: assignedWorkerId,
        assignedWorkerName: workerName,
      );
      notifyListeners();
      await _dataSource.assignTask(taskId, assignedWorkerId);
    }
  }
}
