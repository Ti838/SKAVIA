import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/user_avatar.dart';

/// Screen listing team members, their roles, certifications, and project workload.
class TeamRosterScreen extends StatelessWidget {
  final String projectId;
  final String projectTitle;

  const TeamRosterScreen({
    super.key,
    required this.projectId,
    this.projectTitle = 'Turnkey Project Team',
  });

  final List<Map<String, dynamic>> _members = const [
    {
      'name': 'Rahul Ahmed',
      'role': 'Lead Electrical Specialist',
      'trade': 'Electrical & Lighting',
      'activeTasks': 3,
      'isVerified': true,
      'rating': 4.9,
    },
    {
      'name': 'Kamal Hossain',
      'role': 'Master Plumber',
      'trade': 'Plumbing & Gas Line',
      'activeTasks': 2,
      'isVerified': true,
      'rating': 4.8,
    },
    {
      'name': 'Engr. Tariqul Islam',
      'role': 'HVAC Consultant',
      'trade': 'Chiller & Ventilation',
      'activeTasks': 1,
      'isVerified': true,
      'rating': 5.0,
    },
    {
      'name': 'Sultana Begum',
      'role': 'Site Safety Inspector',
      'trade': 'Compliance & Auditing',
      'activeTasks': 1,
      'isVerified': true,
      'rating': 4.9,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Team Roster',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 22),
            onPressed: () {
              UiFeedbackHelper.showInfo(
                context,
                'Invitation link copied for sharing with specialists',
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        itemCount: _members.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final member = _members[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                UserAvatar(
                  name: member['name'] as String,
                  isVerified: member['isVerified'] == true,
                  radius: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member['name'] as String,
                              style: TextStyle(
                                fontFamily: AppTypography.headingFont,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 11,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${member['rating']}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member['role'] as String,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRoyal,
                        ),
                      ),
                      Text(
                        '${member['trade']} • ${member['activeTasks']} active tasks',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primarySky,
                    size: 20,
                  ),
                  onPressed: () {
                    UiFeedbackHelper.showInfo(
                      context,
                      'Opening team messaging channel with ${member['name']}',
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
