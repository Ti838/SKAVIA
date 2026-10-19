import '../entities/project_entity.dart';
import '../../data/models/task_item_model.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjectsForUser(String userId);
  Future<ProjectEntity?> getProjectById(String projectId);
  Future<List<TaskItemModel>> getProjectTasks(String projectId);
  Future<void> updateTaskStatus(String taskId, String newStatus);
  Future<void> assignTask(String taskId, String assignedWorkerId);
}
