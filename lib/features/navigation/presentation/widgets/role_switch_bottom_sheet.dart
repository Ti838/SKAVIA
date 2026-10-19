import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/app_language_service.dart';
import '../screens/main_scaffold_screen.dart';

/// Interactive modal sheet allowing users to switch between the 3 distinct SKAVIA account modes.
class RoleSwitchBottomSheet extends StatelessWidget {
  final AppRoleMode currentMode;
  final ValueChanged<AppRoleMode> onRoleSelected;

  const RoleSwitchBottomSheet({
    super.key,
    required this.currentMode,
    required this.onRoleSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required AppRoleMode currentMode,
    required ValueChanged<AppRoleMode> onRoleSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RoleSwitchBottomSheet(
        currentMode: currentMode,
        onRoleSelected: (mode) {
          Navigator.of(ctx).pop();
          onRoleSelected(mode);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isBn = AppLanguageService.isBengali;

    final roles = [
      {
        'mode': AppRoleMode.customer,
        'titleEn': 'Individual Customer Mode',
        'titleBn': 'ব্যক্তিগত গ্রাহক মোড',
        'subtitleEn':
            'Book verified home electricians, AC, plumbing & civil repairs with 4-digit OTP protection.',
        'subtitleBn':
            'বাসা-বাড়ির ইলেকট্রিশিয়ান, এসি, প্লাম্বার বুকিং এবং ওটিপি ভেরিফিকেশনে নিরাপদ সেবা।',
        'icon': Icons.person_search_rounded,
        'color': AppColors.primaryRoyal,
        'badgeEn': 'Home Services',
        'badgeBn': 'সার্ভিস বুকিং',
      },
      {
        'mode': AppRoleMode.enterprise,
        'titleEn': 'Corporate & Business Client',
        'titleBn': 'কর্পোরেট / প্রাতিষ্ঠানিক মোড',
        'subtitleEn':
            'Turnkey commercial fit-outs, assemble multidisciplinary units, milestone escrow & VAT invoices.',
        'subtitleBn':
            'বাণিজ্যিক প্রজেক্ট, টিম হায়ার, মাইলস্টোন এসক্রো ও ভ্যাট চালান ব্যবস্থাপনা।',
        'icon': Icons.business_center_rounded,
        'color': AppColors.successGreen,
        'badgeEn': 'Turnkey Projects',
        'badgeBn': 'টার্নকি প্রজেক্ট',
      },
      {
        'mode': AppRoleMode.worker,
        'titleEn': 'Specialist & Worker Mode',
        'titleBn': 'দক্ষ কারিগর / টেকনিশিয়ান মোড',
        'subtitleEn':
            'Accept local job requests, verify completion with client OTP & withdraw earnings to bKash.',
        'subtitleBn':
            'কাজের লাইভ রিকোয়েস্ট গ্রহণ, কাজ শেষে ওটিপিতে পেমেন্ট আনলক এবং ওয়ালেট উইথড্র।',
        'icon': Icons.handyman_rounded,
        'color': AppColors.accent,
        'badgeEn': 'Earn & Jobs',
        'badgeBn': 'কাজ ও আয়',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'অ্যাকাউন্ট মোড পরিবর্তন' : 'Switch Account Mode',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Text(
            isBn
                ? 'আপনার প্রয়োজন অনুযায়ী মোড বেছে নিন — সব ফিচার এই একটি অ্যাপ থেকেই ব্যবহার করতে পারবেন।'
                : 'Seamlessly switch your active workspace without logging into separate apps.',
            style: TextStyle(
              fontSize: 12.5,
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          ...roles.map((r) {
            final mode = r['mode'] as AppRoleMode;
            final isCurrent = currentMode == mode;
            final color = r['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onRoleSelected(mode),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? color.withValues(alpha: isDark ? 0.2 : 0.08)
                        : (isDark
                              ? colorScheme.surfaceContainerHighest
                              : Colors.white),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    border: Border.all(
                      color: isCurrent ? color : colorScheme.outlineVariant,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          r['icon'] as IconData,
                          color: color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isBn
                                        ? (r['titleBn'] as String)
                                        : (r['titleEn'] as String),
                                    style: TextStyle(
                                      fontFamily: AppTypography.headingFont,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isBn ? 'সক্রিয়' : 'ACTIVE',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isBn
                                  ? (r['subtitleBn'] as String)
                                  : (r['subtitleEn'] as String),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

