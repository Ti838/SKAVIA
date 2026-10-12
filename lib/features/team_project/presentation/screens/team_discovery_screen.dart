import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/router/app_routes.dart';

/// Screen 9: Team Discovery ("Find Teams") from the SKAVIA reference design board.
class TeamDiscoveryScreen extends StatefulWidget {
  const TeamDiscoveryScreen({super.key});

  @override
  State<TeamDiscoveryScreen> createState() => _TeamDiscoveryScreenState();
}

class _TeamDiscoveryScreenState extends State<TeamDiscoveryScreen> {
  String _selectedSkill = 'All Skills';
  String _selectedLocation = 'All Locations';
  String _selectedAvailability = 'Any';

  final List<Map<String, dynamic>> _teams = [
    {
      'id': 'team_01',
      'name': 'TechCraft Team',
      'membersCount': 5,
      'projectsCount': 3,
      'rating': 4.8,
      'reviews': 12,
      'avatar':
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=150',
      'skills': ['Flutter', 'Firebase', 'UI/UX'],
      'isSaved': false,
    },
    {
      'id': 'team_02',
      'name': 'Dream Builders',
      'membersCount': 4,
      'projectsCount': 2,
      'rating': 4.6,
      'reviews': 9,
      'avatar':
          'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=150',
      'skills': ['React', 'Node.js', 'Design'],
      'isSaved': true,
    },
    {
      'id': 'team_03',
      'name': 'Pixel Squad',
      'membersCount': 3,
      'projectsCount': 1,
      'rating': 4.7,
      'reviews': 7,
      'avatar':
          'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=150',
      'skills': ['Flutter', 'Firebase', 'Design'],
      'isSaved': false,
    },
    {
      'id': 'team_04',
      'name': 'Code Crafters',
      'membersCount': 6,
      'projectsCount': 5,
      'rating': 4.9,
      'reviews': 18,
      'avatar':
          'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=150',
      'skills': ['Mobile', 'Cloud', 'DevOps'],
      'isSaved': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          'Find Teams',
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
            // Filter Pills Row (Skills v, Location v, Availability v)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Skills', _selectedSkill),
                    const SizedBox(width: 10),
                    _buildFilterChip('Location', _selectedLocation),
                    const SizedBox(width: 10),
                    _buildFilterChip('Availability', _selectedAvailability),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Teams List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: _teams.length,
                itemBuilder: (context, index) {
                  final team = _teams[index];
                  return _buildTeamCard(team);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == 'Skills') {
            final opts = ['All Skills', 'Flutter', 'React', 'Design'];
            _selectedSkill =
                opts[(opts.indexOf(_selectedSkill) + 1) % opts.length];
          } else if (label == 'Location') {
            final opts = ['All Locations', 'Dhanmondi', 'Gulshan', 'Uttara'];
            _selectedLocation =
                opts[(opts.indexOf(_selectedLocation) + 1) % opts.length];
          } else if (label == 'Availability') {
            final opts = ['Any', 'Immediate', 'Part-time', 'Full-time'];
            _selectedAvailability =
                opts[(opts.indexOf(_selectedAvailability) + 1) % opts.length];
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team) {
    final skills = (team['skills'] as List<dynamic>?)?.cast<String>() ?? [];
    final isSaved = team['isSaved'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, Team Name, Stats, Bookmark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEFF6FF),
                backgroundImage: NetworkImage(team['avatar'] as String),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${team['membersCount']} members • ${team['projectsCount']} projects',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${team['rating']} (${team['reviews']})',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF94A3B8),
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    team['isSaved'] = !isSaved;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Skills Chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: skills.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Request to Join Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.projectDashboard,
                  arguments: {
                    'projectId': team['id'],
                    'projectTitle': '${team['name']} Workspace',
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Request to Join',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
