import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_datasource.dart';
import '../models/task_item_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _remoteDataSource;

  ProjectRepositoryImpl({ProjectRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ProjectRemoteDataSource();

  @override
  Future<List<ProjectEntity>> getProjectsForUser(String userId) {
    return _remoteDataSource.getProjectsForUser(userId);
  }

  @override
  Future<ProjectEntity?> getProjectById(String projectId) {
    return _remoteDataSource.getProjectById(projectId);
  }

  @override
  Future<List<TaskItemModel>> getProjectTasks(String projectId) {
    return _remoteDataSource.getProjectTasks(projectId);
  }

  @override
  Future<void> updateTaskStatus(String taskId, String newStatus) {
    return _remoteDataSource.updateTaskStatus(taskId, newStatus);
  }

  @override
  Future<void> assignTask(String taskId, String assignedWorkerId) {
    return _remoteDataSource.assignTask(taskId, assignedWorkerId);
  }
}
