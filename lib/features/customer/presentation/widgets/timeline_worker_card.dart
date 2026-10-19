import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../chat/presentation/screens/chat_room_screen.dart';

/// Card showing assigned worker info, phone dialer action, and direct chat action.
class TimelineWorkerCard extends StatelessWidget {
  final String workerName;
  final String tradeTitle;
  final String requestId;
  final String? workerPhone;

  const TimelineWorkerCard({
    super.key,
    required this.workerName,
    required this.tradeTitle,
    required this.requestId,
    this.workerPhone,
  });

  Future<void> _callWorker(BuildContext context) async {
    final phone = workerPhone?.isNotEmpty == true
        ? workerPhone!
        : AppConstants.supportHelpline;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            workerPhone?.isNotEmpty == true
                ? 'Dialer unavailable. Dial $phone directly.'
                : 'Specialist phone not on file. Calling SKAVIA Support: $phone',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workerName,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  tradeTitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.phone_in_talk_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'Call Specialist',
            onPressed: () => _callWorker(context),
          ),
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'Chat with Specialist',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    conversationId: 'conv_$requestId',
                    otherParticipantName: workerName,
                    otherParticipantId:
                        'worker_${workerName.replaceAll(' ', '_').toLowerCase()}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
