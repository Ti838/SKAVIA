import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/ui_feedback_helper.dart';

/// Screen allowing administrators to review and approve submitted credentials and NIDs.
class VerificationQueueScreen extends StatefulWidget {
  const VerificationQueueScreen({super.key});

  @override
  State<VerificationQueueScreen> createState() =>
      _VerificationQueueScreenState();
}

class _VerificationQueueScreenState extends State<VerificationQueueScreen> {
  final List<Map<String, dynamic>> _queue = [
    {
      'id': 'v_01',
      'name': 'Rahul Ahmed',
      'trade': 'Licensed Master Electrician',
      'docType': 'Bangladesh Electrical Licensing Board (Class A)',
      'nid': '19922695847100234',
      'date': 'Today, 11:20 AM',
    },
    {
      'id': 'v_02',
      'name': 'Kamal Hossain',
      'trade': 'Master Gas & Plumbing Technician',
      'docType': 'Titas Gas Certified Fitter & City Trade License',
      'nid': '19882695847100512',
      'date': 'Yesterday',
    },
    {
      'id': 'v_03',
      'name': 'Engr. Tariqul Islam',
      'trade': 'MEP Project Consultant',
      'docType': 'IEB Member Certificate & B.Sc Engineering',
      'nid': '19852695847100987',
      'date': '2 days ago',
    },
  ];

  void _handleDecision(int index, bool isApproved) {
    final item = _queue[index];
    setState(() => _queue.removeAt(index));

    if (isApproved) {
      UiFeedbackHelper.showSuccess(
        context,
        'Approved and verified ${item['name']}! Verified badge granted.',
      );
    } else {
      UiFeedbackHelper.showInfo(
        context,
        'Application rejected for ${item['name']}. Specialist requested to re-upload.',
      );
    }
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
          'Verification Review Queue',
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
      body: _queue.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 56,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All Verifications Reviewed!',
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
              itemCount: _queue.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _queue[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHighest
                        : Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            item['date'] as String,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['trade'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRoyal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.surface
                              : AppColors.sheetSurfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Credential: ${item['docType']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'National NID: ${item['nid']}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _handleDecision(index, false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.errorRed,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Reject / Resubmit',
                                style: TextStyle(color: AppColors.errorRed),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleDecision(index, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Approve & Verify'),
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
