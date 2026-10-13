import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../chat/data/datasources/chat_remote_datasource.dart';

/// Reusable team member tile for Project Management board
class TeamMemberTile extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool showChatButton;

  const TeamMemberTile({
    super.key,
    required this.member,
    this.showChatButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = member['name'] as String? ?? 'Member';
    final role = member['role'] as String? ?? 'Developer';
    final isLeader = member['isLeader'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLeader) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Lead',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (showChatButton)
            IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: Color(0xFF2563EB),
              ),
              onPressed: () async {
                final currentUserId =
                    FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';
                final otherId =
                    'user_${name.replaceAll(' ', '_').toLowerCase()}';
                final conv = await ChatRemoteDataSource().getOrCreateConversation(
                  currentUserId: currentUserId,
                  otherUserId: otherId,
                );
                if (context.mounted) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chatRoom,
                    arguments: {
                      'conversationId': conv.conversationId,
                      'otherParticipantName': name,
                      'otherParticipantId': otherId,
                    },
                  );
                }
              },
            )
          else if (isLeader)
            const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
        ],
      ),
    );
  }
}
