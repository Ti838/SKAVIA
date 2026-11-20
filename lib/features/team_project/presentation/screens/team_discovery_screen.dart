import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../widgets/team_discovery_card.dart';
import '../widgets/team_discovery_filter_chip.dart';

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

  bool _isLoading = true;
  List<Map<String, dynamic>> _teams = [];
  Set<String> _savedIds = {};

  @override
  void initState() {
    super.initState();
    final cachedSaved = LocalCacheService.instance.get(_savedTeamsCacheKey);
    _savedIds = cachedSaved is List
        ? cachedSaved.map((e) => e.toString()).toSet()
        : {};
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final client = tryGetSupabaseClient();
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await client
          .from(DatabaseTables.teams)
          .select('team_id, name, project_id')
          .limit(20);
      if (mounted) {
        setState(() {
          _teams = (res as List).map((t) {
            final id = t['team_id']?.toString() ?? '';
            return {
              'id': id,
              'projectId': t['project_id']?.toString() ?? '',
              'name': t['name']?.toString() ?? 'Project Crew',
              'membersCount': 0,
              'projectsCount': 0,
              'rating': 0.0,
              'reviews': 0,
              'avatar': '',
              'skills': <String>[],
              'location': 'Dhaka',
              'availability': 'Active',
              'isSaved': _savedIds.contains(id),
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
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
                    TeamDiscoveryFilterChip(
                      label: 'Skills',
                      value: _selectedSkill,
                      isActive: _selectedSkill != 'All Skills',
                      onTap: () {
                        setState(() {
                          const opts = [
                            'All Skills',
                            'Flutter',
                            'React',
                            'Design',
                            'Cloud',
                          ];
                          _selectedSkill =
                              opts[(opts.indexOf(_selectedSkill) + 1) %
                                  opts.length];
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    TeamDiscoveryFilterChip(
                      label: 'Location',
                      value: _selectedLocation,
                      isActive: _selectedLocation != 'All Locations',
                      onTap: () {
                        setState(() {
                          const opts = [
                            'All Locations',
                            'Dhanmondi',
                            'Gulshan',
                            'Uttara',
                          ];
                          _selectedLocation =
                              opts[(opts.indexOf(_selectedLocation) + 1) %
                                  opts.length];
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    TeamDiscoveryFilterChip(
                      label: 'Availability',
                      value: _selectedAvailability,
                      isActive: _selectedAvailability != 'Any',
                      onTap: () {
                        setState(() {
                          const opts = [
                            'Any',
                            'Immediate',
                            'Part-time',
                            'Full-time',
                          ];
                          _selectedAvailability =
                              opts[(opts.indexOf(_selectedAvailability) + 1) %
                                  opts.length];
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Teams List or Contextual Empty State
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: tokens.brandAccent,
                      ),
                    )
                  : visibleTeams.isEmpty
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
                              (_selectedSkill != 'All Skills' ||
                                      _selectedLocation != 'All Locations' ||
                                      _selectedAvailability != 'Any')
                                  ? 'No teams match these filters'
                                  : 'No teams registered yet',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              (_selectedSkill != 'All Skills' ||
                                      _selectedLocation != 'All Locations' ||
                                      _selectedAvailability != 'Any')
                                  ? 'Try adjusting skills, location, or availability.'
                                  : 'Multi-disciplinary and turnkey project teams will appear here once formed.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: tokens.mutedText,
                              ),
                            ),
                            if (_selectedSkill != 'All Skills' ||
                                _selectedLocation != 'All Locations' ||
                                _selectedAvailability != 'Any') ...[
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
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: visibleTeams.length,
                      itemBuilder: (context, index) {
                        final team = visibleTeams[index];
                        return TeamDiscoveryCard(
                          team: team,
                          onToggleSaved: () => _toggleSaved(team),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
