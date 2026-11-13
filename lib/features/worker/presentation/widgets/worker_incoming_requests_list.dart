import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';

/// Incoming job requests list for worker dashboard with empty radar state.
class WorkerIncomingRequestsList extends StatelessWidget {
  final List<Map<String, dynamic>> liveJobRequests;

  const WorkerIncomingRequestsList({super.key, required this.liveJobRequests});

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              AppLanguageService.tr('incoming_requests'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(context, AppRoutes.liveJobFeed),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        AppLanguageService.tr('open_jobs_feed'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: tokens.brandAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: tokens.brandAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (liveJobRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.subtleCardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.radar_rounded,
                  color: tokens.brandAccent,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguageService.tr('no_pending_requests'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLanguageService.tr('radar_alert_desc'),
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...liveJobRequests.map((req) {
            final price = (req['agreed_price'] as num?)?.toDouble() ?? 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokens.subtleCardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
                border: Border.all(color: tokens.border),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 290 || textScale > 1.3;
                  final infoRow = Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tokens.cardBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bolt,
                          color: AppColors.accentCoral,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Incoming Service Request',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Agreed Fare: ৳ ${price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: tokens.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  final reviewBtn = ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.brandAccent,
                      foregroundColor: tokens.onBrandAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.incomingRequests,
                    ),
                    child: const Text(
                      'Review',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        infoRow,
                        const SizedBox(height: 10),
                        reviewBtn,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: infoRow),
                      const SizedBox(width: 8),
                      reviewBtn,
                    ],
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}
