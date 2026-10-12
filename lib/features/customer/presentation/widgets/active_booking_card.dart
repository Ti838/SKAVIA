import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';

/// Uber/Grab-Style Active Booking Card with Real 4-Digit Security OTP
class ActiveBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String locationZone;
  final VoidCallback onViewOtp;
  final VoidCallback onOpenChat;

  const ActiveBookingCard({
    super.key,
    required this.booking,
    required this.locationZone,
    required this.onViewOtp,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking['status']?.toString() ?? 'In Progress';
    final notes = booking['service_notes']?.toString() ?? 'Service in Progress';
    final price = (booking['agreed_price'] as num?)?.toDouble() ?? 500.0;
    final worker = booking['worker_profiles'];
    final techName =
        worker?['users']?['full_name']?.toString() ??
        'Assigned Master Technician';
    final techPhone =
        worker?['users']?['phone_number']?.toString() ?? '01700000000';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRoyal.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentAqua.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentAqua,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.accentAqua,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '৳ ${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notes,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Technician: $techName • $locationZone',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPeach,
                    foregroundColor: AppColors.primaryRoyal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.key_rounded, size: 16),
                  label: const Text(
                    'View Job OTP',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  onPressed: onViewOtp,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () async {
                  final uri = Uri(scheme: 'tel', path: techPhone);
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
              ),
              const SizedBox(width: 6),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: onOpenChat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
