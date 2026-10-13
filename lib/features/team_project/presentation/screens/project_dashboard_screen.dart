import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_typography.dart';
import '../widgets/project_overview_tab_view.dart';
import '../widgets/project_tasks_tab_view.dart';
import '../widgets/team_member_tile.dart';

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

  // Default design mock fallback matching reference board Screens 10 & 12
  final List<Map<String, dynamic>> _fallbackMembers = [
    {
      'name': 'You',
      'role': 'Team Leader',
      'isLeader': true,
      'avatar':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    },
    {
      'name': 'Arafat',
      'role': 'Developer',
      'isLeader': false,
      'avatar':
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
    },
    {
      'name': 'Nusrat',
      'role': 'Designer',
      'isLeader': false,
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    },
    {
      'name': 'Sabbir',
      'role': 'Developer',
      'isLeader': false,
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    },
  ];

  final List<Map<String, dynamic>> _fallbackTasks = [
    {
      'id': 't1',
      'title': 'Setup project structure',
      'status': 'Completed',
      'date': 'Apr 20',
    },
    {
      'id': 't2',
      'title': 'Design UI components',
      'status': 'In Progress',
      'date': 'Apr 22',
    },
    {
      'id': 't3',
      'title': 'Implement authentication',
      'status': 'Pending',
      'date': 'Apr 25',
    },
    {
      'id': 't4',
      'title': 'API integration',
      'status': 'Pending',
      'date': 'Apr 28',
    },
    {
      'id': 't5',
      'title': 'Testing & bug fix',
      'status': 'Pending',
      'date': 'May 2',
    },
  ];

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
        project = await client
            .from('projects')
            .select('*')
            .eq('project_id', widget.projectId!)
            .maybeSingle();
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
          if (_teamMembers.isEmpty) _teamMembers = List.from(_fallbackMembers);
          if (_tasks.isEmpty) _tasks = List.from(_fallbackTasks);
          _isLoading = false;
        });
      }
    }
  }

  void _addNewTaskDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Add New Task',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Implement payment flow',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = titleController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _tasks.add({
                    'id': 't_${DateTime.now().millisecondsSinceEpoch}',
                    'title': text,
                    'status': 'Pending',
                    'date': 'May 5',
                  });
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text(
              'Add Task',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _addMemberDialog() {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Add Team Member',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Member Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  hintText: 'Role (e.g. Developer, QA)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final role = roleController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _teamMembers.add({
                    'name': name,
                    'role': role.isNotEmpty ? role : 'Developer',
                    'isLeader': false,
                  });
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
            icon: Icon(Icons.add, color: colorScheme.onSurface, size: 24),
            onPressed: () {
              if (_selectedTopTab == 1) {
                _addNewTaskDialog();
              } else {
                _addMemberDialog();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            )
          : Column(
              children: [
                // 3-Segment Top Pill Selector (Overview | Tasks | Members)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceContainerHighest
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        _buildTopTabItem(0, 'Overview'),
                        _buildTopTabItem(1, 'Tasks'),
                        _buildTopTabItem(2, 'Members'),
                      ],
                    ),
                  ),
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

  Widget _buildTopTabItem(int index, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedTopTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTopTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? colorScheme.surface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabBody() {
    switch (_selectedTopTab) {
      case 0:
        return ProjectOverviewTabView(
          budget: _budget,
          teamMembers: _teamMembers,
          onAddMember: _addMemberDialog,
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
          onAddTask: _addNewTaskDialog,
        );
      case 2:
      default:
        return _buildMembersTab();
    }
  }

  // Members Tab
  Widget _buildMembersTab() {
    return ListView.builder(
      key: const ValueKey('members_tab'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: _teamMembers.length,
      itemBuilder: (context, index) {
        final m = _teamMembers[index];
        return TeamMemberTile(member: m, showChatButton: true);
      },
    );
  }
}
