import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Reusable badge displaying algorithmic match score percentage with color tiers.
class MatchScoreBadge extends StatelessWidget {
  final double score; // 0.0 to 1.0 or 0 to 100
  final double size;

  const MatchScoreBadge({super.key, required this.score, this.size = 36});

  double get _normalizedScore => score > 1.0 ? score : score * 100;

  Color _badgeColor(BuildContext context) {
    if (_normalizedScore >= 90) return AppColors.successGreen;
    if (_normalizedScore >= 75) return context.skavia.brandAccent;
    if (_normalizedScore >= 60) return AppColors.warningAmber;
    return context.colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${_normalizedScore.toStringAsFixed(0)}% Match',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
