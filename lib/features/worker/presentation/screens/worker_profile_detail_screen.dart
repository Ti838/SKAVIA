import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/router/app_routes.dart';
import '../../../chat/data/datasources/chat_remote_datasource.dart';

/// Worker Profile Screen matching Screen 13 of SKAVIA reference design board.
/// Displays Rahul Ahmed's profile (or passed specialist), stats, skills, and direct Message/Hire CTAs.
class WorkerProfileDetailScreen extends StatefulWidget {
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
    this.name = 'Rahul Ahmed',
    this.title = 'Flutter Developer',
    this.rating = 4.8,
    this.reviewsCount = 32,
    this.experience = '2+ years',
    this.location = 'Dhaka, Bangladesh',
    this.hourlyRate = '\$15/hr',
    this.skills = const ['Flutter', 'Dart', 'Firebase', 'REST API', 'UI/UX'],
    this.avatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=250',
  });

  @override
  State<WorkerProfileDetailScreen> createState() =>
      _WorkerProfileDetailScreenState();
}

class _WorkerProfileDetailScreenState extends State<WorkerProfileDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Worker Profile',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                  image: DecorationImage(
                    image: NetworkImage(widget.avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Name with Verified checkmark
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),

              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.rating} (${widget.reviewsCount} reviews)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Action Buttons: Message & Hire
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final currentUserId =
                            FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';
                        final otherId =
                            'worker_${widget.name.replaceAll(' ', '_').toLowerCase()}';
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
                              'otherParticipantName': widget.name,
                              'otherParticipantAvatar': widget.avatarUrl,
                              'otherParticipantId': otherId,
                            },
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(
                          color: Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.bookingConfirmation,
                          arguments: {
                            'workerProfileId': 'wp_rahul',
                            'workerName': widget.name,
                            'tradeTitle': widget.title,
                            'hourlyRate': 150.0,
                            'jobTitle': 'Mobile App Development',
                            'location': widget.location,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
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
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Info Items: Experience, Location, Hourly Rate
              _buildInfoRow(
                icon: Icons.history_rounded,
                label: 'Experience',
                value: widget.experience,
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: widget.location,
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildInfoRow(
                icon: Icons.monetization_on_outlined,
                label: 'Hourly Rate',
                value: widget.hourlyRate,
              ),
              const SizedBox(height: 28),

              // Skills Section
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Skills',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
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
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
