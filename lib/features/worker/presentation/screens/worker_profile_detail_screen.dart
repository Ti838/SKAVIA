import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../chat/data/datasources/chat_remote_datasource.dart';

/// Worker Profile Detail Screen displaying specialist credentials, stats, skills, and Message/Hire CTAs.
class WorkerProfileDetailScreen extends StatefulWidget {
  final String? workerProfileId;
  final String name;
  final String title;
  final double rating;
  final int reviewsCount;
  final String experience;
  final String location;
  final String hourlyRate;
  final List<String> skills;
  final String avatarUrl;

  const WorkerProfileDetailScreen({
    super.key,
    this.workerProfileId,
    this.name = 'Rahul Ahmed',
    this.title = 'Flutter Developer',
    this.rating = 4.8,
    this.reviewsCount = 32,
    this.experience = '2+ years',
    this.location = 'Dhaka, Bangladesh',
    this.hourlyRate = '৳ 1,500/hr',
    this.skills = const ['Flutter', 'Dart', 'Firebase', 'REST API', 'UI/UX'],
    this.avatarUrl = '',
  });

  @override
  State<WorkerProfileDetailScreen> createState() =>
      _WorkerProfileDetailScreenState();
}

class _WorkerProfileDetailScreenState extends State<WorkerProfileDetailScreen> {
  double _parseHourlyRate() {
    final numeric = widget.hourlyRate.replaceAll(RegExp(r'[^0-9.]'), '');
    final parsed = double.tryParse(numeric);
    return (parsed != null && parsed > 0) ? parsed : 1500.0;
  }

  String _safeCurrentUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: const AppAppBar(title: 'Worker Profile', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.border, width: 2),
                ),
                child: UserAvatar(
                  imageUrl: widget.avatarUrl,
                  name: widget.name,
                  radius: 42,
                  isVerified: true,
                ),
              ),
              const SizedBox(height: 14),

              // Name with Verified checkmark
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.verified_rounded,
                    color: tokens.brandAccent,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: tokens.mutedText,
                ),
              ),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${widget.rating} (${widget.reviewsCount} reviews)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Action Buttons: Message & Hire
              LayoutBuilder(
                builder: (context, constraints) {
                  final stackVertically =
                      constraints.maxWidth < 290 || textScale > 1.3;

                  final messageButton = OutlinedButton(
                    onPressed: () async {
                      final currentUid = _safeCurrentUid();
                      if (currentUid.isEmpty) {
                        UiFeedbackHelper.showError(
                          context,
                          'Please sign in to message this specialist.',
                        );
                        return;
                      }
                      final otherId =
                          widget.workerProfileId ??
                          'worker_${widget.name.replaceAll(' ', '_').toLowerCase()}';
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
                            'otherParticipantName': widget.name,
                            'otherParticipantAvatar': widget.avatarUrl,
                            'otherParticipantId': otherId,
                          },
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: tokens.border, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );

                  final hireButton = ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.bookingConfirmation,
                        arguments: {
                          'workerProfileId':
                              widget.workerProfileId ??
                              'wp_${widget.name.replaceAll(' ', '_').toLowerCase()}',
                          'workerName': widget.name,
                          'tradeTitle': widget.title,
                          'hourlyRate': _parseHourlyRate(),
                          'jobTitle': '${widget.title} Service',
                          'location': widget.location,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.brandAccent,
                      foregroundColor: tokens.onBrandAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Hire',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );

                  if (stackVertically) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        messageButton,
                        const SizedBox(height: 10),
                        hireButton,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: messageButton),
                      const SizedBox(width: 12),
                      Expanded(child: hireButton),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              _buildInfoRow(
                context,
                icon: Icons.history_rounded,
                label: 'Experience',
                value: widget.experience,
              ),
              Divider(height: 24, color: tokens.subtleBorder),
              _buildInfoRow(
                context,
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: widget.location,
              ),
              Divider(height: 24, color: tokens.subtleBorder),
              _buildInfoRow(
                context,
                icon: Icons.monetization_on_outlined,
                label: 'Hourly Rate',
                value: widget.hourlyRate,
              ),
              const SizedBox(height: 28),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Skills',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.softBlueBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: tokens.brandAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tokens.brandAccent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: tokens.subtleCardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: tokens.border),
          ),
          child: Icon(icon, color: tokens.brandAccent, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: tokens.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
