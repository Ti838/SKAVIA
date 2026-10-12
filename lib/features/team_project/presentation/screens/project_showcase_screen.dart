import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/router/app_routes.dart';

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
      'thumbnail':
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400',
      'tagColor': Color(0xFF10B981),
      'progress': 0.85,
    },
    {
      'title': 'E-commerce Platform',
      'category': 'Web App • React',
      'thumbnail':
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
      'tagColor': Color(0xFF2563EB),
      'progress': 0.60,
    },
    {
      'title': 'Portfolio Website',
      'category': 'Web • Next.js',
      'thumbnail':
          'https://images.unsplash.com/photo-1467232004584-a241de8bcf5d?w=400',
      'tagColor': Color(0xFF8B5CF6),
      'progress': 1.0,
    },
    {
      'title': 'Task Manager',
      'category': 'Mobile App • Flutter',
      'thumbnail':
          'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400',
      'tagColor': Color(0xFFF59E0B),
      'progress': 0.45,
    },
  ];

  final List<Map<String, dynamic>> _exploreProjects = [
    {
      'title': 'Smart FinTech Dashboard',
      'category': 'Finance • Flutter & Golang',
      'thumbnail':
          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
      'tagColor': Color(0xFF0EA5E9),
      'progress': 0.90,
    },
    {
      'title': 'IoT Smart Logistics',
      'category': 'Hardware & Mobile • Python',
      'thumbnail':
          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400',
      'tagColor': Color(0xFF10B981),
      'progress': 0.70,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeList = _selectedTab == 0 ? _myProjects : _exploreProjects;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Project Showcase',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Top Tab (My Projects | Explore)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
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

            // Projects 2-Column Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: activeList.length,
                itemBuilder: (context, index) {
                  final proj = activeList[index];
                  return _buildProjectCard(proj);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> proj) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail image with curved top
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  proj['thumbnail'] as String,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stack) => Container(
                    color: const Color(0xFFEFF6FF),
                    child: const Center(
                      child: Icon(
                        Icons.apps_rounded,
                        color: Color(0xFF2563EB),
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Title & Category
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proj['title'] as String,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    proj['category'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
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
}
