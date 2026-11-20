import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Card widget representing a role option on the RoleSelectionScreen.
class RoleOptionCard extends StatelessWidget {
  final Map<String, dynamic> role;
  final bool isSelected;
  final String corporateSubtype;
  final VoidCallback onTap;
  final ValueChanged<String> onSubtypeChanged;

  const RoleOptionCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.corporateSubtype,
    required this.onTap,
    required this.onSubtypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final skavia = context.skavia;
    final isBn = context.isBengali;

    final roleId = role['id'] as String;
    final accentColor = role['color'] as Color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? accentColor.withValues(alpha: 0.16)
                    : accentColor.withValues(alpha: 0.08))
                : (isDark
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                    : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE2E8F0)),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      role['icon'] as IconData,
                      color: accentColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn
                              ? (role['titleBn'] as String)
                              : (role['titleEn'] as String),
                          style: TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isBn
                                ? (role['badgeBn'] as String)
                                : (role['badgeEn'] as String),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isBn
                              ? (role['subtitleBn'] as String)
                              : (role['subtitleEn'] as String),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? accentColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? accentColor : colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
              if (roleId == 'enterprise' && isSelected) ...[
                const SizedBox(height: 12),
                Divider(
                  color: skavia.subtleBorder,
                  height: 1,
                ),
                const SizedBox(height: 10),
                Text(
                  isBn
                      ? 'প্রাতিষ্ঠানিক ধরন নির্বাচন করুন:'
                      : 'Entity Classification:',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: ['Business Client', 'Organization'].map(
                    (subtype) {
                      final active = corporateSubtype == subtype;
                      return InkWell(
                        onTap: () => onSubtypeChanged(subtype),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? accentColor.withValues(alpha: 0.2)
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: active
                                  ? accentColor
                                  : skavia.subtleBorder,
                            ),
                          ),
                          child: Text(
                            subtype,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: active
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: active
                                  ? accentColor
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
