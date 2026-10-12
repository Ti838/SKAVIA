import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sheetBackground,
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
                    color: AppColors.borderLight,
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
                      color: AppColors.primarySky.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primarySky,
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
                          style: const TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Estimated time: ${service.estimatedDuration}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMedium,
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
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textDark,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Inclusive of SKAVIA Escrow',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '৳ ${service.basePrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryRoyal,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Selected ${service.name}. Matching certified technicians...',
                      ),
                      backgroundColor: AppColors.statusActive,
                    ),
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
