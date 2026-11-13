import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/user_avatar.dart';

/// Screen 9: Team Discovery ("Find Teams") with real filtering and bookmark persistence.
class TeamDiscoveryScreen extends StatefulWidget {
  const TeamDiscoveryScreen({super.key});

  @override
  State<TeamDiscoveryScreen> createState() => _TeamDiscoveryScreenState();
}

class _TeamDiscoveryScreenState extends State<TeamDiscoveryScreen> {
  static const String _savedTeamsCacheKey = 'team_discovery_saved_ids';

  String _selectedSkill = 'All Skills';
  String _selectedLocation = 'All Locations';
  String _selectedAvailability = 'Any';

  late final List<Map<String, dynamic>> _teams;

  @override
  void initState() {
    super.initState();
    final cachedSaved = LocalCacheService.instance.get(
      _savedTeamsCacheKey,
    );
    final savedIds = cachedSaved is List
        ? cachedSaved.map((e) => e.toString()).toSet()
        : null;

    _teams = [
      {
        'id': 'team_01',
        'name': 'TechCraft Team',
        'membersCount': 5,
        'projectsCount': 3,
        'rating': 4.8,
        'reviews': 12,
        'avatar': '',
        'skills': ['Flutter', 'Firebase', 'UI/UX'],
        'location': 'Dhanmondi',
        'availability': 'Immediate',
        'isSaved': savedIds?.contains('team_01') ?? false,
      },
      {
        'id': 'team_02',
        'name': 'Dream Builders',
        'membersCount': 4,
        'projectsCount': 2,
        'rating': 4.6,
        'reviews': 9,
        'avatar': '',
        'skills': ['React', 'Node.js', 'Design'],
        'location': 'Gulshan',
        'availability': 'Full-time',
        'isSaved': savedIds?.contains('team_02') ?? true,
      },
      {
        'id': 'team_03',
        'name': 'Pixel Squad',
        'membersCount': 3,
        'projectsCount': 1,
        'rating': 4.7,
        'reviews': 7,
        'avatar': '',
        'skills': ['Flutter', 'Firebase', 'Design'],
        'location': 'Uttara',
        'availability': 'Part-time',
        'isSaved': savedIds?.contains('team_03') ?? false,
      },
      {
        'id': 'team_04',
        'name': 'Code Crafters',
        'membersCount': 6,
        'projectsCount': 5,
        'rating': 4.9,
        'reviews': 18,
        'avatar': '',
        'skills': ['Mobile', 'Cloud', 'DevOps'],
        'location': 'Gulshan',
        'availability': 'Immediate',
        'isSaved': savedIds?.contains('team_04') ?? false,
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredTeams {
    return _teams.where((team) {
      final skills = (team['skills'] as List<dynamic>? ?? [])
          .map((e) => e.toString().toLowerCase())
          .toList();
      final matchesSkill =
          _selectedSkill == 'All Skills' ||
          skills.contains(_selectedSkill.toLowerCase());
      final matchesLocation =
          _selectedLocation == 'All Locations' ||
          team['location'] == _selectedLocation;
      final matchesAvailability =
          _selectedAvailability == 'Any' ||
          team['availability'] == _selectedAvailability;
      return matchesSkill && matchesLocation && matchesAvailability;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedSkill = 'All Skills';
      _selectedLocation = 'All Locations';
      _selectedAvailability = 'Any';
    });
  }

  void _toggleSaved(Map<String, dynamic> team) {
    final nextSaved = !(team['isSaved'] == true);
    setState(() {
      team['isSaved'] = nextSaved;
    });
    final savedIds = _teams
        .where((t) => t['isSaved'] == true)
        .map((t) => t['id'].toString())
        .toList();
    LocalCacheService.instance.put(_savedTeamsCacheKey, savedIds);
    UiFeedbackHelper.showInfo(
      context,
      nextSaved
          ? '${team['name']} saved to your shortlist'
          : '${team['name']} removed from shortlist',
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final visibleTeams = _filteredTeams;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: const AppAppBar(title: 'Find Teams'),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      'Skills',
                      _selectedSkill,
                      isActive: _selectedSkill != 'All Skills',
                    ),
                    const SizedBox(width: 10),
                    _buildFilterChip(
                      'Location',
                      _selectedLocation,
                      isActive: _selectedLocation != 'All Locations',
                    ),
                    const SizedBox(width: 10),
                    _buildFilterChip(
                      'Availability',
                      _selectedAvailability,
                      isActive: _selectedAvailability != 'Any',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Teams List or Contextual Empty State
            Expanded(
              child: visibleTeams.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.groups_2_outlined,
                              size: 48,
                              color: tokens.mutedText,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No teams match these filters',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try adjusting skills, location, or availability.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: tokens.mutedText,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextButton.icon(
                              onPressed: _resetFilters,
                              icon: Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: tokens.brandAccent,
                              ),
                              label: Text(
                                'Reset Filters',
                                style: TextStyle(
                                  color: tokens.brandAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: visibleTeams.length,
                      itemBuilder: (context, index) {
                        return _buildTeamCard(visibleTeams[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value, {
    required bool isActive,
  }) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == 'Skills') {
            const opts = ['All Skills', 'Flutter', 'React', 'Design', 'Cloud'];
            _selectedSkill =
                opts[(opts.indexOf(_selectedSkill) + 1) % opts.length];
          } else if (label == 'Location') {
            const opts = ['All Locations', 'Dhanmondi', 'Gulshan', 'Uttara'];
            _selectedLocation =
                opts[(opts.indexOf(_selectedLocation) + 1) % opts.length];
          } else if (label == 'Availability') {
            const opts = ['Any', 'Immediate', 'Part-time', 'Full-time'];
            _selectedAvailability =
                opts[(opts.indexOf(_selectedAvailability) + 1) % opts.length];
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? tokens.softBlueBg : tokens.subtleCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? tokens.brandAccent : tokens.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isActive ? '$label: $value' : label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isActive ? tokens.brandAccent : colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive ? tokens.brandAccent : tokens.mutedText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skills = (team['skills'] as List<dynamic>?)?.cast<String>() ?? [];
    final isSaved = team['isSaved'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                imageUrl: team['avatar'] as String?,
                name: team['name'] as String? ?? 'SKAVIA Team',
                radius: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team['name'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${team['membersCount']} members • ${team['projectsCount']} projects • ${team['location']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: tokens.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 16,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '${team['rating']} (${team['reviews']})',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${team['availability']}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tokens.brandAccent,
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
                  color: isSaved ? tokens.brandAccent : tokens.mutedText,
                  size: 22,
                ),
                onPressed: () => _toggleSaved(team),
              ),
            ],
          ),
          const SizedBox(height: 12),

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
                  color: tokens.softBlueBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: tokens.brandAccent.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tokens.brandAccent,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

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
                backgroundColor: tokens.brandAccent,
                foregroundColor: tokens.onBrandAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Open Team Workspace',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
