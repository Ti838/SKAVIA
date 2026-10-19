import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_button.dart';

/// Screen allowing administrators to configure and deploy cross-disciplinary teams for complex turnkey contracts.
class TeamAssemblyScreen extends StatefulWidget {
  const TeamAssemblyScreen({super.key});

  @override
  State<TeamAssemblyScreen> createState() => _TeamAssemblyScreenState();
}

class _TeamAssemblyScreenState extends State<TeamAssemblyScreen> {
  final _teamNameController = TextEditingController(
    text: 'Gulshan Commercial MEP Response Unit',
  );
  final _projectBudgetController = TextEditingController(text: '75000');

  final List<String> _selectedTrades = [
    'Electrical & Lighting',
    'HVAC & AC',
    'Plumbing & Water Systems',
  ];

  final List<String> _availableTrades = [
    'Electrical & Lighting',
    'HVAC & AC',
    'Plumbing & Water Systems',
    'Civil & Carpentry',
    'IT & Smart Automation',
    'Fire Safety & Compliance',
  ];

  @override
  void dispose() {
    _teamNameController.dispose();
    _projectBudgetController.dispose();
    super.dispose();
  }

  void _assembleTeam() {
    UiFeedbackHelper.showSuccess(
      context,
      'Turnkey team unit assembled! Matched top-ranked certified specialists deployed to project roster.',
    );
    Navigator.of(context).pop();
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
          'Assemble Specialized Unit',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Configuration',
              style: TextStyle(
                fontFamily: AppTypography.headingFont,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _teamNameController,
              decoration: const InputDecoration(
                labelText: 'Unit / Team Call-Sign',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _projectBudgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Collective Escrow Budget (৳ BDT)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Required Trade Disciplines',
              style: TextStyle(
                fontFamily: AppTypography.headingFont,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTrades.map((trade) {
                final isSelected = _selectedTrades.contains(trade);
                return FilterChip(
                  label: Text(trade),
                  selected: isSelected,
                  selectedColor: AppColors.primarySky.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primaryRoyal,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryRoyal
                        : colorScheme.onSurface,
                    fontSize: 12.5,
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedTrades.add(trade);
                      } else {
                        _selectedTrades.remove(trade);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest
                    : AppColors.sheetSurfaceSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primarySky,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SKAVIA Algorithmic Matcher will automatically select the highest-rated verified specialists within the project zone.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            AppButton(
              text: 'Deploy Team to Project Roster',
              onPressed: _assembleTeam,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
