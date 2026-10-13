import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../data/models/requirement_model.dart';

/// Card displaying an active job requirement in the live marketplace feed
class JobRequirementFeedCard extends StatelessWidget {
  final JobRequirementItem job;
  final VoidCallback? onApply;
  final VoidCallback? onMessage;

  const JobRequirementFeedCard({
    super.key,
    required this.job,
    this.onApply,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final isEmergency = job.urgency.toLowerCase().contains('emergency');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEmergency
              ? AppColors.accentCoral.withValues(alpha: 0.3)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Top Meta (Category, Urgency & Time)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySky.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.category,
                  style: const TextStyle(
                    color: AppColors.primaryRoyal,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Row(
                children: [
                  if (isEmergency)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBn ? 'জরুরি' : 'Urgent',
                        style: const TextStyle(
                          color: AppColors.accentCoral,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  Text(
                    job.timeAgo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Job Title
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),

          // Job Description
          Text(
            job.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Location & Client Row
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: AppColors.primarySky,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Client: ${job.clientName}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Budget Tag & Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'বাজেট সীমা' : 'Client Budget',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '৳ ${job.budgetMin.toStringAsFixed(0)} – ৳ ${job.budgetMax.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryRoyal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Message / Inquiry Button
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.primarySky,
                      size: 20,
                    ),
                    tooltip: 'Message Client',
                    onPressed:
                        onMessage ??
                        () {
                          Navigator.pushNamed(context, AppRoutes.chatList);
                        },
                  ),
                  const SizedBox(width: 6),

                  // Direct Apply / Bid Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRoyal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                    ),
                    onPressed: onApply,
                    child: Text(
                      isBn ? 'আবেদন (Bid)' : 'Apply / Bid',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
