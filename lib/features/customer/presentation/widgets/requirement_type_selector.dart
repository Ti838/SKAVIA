import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Scope & Type selector for posting service requirements (Individual vs Team Project)
class RequirementTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const RequirementTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  Widget _buildCard({
    required BuildContext context,
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedType == type;
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Material(
      color: isSelected
          ? AppColors.primarySky.withValues(alpha: context.isDarkMode ? 0.18 : 0.08)
          : tokens.cardBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => onTypeChanged(type),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primarySky : tokens.border,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primarySky
                    : colorScheme.onSurfaceVariant,
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? tokens.brandAccent : colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: tokens.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Scope',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final stackCards = constraints.maxWidth < 330 || textScale > 1.35;
            final singleCard = _buildCard(
              context: context,
              type: 'Individual',
              title: 'Single Specialist',
              subtitle: 'Individual technician',
              icon: Icons.person_rounded,
            );
            final teamCard = _buildCard(
              context: context,
              type: 'Team Project',
              title: 'Team Project',
              subtitle: 'Multi-discipline team',
              icon: Icons.groups_rounded,
            );
            if (stackCards) {
              return Column(
                children: [
                  singleCard,
                  const SizedBox(height: 10),
                  teamCard,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: singleCard),
                const SizedBox(width: 12),
                Expanded(child: teamCard),
              ],
            );
          },
        ),
      ],
    );
  }
}
