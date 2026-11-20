import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/service_model.dart';

/// Modal bottom sheet displaying service details and scheduling/matching entry.
class CatalogServiceDetailSheet extends StatelessWidget {
  final ServiceModel service;

  const CatalogServiceDetailSheet({super.key, required this.service});

  static void show(BuildContext context, ServiceModel service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => CatalogServiceDetailSheet(service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final isBn = AppLanguageService.isBengali;
    final hasDuration = service.estimatedDuration.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    Icons.home_repair_service_outlined,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (hasDuration) ...[
                        const SizedBox(height: 2),
                        Text(
                          isBn
                              ? 'আনুমানিক সময়: ${service.estimatedDuration}'
                              : 'Estimated time: ${service.estimatedDuration}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (service.description.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                service.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.subtleCardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'প্রারম্ভিক মূল্য' : 'Base Service Rate',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: tokens.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isBn
                              ? 'SKAVIA ওটিপি সুরক্ষিত বুকিং'
                              : 'OTP-verified booking protection',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service.basePrice > 0
                        ? '৳ ${service.basePrice.toStringAsFixed(0)}'
                        : (isBn ? 'আলোচনা সাপেক্ষে' : 'Custom Quote'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFeatures: AppTypography.tabularFigures,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: isBn
                  ? 'বুকিং ও শিডিউল নিশ্চিত করুন'
                  : 'Continue to Booking',
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(
                  AppRoutes.bookingConfirmation,
                  arguments: {
                    'workerProfileId': '',
                    'workerName': isBn
                        ? 'যাচাইকৃত কর্মী নির্ধারিত হবে'
                        : 'Assigned After Matching',
                    'tradeTitle': service.name,
                    'hourlyRate': service.basePrice,
                    'jobTitle': service.name,
                    'location': 'Dhaka, Bangladesh',
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
