import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Screen 8: AI Analysis Results and Recommended Team structure
class AiResultsView extends StatelessWidget {
  final List<String> requiredSkills;
  final List<Map<String, String>> recommendedTeam;
  final VoidCallback onEditRequest;
  final String? projectSummary;
  final String? projectTitle;
  final String? projectId;

  const AiResultsView({
    super.key,
    required this.requiredSkills,
    required this.recommendedTeam,
    required this.onEditRequest,
    this.projectSummary,
    this.projectTitle,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final summaryText = (projectSummary != null && projectSummary!.trim().isNotEmpty)
        ? projectSummary!.trim()
        : 'Mobile app for e-commerce with payment integration and admin panel.';
    final targetTitle = (projectTitle != null && projectTitle!.trim().isNotEmpty)
        ? projectTitle!.trim()
        : 'Mobile App for E-Commerce';

    return SingleChildScrollView(
      key: const ValueKey('results_view'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Summary Card
          Text(
            'Project Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.subtleCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tokens.border),
            ),
            child: Text(
              summaryText,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: tokens.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Required Skills
          Text(
            'Required Skills',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: requiredSkills.map((skill) {
              final isOptional = skill.toLowerCase().contains('optional');
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isOptional ? tokens.cardBg : tokens.softBlueBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOptional
                        ? tokens.border
                        : tokens.brandAccent.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOptional ? tokens.mutedText : tokens.brandAccent,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Recommended Team (3-5 members)
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recommended Team',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '(3-5 members)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: tokens.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: recommendedTeam.map((member) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: tokens.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tokens.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: tokens.softBlueBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          member['index'] ?? '1',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: tokens.brandAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        member['role'] ?? 'Specialist',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Action Buttons: Edit Request & Create Team (stack on narrow/2.0x textScale)
          LayoutBuilder(
            builder: (context, constraints) {
              final stackButtons = constraints.maxWidth < 330 || textScale > 1.35;
              final editBtn = OutlinedButton(
                onPressed: onEditRequest,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  side: BorderSide(color: tokens.brandAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Edit Request',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: tokens.brandAccent,
                  ),
                ),
              );

              final createBtn = ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.projectDashboard,
                    arguments: {
                      'projectId': projectId ?? 'proj_ecommerce_001',
                      'projectTitle': targetTitle,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandAccent,
                  foregroundColor: tokens.onBrandAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Create Team',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: tokens.onBrandAccent,
                  ),
                ),
              );

              if (stackButtons) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    editBtn,
                    const SizedBox(height: 10),
                    createBtn,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: editBtn),
                  const SizedBox(width: 12),
                  Expanded(child: createBtn),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
