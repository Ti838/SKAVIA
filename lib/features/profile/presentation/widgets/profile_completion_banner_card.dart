import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/services/profile_completion_engine.dart';

/// Interactive Profile Completion Intelligence Banner Card.
/// Displays progress bar, missing steps, and one-tap navigation to incomplete fields.
class ProfileCompletionBannerCard extends StatelessWidget {
  final ProfileCompletionResult result;
  final VoidCallback? onActionTap;

  const ProfileCompletionBannerCard({
    super.key,
    required this.result,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (result.isComplete && result.percentage == 100) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final nextAction = result.nextRecommendedAction;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 340 || textScale > 1.35;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primarySky.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: tokens.brandAccent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified_user_rounded,
                            color: tokens.brandAccent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Profile Strength',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: result.percentage >= 80
                          ? AppColors.success.withValues(alpha: 0.14)
                          : AppColors.warning.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${result.percentage}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: result.percentage >= 80
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: result.percentage / 100,
                  minHeight: 6,
                  backgroundColor: colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    result.percentage >= 80
                        ? AppColors.success
                        : AppColors.primarySky,
                  ),
                ),
              ),
              if (nextAction != null) ...[
                const SizedBox(height: 12),
                if (isCompact) ...[
                  Text(
                    'Next step: Add ${nextAction.label}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nextAction.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (onActionTap != null) {
                          onActionTap!();
                        } else {
                          Navigator.pushNamed(context, nextAction.actionRoute);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.brandAccent,
                        foregroundColor: tokens.onBrandAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next step: Add ${nextAction.label}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nextAction.reason,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (onActionTap != null) {
                            onActionTap!();
                          } else {
                            Navigator.pushNamed(context, nextAction.actionRoute);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.brandAccent,
                          foregroundColor: tokens.onBrandAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Complete',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
