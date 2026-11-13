import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
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

  void _openChat(BuildContext context) {
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
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackActions = constraints.maxWidth < 290 || textScale > 1.35;

          final infoRow = Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: tokens.softBlueBg,
                child: Icon(
                  Icons.person,
                  color: tokens.brandAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workerName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      tradeTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!stackActions) ...[
                IconButton(
                  icon: Icon(
                    Icons.phone_in_talk_rounded,
                    color: tokens.brandAccent,
                  ),
                  tooltip: 'Call Specialist',
                  onPressed: () => _callWorker(context),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: tokens.brandAccent,
                  ),
                  tooltip: 'Chat with Specialist',
                  onPressed: () => _openChat(context),
                ),
              ],
            ],
          );

          if (!stackActions) return infoRow;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoRow,
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _callWorker(context),
                    icon: Icon(
                      Icons.phone_in_talk_rounded,
                      size: 16,
                      color: tokens.brandAccent,
                    ),
                    label: Text(
                      'Call',
                      style: TextStyle(color: tokens.brandAccent),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: tokens.brandAccent),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openChat(context),
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: tokens.brandAccent,
                    ),
                    label: Text(
                      'Chat',
                      style: TextStyle(color: tokens.brandAccent),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: tokens.brandAccent),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
