import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/user_avatar.dart';

/// Card displaying team avatar, metadata, skills, rating, bookmark toggle, and workspace routing.
class TeamDiscoveryCard extends StatelessWidget {
  final Map<String, dynamic> team;
  final VoidCallback onToggleSaved;

  const TeamDiscoveryCard({
    super.key,
    required this.team,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
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
                onPressed: onToggleSaved,
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
                final projectId = (team['projectId'] as String?)?.trim() ?? '';
                if (projectId.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.projectDashboard,
                    arguments: {
                      'projectId': projectId,
                      'projectTitle': '${team['name']} Workspace',
                    },
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.teamRoster,
                    arguments: {
                      'teamId': team['id'],
                      'teamName': team['name'],
                    },
                  );
                }
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
