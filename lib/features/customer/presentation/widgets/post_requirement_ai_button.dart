import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Auto-diagnose with SKAVIA AI action button with loading spinner.
class PostRequirementAiButton extends StatelessWidget {
  final bool isDiagnosing;
  final VoidCallback onDiagnose;

  const PostRequirementAiButton({
    super.key,
    required this.isDiagnosing,
    required this.onDiagnose,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;

    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: isDiagnosing ? null : onDiagnose,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tokens.softVioletBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: tokens.brandAccent.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDiagnosing)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: tokens.brandAccent,
                  ),
                )
              else
                Icon(
                  Icons.auto_awesome,
                  color: tokens.brandAccent,
                  size: 14,
                ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Auto-Diagnose with SKAVIA AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tokens.brandAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

