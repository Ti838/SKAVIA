import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';

/// Screen allowing administrators to configure and deploy cross-disciplinary teams for complex turnkey contracts.
class TeamAssemblyScreen extends StatefulWidget {
  const TeamAssemblyScreen({super.key});

  @override
  State<TeamAssemblyScreen> createState() => _TeamAssemblyScreenState();
}

class _TeamAssemblyScreenState extends State<TeamAssemblyScreen> {
  static const String _cacheKey = 'admin_last_assembled_team';

  late final TextEditingController _teamNameController;
  late final TextEditingController _projectBudgetController;

  late final List<String> _selectedTrades;

  final List<String> _availableTrades = const [
    'Electrical & Lighting',
    'HVAC & AC',
    'Plumbing & Water Systems',
    'Civil & Carpentry',
    'IT & Smart Automation',
    'Fire Safety & Compliance',
  ];

  @override
  void initState() {
    super.initState();
    final rawCached = LocalCacheService.instance.get(_cacheKey);
    final cached = rawCached is Map
        ? Map<String, dynamic>.from(rawCached)
        : null;
    _teamNameController = TextEditingController(
      text: cached?['name']?.toString() ?? 'Gulshan Commercial MEP Response Unit',
    );
    _projectBudgetController = TextEditingController(
      text: cached?['budget']?.toString() ?? '75000',
    );
    final savedTrades = (cached?['trades'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();
    _selectedTrades = savedTrades != null && savedTrades.isNotEmpty
        ? savedTrades
        : [
            'Electrical & Lighting',
            'HVAC & AC',
            'Plumbing & Water Systems',
          ];
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _projectBudgetController.dispose();
    super.dispose();
  }

  void _assembleTeam() {
    if (_teamNameController.text.trim().isEmpty) {
      UiFeedbackHelper.showError(context, 'Enter a unit or team call-sign.');
      return;
    }
    LocalCacheService.instance.put(_cacheKey, {
      'name': _teamNameController.text.trim(),
      'budget': _projectBudgetController.text.trim(),
      'trades': List<String>.from(_selectedTrades),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    UiFeedbackHelper.showSuccess(
      context,
      'Turnkey team unit draft saved. Deploy verified specialists from project roster.',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: const AppAppBar(title: 'Assemble Specialized Unit'),
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
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Unit / Team Call-Sign',
                filled: true,
                fillColor: tokens.inputBg,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _projectBudgetController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Collective Escrow Budget (৳ BDT)',
                filled: true,
                fillColor: tokens.inputBg,
                border: const OutlineInputBorder(),
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
                  selectedColor: tokens.softBlueBg,
                  backgroundColor: tokens.subtleCardBg,
                  checkmarkColor: tokens.brandAccent,
                  side: BorderSide(
                    color: isSelected ? tokens.brandAccent : tokens.border,
                  ),
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? tokens.brandAccent
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
                color: tokens.subtleCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: tokens.brandAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SKAVIA Matching Engine ranks verified specialists within the project zone by certification and availability.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            AppButton(
              text: 'Save & Deploy Unit Configuration',
              onPressed: _assembleTeam,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
