import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';

/// Screen enabling skilled workers to showcase past projects, certificates, and work samples.
class PortfolioManagementScreen extends StatefulWidget {
  const PortfolioManagementScreen({super.key});

  @override
  State<PortfolioManagementScreen> createState() =>
      _PortfolioManagementScreenState();
}

class _PortfolioManagementScreenState extends State<PortfolioManagementScreen> {
  static const String _cacheKey = 'worker_portfolio_items_v1';

  List<Map<String, dynamic>> _portfolioItems = [
    {
      'title': 'High-Rise Commercial HVAC & Chiller Overhaul',
      'category': 'HVAC & AC Engineering',
      'year': '2025',
      'description':
          'Complete inspection, refrigerant recharge, and compressor replacement for a 12-story corporate tower in Banani.',
      'skills': ['Commercial HVAC', '3-Phase Electrical', 'Safety Auditing'],
      'verified': true,
    },
    {
      'title': 'Smart Home IoT Electrical Automation',
      'category': 'Electrical & Lighting',
      'year': '2026',
      'description':
          'Installed 48-channel smart breakers, automated circuit protection, and voice-controlled lighting panel in Dhanmondi.',
      'skills': ['Smart Breakers', 'Surge Protection', 'Wiring Diagnostics'],
      'verified': true,
    },
    {
      'title': 'Emergency High-Pressure Main Line Plumbing',
      'category': 'Plumbing & Water Systems',
      'year': '2026',
      'description':
          'Repaired ruptured underground 4-inch supply line and restored clean pressure distribution for residential complex.',
      'skills': ['PPR Welding', 'Hydrostatic Testing', 'Leak Detection'],
      'verified': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    final cached = LocalCacheService.instance.get(_cacheKey);
    if (cached is List && cached.isNotEmpty) {
      _portfolioItems = cached
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }

  void _persistPortfolio() {
    LocalCacheService.instance.put(_cacheKey, _portfolioItems);
  }

  void _addNewProject() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final skillController = TextEditingController();
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

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
          color: tokens.sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: tokens.border)),
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
                    color: tokens.border,
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
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: TextStyle(color: colorScheme.onSurface),
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
                style: TextStyle(color: colorScheme.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Work Description & Deliverables',
                  hintText: 'Describe the challenge, tools used, and outcome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: skillController,
                style: TextStyle(color: colorScheme.onSurface),
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
                                  .where((s) => s.isNotEmpty)
                                  .toList()
                            : ['Certified Workmanship'],
                        'verified': false,
                      });
                    });
                    _persistPortfolio();
                    Navigator.pop(ctx);
                    UiFeedbackHelper.showSuccess(
                      context,
                      'Portfolio project saved locally to your profile!',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      titleController.dispose();
      descController.dispose();
      skillController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppAppBar(
        title: 'Work Samples & Portfolio',
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              size: 24,
              color: colorScheme.onSurface,
            ),
            onPressed: _addNewProject,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        itemCount: _portfolioItems.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = _portfolioItems[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.softBlueBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['category'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tokens.brandAccent,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (item['verified'] == true) ...[
                          Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: tokens.brandAccent,
                          ),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: tokens.brandAccent,
                            ),
                          ),
                        ],
                        Text(
                          item['year'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: tokens.secondaryText,
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
                    color: tokens.secondaryText,
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
                        color: tokens.subtleCardBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: tokens.subtleBorder),
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
        backgroundColor: tokens.brandAccent,
        foregroundColor: tokens.onBrandAccent,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Work Sample'),
      ),
    );
  }
}
