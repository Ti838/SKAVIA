import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/project_model.dart';
import '../models/task_item_model.dart';

class ProjectRemoteDataSource {
  final SupabaseClient _client;

  ProjectRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<ProjectModel>> getProjectsForUser(String userId) async {
    try {
      final res = await _client
          .from('projects')
          .select('*')
          .or('client_id.eq.$userId,team_leader_id.eq.$userId')
          .order('start_date', ascending: false);

      return (res as List).map((r) => ProjectModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('[ProjectRemoteDataSource] getProjectsForUser notice: $e');
      return [];
    }
  }

  Future<ProjectModel?> getProjectById(String projectId) async {
    try {
      final res = await _client
          .from('projects')
          .select('*')
          .eq('project_id', projectId)
          .maybeSingle();

      if (res != null) return ProjectModel.fromJson(res);
      return null;
    } catch (e) {
      debugPrint('[ProjectRemoteDataSource] getProjectById notice: $e');
      return null;
    }
  }

  Future<List<TaskItemModel>> getProjectTasks(String projectId) async {
    try {
      final res = await _client
          .from('tasks')
          .select('*')
          .eq('project_id', projectId)
          .order('due_date', ascending: true);

      return (res as List).map((r) => TaskItemModel.fromJson(r)).toList();
    } catch (e) {
      debugPrint('[ProjectRemoteDataSource] getProjectTasks notice: $e');
      return [];
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _client
          .from('tasks')
          .update({'status': newStatus})
          .eq('task_id', taskId);
    } catch (e) {
      debugPrint('[ProjectRemoteDataSource] updateTaskStatus notice: $e');
    }
  }

  Future<void> assignTask(String taskId, String assignedWorkerId) async {
    try {
      await _client
          .from('tasks')
          .update({'assigned_to': assignedWorkerId})
          .eq('task_id', taskId);
    } catch (e) {
      debugPrint('[ProjectRemoteDataSource] assignTask notice: $e');
    }
  }
}
