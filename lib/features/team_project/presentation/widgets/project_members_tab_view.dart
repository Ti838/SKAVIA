import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import 'team_member_tile.dart';

/// Tab view displaying project team members with chat buttons and add member actions.
class ProjectMembersTabView extends StatelessWidget {
  final List<Map<String, dynamic>> teamMembers;
  final VoidCallback? onAddMember;

  const ProjectMembersTabView({
    super.key,
    required this.teamMembers,
    this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    if (teamMembers.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: tokens.mutedText,
              ),
              const SizedBox(height: 12),
              Text(
                'No team members assigned yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (onAddMember != null) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onAddMember,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.brandAccent,
                    foregroundColor: tokens.onBrandAccent,
                  ),
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Add Member'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey('members_tab'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: teamMembers.length,
      itemBuilder: (context, index) {
        final m = teamMembers[index];
        return TeamMemberTile(member: m, showChatButton: true);
      },
    );
  }
}
