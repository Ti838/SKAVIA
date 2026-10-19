import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/ui_feedback_helper.dart';

/// Screen allowing administrators to mediate disputes and execute partial/full escrow settlements.
class DisputeResolutionScreen extends StatefulWidget {
  const DisputeResolutionScreen({super.key});

  @override
  State<DisputeResolutionScreen> createState() =>
      _DisputeResolutionScreenState();
}

class _DisputeResolutionScreenState extends State<DisputeResolutionScreen> {
  final List<Map<String, dynamic>> _disputes = [
    {
      'id': 'disp_101',
      'title': 'Unfinished AC Compressor Leak Repair',
      'client': 'Tanvir Chowdhury',
      'worker': 'Babul Mia (HVAC)',
      'escrowAmount': 3500.0,
      'claim': 'Worker departed before pressure gauge testing. Gas leaked within 24 hours.',
      'status': 'Open Mediation',
    },
    {
      'id': 'disp_102',
      'title': 'Scope Discrepancy on Distribution Board',
      'client': 'Delta Textiles Ltd',
      'worker': 'Faridul Haque (Electrician)',
      'escrowAmount': 18000.0,
      'claim': 'Contract required copper busbars; contractor utilized aluminum alloy substitutes.',
      'status': 'Open Mediation',
    },
  ];

  void _resolve(int index, String resolution) {
    setState(() => _disputes.removeAt(index));
    UiFeedbackHelper.showSuccess(
      context,
      'Dispute resolved: $resolution. Escrow updated.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Escrow Dispute Mediation',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _disputes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 56,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Pending Escrow Disputes',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              itemCount: _disputes.length,
              separatorBuilder: (_, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final d = _disputes[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHighest
                        : Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                    border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              d['title'] as String,
                              style: TextStyle(
                                fontFamily: AppTypography.headingFont,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '৳ ${(d['escrowAmount'] as num).toStringAsFixed(0)} Escrow',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Client: ${d['client']}  •  Specialist: ${d['worker']}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d['claim'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _resolve(index, 'Full Refund to Client'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.errorRed,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Refund Client',
                                style: TextStyle(
                                  color: AppColors.errorRed,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _resolve(
                                index,
                                'Release Escrow to Specialist',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRoyal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Release Escrow',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
