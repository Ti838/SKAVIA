import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_button.dart';

/// Screen enabling skilled workers to showcase past projects, certificates, and work samples.
/// Inspired by LinkedIn & Upwork portfolio presentations.
class PortfolioManagementScreen extends StatefulWidget {
  const PortfolioManagementScreen({super.key});

  @override
  State<PortfolioManagementScreen> createState() =>
      _PortfolioManagementScreenState();
}

class _PortfolioManagementScreenState extends State<PortfolioManagementScreen> {
  final List<Map<String, dynamic>> _portfolioItems = [
    {
      'title': 'High-Rise Commercial HVAC & Chiller Overhaul',
      'category': 'HVAC & AC Engineering',
      'year': '2025',
      'description': 'Complete inspection, refrigerant recharge, and compressor replacement for a 12-story corporate tower in Banani.',
      'skills': ['Commercial HVAC', '3-Phase Electrical', 'Safety Auditing'],
      'verified': true,
    },
    {
      'title': 'Smart Home IoT Electrical Automation',
      'category': 'Electrical & Lighting',
      'year': '2026',
      'description': 'Installed 48-channel smart breakers, automated circuit protection, and voice-controlled lighting panel in Dhanmondi.',
      'skills': ['Smart Breakers', 'Surge Protection', 'Wiring Diagnostics'],
      'verified': true,
    },
    {
      'title': 'Emergency High-Pressure Main Line Plumbing',
      'category': 'Plumbing & Water Systems',
      'year': '2026',
      'description': 'Repaired ruptured underground 4-inch supply line and restored clean pressure distribution for residential complex.',
      'skills': ['PPR Welding', 'Hydrostatic Testing', 'Leak Detection'],
      'verified': false,
    },
  ];

  void _addNewProject() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final skillController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Verified Work Sample',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Project Title',
                  hintText: 'e.g. Modern Residential Rewiring',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Work Description & Deliverables',
                  hintText: 'Describe the challenge, tools used, and outcome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: skillController,
                decoration: const InputDecoration(
                  labelText: 'Tags / Skills (comma separated)',
                  hintText: 'e.g. Electrical, Smart Home, Safety',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Publish to Portfolio',
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    setState(() {
                      _portfolioItems.insert(0, {
                        'title': titleController.text.trim(),
                        'category': 'General Skilled Trade',
                        'year': DateTime.now().year.toString(),
                        'description': descController.text.trim().isNotEmpty
                            ? descController.text.trim()
                            : 'Completed to verified SKAVIA trade standards.',
                        'skills': skillController.text.trim().isNotEmpty
                            ? skillController.text
                                  .split(',')
                                  .map((s) => s.trim())
                                  .toList()
                            : ['Certified Workmanship'],
                        'verified': false,
                      });
                    });
                    Navigator.pop(ctx);
                    UiFeedbackHelper.showSuccess(
                      context,
                      'Portfolio project published to your public profile!',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
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
          'Work Samples & Portfolio',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
            onPressed: _addNewProject,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        itemCount: _portfolioItems.length,
        separatorBuilder: (_, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = _portfolioItems[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySky.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['category'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryRoyal,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (item['verified'] == true) ...[
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.primarySky,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primarySky,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          item['year'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item['title'] as String,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['description'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (item['skills'] as List<dynamic>).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.surface
                            : AppColors.sheetSurfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        skill.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewProject,
        backgroundColor: AppColors.primaryRoyal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Work Sample'),
      ),
    );
  }
}
