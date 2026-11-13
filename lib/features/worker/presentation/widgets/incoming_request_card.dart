import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';

class IncomingRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final price = (request['agreed_price'] as num?)?.toDouble() ?? 1000.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tokens.softBlueBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request['category']?.toString() ?? 'Service',
                  style: AppTypography.caption.copyWith(
                    color: tokens.brandAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '৳ ${price.toStringAsFixed(0)}',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  color: tokens.brandAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          Text(
            request['job_title']?.toString() ?? 'Job Title',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Client: ${request['client_name'] ?? "Verified Customer"}',
            style: AppTypography.bodySmall.copyWith(
              color: tokens.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: tokens.brandAccent,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  request['location']?.toString() ?? 'Dhaka',
                  style: AppTypography.caption.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: tokens.brandAccent,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  request['scheduled_at']?.toString() ?? 'Immediate',
                  style: AppTypography.caption.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          if (request['service_notes'] != null &&
              request['service_notes'].toString().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tokens.subtleCardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: tokens.subtleBorder),
              ),
              child: Text(
                'Note: ${request['service_notes']}',
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: tokens.secondaryText,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
          ],

          LayoutBuilder(
            builder: (context, constraints) {
              final stackButtons =
                  constraints.maxWidth < 290 || textScale > 1.3;

              final declineBtn = OutlinedButton(
                onPressed: onDecline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusRound,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Decline',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              );

              final acceptBtn = AppButton(text: 'Accept Job', onPressed: onAccept);

              if (stackButtons) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    acceptBtn,
                    const SizedBox(height: 8),
                    declineBtn,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: declineBtn),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(flex: 2, child: acceptBtn),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
