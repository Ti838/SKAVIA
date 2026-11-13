import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Horizontal stepper indicator for the Request Service flow aligned with Screen 6
class PostRequirementStepper extends StatelessWidget {
  final int activeStep;

  const PostRequirementStepper({super.key, this.activeStep = 1});

  Widget _buildStepItem(
    BuildContext context,
    int stepNumber,
    String title,
    bool isActive,
  ) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isActive ? tokens.brandAccent : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? tokens.brandAccent : tokens.border,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$stepNumber',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isActive ? tokens.onBrandAccent : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? tokens.brandAccent : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        color: context.skavia.border,
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildStepItem(context, 1, 'Details', activeStep >= 1),
          _buildStepDivider(context),
          _buildStepItem(context, 2, 'Skills', activeStep >= 2),
          _buildStepDivider(context),
          _buildStepItem(context, 3, 'Budget', activeStep >= 3),
          _buildStepDivider(context),
          _buildStepItem(context, 4, 'Review', activeStep >= 4),
        ],
      ),
    );
  }
}
