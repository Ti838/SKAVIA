import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_app_bar.dart';

/// Screen 15: Project Showcase ("Project Showcase") with "My Projects" and "Explore" tabs.
class ProjectShowcaseScreen extends StatefulWidget {
  const ProjectShowcaseScreen({super.key});

  @override
  State<ProjectShowcaseScreen> createState() => _ProjectShowcaseScreenState();
}

class _ProjectShowcaseScreenState extends State<ProjectShowcaseScreen> {
  int _selectedTab = 0; // 0: My Projects, 1: Explore

  final List<Map<String, dynamic>> _myProjects = [
    {
      'title': 'HealthCare App',
      'category': 'Mobile App • Flutter',
      'thumbnail': '',
      'tagColor': Color(0xFF10B981),
      'progress': 0.85,
    },
    {
      'title': 'E-commerce Platform',
      'category': 'Web App • React',
      'thumbnail': '',
      'tagColor': Color(0xFF2563EB),
      'progress': 0.60,
    },
    {
      'title': 'Portfolio Website',
      'category': 'Web • Next.js',
      'thumbnail': '',
      'tagColor': Color(0xFF8B5CF6),
      'progress': 1.0,
    },
    {
      'title': 'Task Manager',
      'category': 'Mobile App • Flutter',
      'thumbnail': '',
      'tagColor': Color(0xFFF59E0B),
      'progress': 0.45,
    },
  ];

  final List<Map<String, dynamic>> _exploreProjects = [
    {
      'title': 'Smart FinTech Dashboard',
      'category': 'Finance • Flutter & Golang',
      'thumbnail': '',
      'tagColor': Color(0xFF0EA5E9),
      'progress': 0.90,
    },
    {
      'title': 'IoT Smart Logistics',
      'category': 'Hardware & Mobile • Python',
      'thumbnail': '',
      'tagColor': Color(0xFF10B981),
      'progress': 0.70,
    },
  ];

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

            // Responsive Projects Grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textScale = MediaQuery.textScalerOf(context).scale(1);
                  final isSingleCol =
                      constraints.maxWidth < 360 || textScale > 1.3;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
    final hasValidUrl =
        thumbUrl.startsWith('http://') || thumbUrl.startsWith('https://');
    final accentColor = proj['tagColor'] as Color? ?? tokens.brandAccent;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.projectDashboard,
          arguments: {
            'projectId': 'proj_${proj['title']}',
            'projectTitle': proj['title'] as String,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: tokens.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tokens.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: hasValidUrl
                    ? Image.network(
                        thumbUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _buildThumbnailFallback(tokens, accentColor),
                      )
                    : _buildThumbnailFallback(tokens, accentColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    proj['title'] as String,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    proj['category'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: tokens.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailFallback(
    dynamic tokens,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      color: tokens.softBlueBg,
      child: Center(
        child: Icon(
          Icons.apps_rounded,
          color: accentColor,
          size: 32,
        ),
      ),
    );
  }
}
