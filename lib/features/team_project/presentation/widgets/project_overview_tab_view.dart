import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import 'team_member_tile.dart';
import 'team_progress_bar.dart';

class ProjectOverviewTabView extends StatelessWidget {
  final double budget;
  final double progressPercent;
  final List<Map<String, dynamic>> teamMembers;
  final VoidCallback onAddMember;

  const ProjectOverviewTabView({
    super.key,
    required this.budget,
    this.progressPercent = 0.60,
    required this.teamMembers,
    required this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return SingleChildScrollView(
      key: const ValueKey('overview_tab'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeamProgressBar(progressPercent: progressPercent, budget: budget),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Team Members (${teamMembers.length})',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onAddMember,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    '+ Add',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: tokens.brandAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Column(
            children: teamMembers.map((member) {
              return TeamMemberTile(member: member, showChatButton: false);
            }).toList(),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddMember,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Add Member',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.brandAccent,
                foregroundColor: tokens.onBrandAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
