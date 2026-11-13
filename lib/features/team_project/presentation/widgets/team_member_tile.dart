import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/user_avatar.dart';
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
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final name = member['name'] as String? ?? 'Member';
    final role = member['role'] as String? ?? 'Developer';
    final isLeader = member['isLeader'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          UserAvatar(name: name, radius: 20, isVerified: isLeader),
          const SizedBox(width: 12),
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
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isLeader)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.softPeachBg,
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
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 12,
                    color: tokens.mutedText,
                  ),
                ),
              ],
            ),
          ),
          if (showChatButton)
            IconButton(
              icon: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: tokens.brandAccent,
              ),
              onPressed: () async {
                String? currentUid;
                try {
                  currentUid = FirebaseAuth.instance.currentUser?.uid;
                } catch (_) {
                  currentUid = null;
                }
                if (currentUid == null) {
                  UiFeedbackHelper.showError(
                    context,
                    'Please sign in to chat with team members.',
                  );
                  return;
                }
                final otherId =
                    'user_${name.replaceAll(' ', '_').toLowerCase()}';
                final conv = await ChatRemoteDataSource()
                    .getOrCreateConversation(
                      currentUserId: currentUid,
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
