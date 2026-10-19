import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_typography.dart';
import '../../data/models/project_fallback_data.dart';
import '../widgets/project_action_dialogs.dart';
import '../widgets/project_members_tab_view.dart';
import '../widgets/project_overview_tab_view.dart';
import '../widgets/project_tasks_tab_view.dart';
import '../widgets/project_top_tab_selector.dart';
import 'task_board_screen.dart';
import 'team_roster_screen.dart';

/// Project Management & Task Board Screen aligned with Screen 10 & Screen 12 of SKAVIA reference design.
/// Supports Overview, Tasks, and Members tabs with live Supabase query fallback.
class ProjectDashboardScreen extends StatefulWidget {
  final String? projectId;
  final String projectTitle;

  const ProjectDashboardScreen({
    super.key,
    this.projectId,
    this.projectTitle = 'Project Alpha',
  });

  @override
  State<ProjectDashboardScreen> createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends State<ProjectDashboardScreen> {
  int _selectedTopTab = 0; // 0: Overview, 1: Tasks, 2: Members
  int _selectedTaskFilter = 0; // 0: Tasks, 1: Files, 2: Milestones

  bool _isLoading = true;
  String _title = 'Project Alpha';
  double _budget = 15000.0;
  List<Map<String, dynamic>> _teamMembers = [];
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _title = widget.projectTitle;
    _fetchRealProjectData();
  }

  Future<void> _fetchRealProjectData() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final client = Supabase.instance.client;

      Map<String, dynamic>? project;

      if (widget.projectId != null && !widget.projectId!.startsWith('proj_')) {
        var query = client
            .from('projects')
            .select('*')
            .eq('project_id', widget.projectId!);
        if (user != null) {
          query = query.eq('client_id', user.uid);
        }
        project = await query.maybeSingle();
      } else if (user != null) {
        project = await client
            .from('projects')
            .select('*')
            .eq('client_id', user.uid)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
      }

      if (project != null) {
        _title = project['title']?.toString() ?? widget.projectTitle;
        _budget = (project['total_budget'] as num?)?.toDouble() ?? 0.0;
        final projId = project['project_id'];

        final teamRes = await client
            .from('teams')
            .select('team_id, name, status')
            .eq('project_id', projId)
            .maybeSingle();

        if (teamRes != null) {
          final teamId = teamRes['team_id'];
          final membersRes = await client
              .from('team_members')
              .select(
                'team_member_id, role_in_team, is_team_leader, worker_profiles ( title, location, rating_average, users ( full_name ) )',
              )
              .eq('team_id', teamId);

          final members = <Map<String, dynamic>>[];
          for (final m in membersRes) {
            final wp = m['worker_profiles'] as Map<String, dynamic>?;
            final u = wp?['users'] as Map<String, dynamic>?;
            members.add({
              'name': u?['full_name'] ?? 'Assigned Member',
              'role': m['role_in_team'] ?? wp?['title'] ?? 'Developer',
              'isLeader': m['is_team_leader'] == true,
            });
          }

          if (members.isNotEmpty) {
            _teamMembers = members;
          }

          final tasksRes = await client
              .from('tasks')
              .select('task_id, title, status, description, created_at')
              .eq('team_id', teamId);

          if (tasksRes.isNotEmpty) {
            _tasks = tasksRes.map((t) {
              final statusRaw = t['status']?.toString() ?? 'Pending';
              String statusClean = 'Pending';
              if (statusRaw == 'Verified' || statusRaw == 'Completed') {
                statusClean = 'Completed';
              } else if (statusRaw == 'In Progress' ||
                  statusRaw == 'Submitted') {
                statusClean = 'In Progress';
              }
              return {
                'id': t['task_id']?.toString() ?? '',
                'title': t['title']?.toString() ?? 'Task',
                'status': statusClean,
                'date': 'Apr 24',
              };
            }).toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching live project data: $e');
    } finally {
      if (mounted) {
        setState(() {
          if (_teamMembers.isEmpty) {
            _teamMembers = List.from(ProjectFallbackData.fallbackMembers);
          }
          if (_tasks.isEmpty) {
            _tasks = List.from(ProjectFallbackData.fallbackTasks);
          }
          _isLoading = false;
        });
      }
    }
  }

  void _onAddNewTask() {
    ProjectActionDialogs.showAddTaskDialog(
      context,
      onTaskAdded: (text) {
        setState(() {
          _tasks.add({
            'id': 't_${DateTime.now().millisecondsSinceEpoch}',
            'title': text,
            'status': 'Pending',
            'date': 'May 5',
          });
        });
      },
    );
  }

  void _onAddNewMember() {
    ProjectActionDialogs.showAddMemberDialog(
      context,
      onMemberAdded: (name, role) {
        setState(() {
          _teamMembers.add({'name': name, 'role': role, 'isLeader': false});
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _title,
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Kanban Task Board',
            icon: Icon(
              Icons.view_kanban_outlined,
              color: colorScheme.onSurface,
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskBoardScreen(
                    projectId: widget.projectId ?? 'proj_01',
                    projectTitle: _title,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Team Roster',
            icon: Icon(
              Icons.people_outline_rounded,
              color: colorScheme.onSurface,
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TeamRosterScreen(
                    projectId: widget.projectId ?? 'proj_01',
                    projectTitle: _title,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Add Item',
            icon: Icon(Icons.add, color: colorScheme.onSurface, size: 24),
            onPressed: () {
              if (_selectedTopTab == 1) {
                _onAddNewTask();
              } else {
                _onAddNewMember();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : Column(
              children: [
                // 3-Segment Top Pill Selector (Overview | Tasks | Members)
                ProjectTopTabSelector(
                  selectedIndex: _selectedTopTab,
                  onTabSelected: (idx) => setState(() => _selectedTopTab = idx),
                ),
                const SizedBox(height: 8),

                // Content Views
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildSelectedTabBody(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSelectedTabBody() {
    switch (_selectedTopTab) {
      case 0:
        return ProjectOverviewTabView(
          budget: _budget,
          teamMembers: _teamMembers,
          onAddMember: _onAddNewMember,
        );
      case 1:
        return ProjectTasksTabView(
          tasks: _tasks,
          selectedTaskFilter: _selectedTaskFilter,
          onFilterChanged: (filter) =>
              setState(() => _selectedTaskFilter = filter),
          onToggleTaskStatus: (index) {
            setState(() {
              final task = _tasks[index];
              final status = task['status'] as String? ?? 'Pending';
              if (status == 'Completed') {
                task['status'] = 'In Progress';
              } else if (status == 'In Progress') {
                task['status'] = 'Completed';
              } else {
                task['status'] = 'In Progress';
              }
            });
          },
          onAddTask: _onAddNewTask,
        );
      case 2:
      default:
        return ProjectMembersTabView(
          teamMembers: _teamMembers,
          onAddMember: _onAddNewMember,
        );
    }
  }
}
