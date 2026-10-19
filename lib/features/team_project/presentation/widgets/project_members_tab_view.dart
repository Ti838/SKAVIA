import 'package:flutter/material.dart';

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
    if (teamMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              'No team members assigned yet',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            if (onAddMember != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onAddMember,
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Member'),
              ),
            ],
          ],
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
