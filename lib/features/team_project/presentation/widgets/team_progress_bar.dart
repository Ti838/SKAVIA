import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Project Progress & Budget overview card aligned with SKAVIA screen 10.
class TeamProgressBar extends StatelessWidget {
  final double progressPercent;
  final double budget;

  const TeamProgressBar({
    super.key,
    this.progressPercent = 0.60,
    this.budget = 15000.0,
  });

  @override
  Widget build(BuildContext context) {
    final percentInt = (progressPercent * 100).toInt();
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Project Progress',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percentInt%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: tokens.brandAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: tokens.subtleBorder,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.brandAccent),
            ),
          ),
          if (budget > 0) ...[
            const SizedBox(height: 10),
            Text(
              'Budget: ৳ ${budget.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                color: tokens.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
