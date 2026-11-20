import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../../shared/widgets/app_app_bar.dart';

/// Screen 15: Project Showcase ("Project Showcase") with "My Projects" and "Explore" tabs.
/// Completely data-driven with live Supabase integration and clean empty states.
class ProjectShowcaseScreen extends StatefulWidget {
  const ProjectShowcaseScreen({super.key});

  @override
  State<ProjectShowcaseScreen> createState() => _ProjectShowcaseScreenState();
}

class _ProjectShowcaseScreenState extends State<ProjectShowcaseScreen> {
  int _selectedTab = 0; // 0: My Projects, 1: Explore
  bool _isLoading = true;
  List<Map<String, dynamic>> _myProjects = [];
  List<Map<String, dynamic>> _exploreProjects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final client = tryGetSupabaseClient();
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    String? uid;
    try {
      uid = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      uid = null;
    }

    try {
      final res = await client
          .from(DatabaseTables.projects)
          .select('project_id, title, status, total_budget, created_at, client_id')
          .order('created_at', ascending: false)
          .limit(20);

      if (mounted) {
        final all = (res as List).map((p) {
          final status = p['status']?.toString().toLowerCase() ?? '';
          return {
            'id': p['project_id']?.toString() ?? '',
            'title': p['title']?.toString() ?? 'Project',
            'category': status == 'completed' ? 'Completed' : 'Active Project',
            'thumbnail': '',
            'tagColor': const Color(0xFF0F766E),
            'progress': status == 'completed' ? 1.0 : 0.0,
            'client_id': p['client_id']?.toString(),
          };
        }).toList();

        setState(() {
          _myProjects = uid != null
              ? all.where((p) => p['client_id'] == uid).toList()
              : [];
          _exploreProjects = all;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final activeList = _selectedTab == 0 ? _myProjects : _exploreProjects;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: const AppAppBar(title: 'Project Showcase'),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Top Tab (My Projects | Explore)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: tokens.subtleCardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: tokens.border),
                ),
                child: Row(
                  children: [
                    _buildTab(0, 'My Projects'),
                    _buildTab(1, 'Explore'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Responsive Projects Grid or Contextual Empty State
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: tokens.brandAccent,
                      ),
                    )
                  : activeList.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_open_rounded,
                                  size: 56,
                                  color: tokens.mutedText,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedTab == 0
                                      ? 'No Projects Yet'
                                      : 'No Public Showcases',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: context.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedTab == 0
                                      ? 'Your ongoing and completed turnkey projects will appear here.'
                                      : 'Showcase projects created by verified team leaders will appear here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: tokens.mutedText,
                                  ),
                                ),
                                if (_selectedTab == 0) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.postRequirement,
                                    ),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                    ),
                                    label: const Text('Start New Project'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final textScale =
                                MediaQuery.textScalerOf(context).scale(1);
                            final isSingleCol =
                                constraints.maxWidth < 360 || textScale > 1.3;
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isSingleCol ? 1 : 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: isSingleCol ? 1.65 : 0.82,
                              ),
                              itemCount: activeList.length,
                              itemBuilder: (context, index) {
                                return _buildProjectCard(activeList[index]);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final tokens = context.skavia;
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? tokens.brandAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? tokens.onBrandAccent : tokens.mutedText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> proj) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thumbUrl = (proj['thumbnail'] as String?)?.trim() ?? '';
    final progress = (proj['progress'] as double?) ?? 0.0;
    final tagColor = (proj['tagColor'] as Color?) ?? const Color(0xFF10B981);

    final projectId = (proj['id'] as String?)?.trim() ?? '';
    final projectTitle = (proj['title'] as String?)?.trim() ?? 'Project';

    return Material(
      color: tokens.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: projectId.isEmpty
            ? null
            : () => Navigator.pushNamed(
                context,
                AppRoutes.projectDashboard,
                arguments: {
                  'projectId': projectId,
                  'projectTitle': projectTitle,
                },
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Thumbnail / Category Header
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainerHighest
                      : tagColor.withValues(alpha: 0.12),
                ),
                child: thumbUrl.isNotEmpty
                    ? Image.network(
                        thumbUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(
                            Icons.work_outline_rounded,
                            size: 32,
                            color: tagColor,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.work_outline_rounded,
                          size: 32,
                          color: tagColor,
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    proj['category'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: tokens.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Linear Progress Indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: tokens.border,
                      valueColor: AlwaysStoppedAnimation<Color>(tagColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: tokens.mutedText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
