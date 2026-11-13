import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
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
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppAppBar(
        title: 'Team Roster',
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_add_alt_1_rounded,
              size: 22,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              UiFeedbackHelper.showInfo(
                context,
                'Team specialist assignment for $projectTitle is coordinated by your Team Leader.',
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        itemCount: _members.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final member = _members[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: tokens.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            member['name'] as String,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: tokens.softPeachBg,
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
                      const SizedBox(height: 3),
                      Text(
                        member['role'] as String,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: tokens.brandAccent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${member['trade']} • ${member['activeTasks']} active tasks',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: tokens.brandAccent,
                    size: 20,
                  ),
                  onPressed: () {
                    User? currentUser;
                    try {
                      currentUser = FirebaseAuth.instance.currentUser;
                    } catch (_) {
                      currentUser = null;
                    }
                    if (currentUser == null) {
                      UiFeedbackHelper.showInfo(
                        context,
                        'Sign in to message ${member['name']}.',
                      );
                      return;
                    }
                    UiFeedbackHelper.showInfo(
                      context,
                      'Use the Project Messages tab to coordinate with ${member['name']}.',
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
