import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/service_model.dart';

/// Modal bottom sheet displaying detailed specs and 1-tap book for a selected catalog service
class CatalogServiceDetailSheet extends StatelessWidget {
  final ServiceModel service;

  const CatalogServiceDetailSheet({super.key, required this.service});

  static void show(BuildContext context, ServiceModel service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => CatalogServiceDetailSheet(service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Container(
      decoration: BoxDecoration(
        color: tokens.sheetBg,
        borderRadius: AppDimensions.roundedSheetTop,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: colorScheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Estimated time: ${service.estimatedDuration}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                service.description,
                style: TextStyle(
                  fontSize: 13.5,
                  color: colorScheme.onSurface,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.subtleCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: tokens.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Starting Price',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Inclusive of SKAVIA Escrow',
                            style: TextStyle(
                              fontSize: 10,
                              color: tokens.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '৳ ${service.basePrice.toStringAsFixed(0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFont,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: tokens.brandAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Proceed to Schedule & Match',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    AppRoutes.bookingConfirmation,
                    arguments: {
                      'workerProfileId': 'wp_verified_pool',
                      'workerName': 'Certified SKAVIA Specialist',
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
      ),
    );
  }
}
