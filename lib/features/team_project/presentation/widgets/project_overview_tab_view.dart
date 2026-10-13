import 'package:flutter/material.dart';

import 'team_member_tile.dart';
import 'team_progress_bar.dart';

class ProjectOverviewTabView extends StatelessWidget {
  final double budget;
  final List<Map<String, dynamic>> teamMembers;
  final VoidCallback onAddMember;

  const ProjectOverviewTabView({
    super.key,
    required this.budget,
    required this.teamMembers,
    required this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('overview_tab'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Progress Card
          TeamProgressBar(progressPercent: 0.60, budget: budget),
          const SizedBox(height: 24),

          // Team Members Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team Members (${teamMembers.length})',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              InkWell(
                onTap: onAddMember,
                child: const Text(
                  '+ Add',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Team Members List
          Column(
            children: teamMembers.map((member) {
              return TeamMemberTile(member: member, showChatButton: false);
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Add Member Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddMember,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'Add Member',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
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
