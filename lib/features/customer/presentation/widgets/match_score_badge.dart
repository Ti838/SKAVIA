import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Reusable badge displaying algorithmic match score percentage with color tiers.
class MatchScoreBadge extends StatelessWidget {
  final double score; // 0.0 to 1.0 or 0 to 100
  final double size;

  const MatchScoreBadge({super.key, required this.score, this.size = 36});

  double get _normalizedScore => score > 1.0 ? score : score * 100;

  Color get _badgeColor {
    if (_normalizedScore >= 90) return AppColors.successGreen;
    if (_normalizedScore >= 75) return AppColors.primarySky;
    if (_normalizedScore >= 60) return AppColors.accent;
    return AppColors.textMedium;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 13, color: _badgeColor),
          const SizedBox(width: 4),
          Text(
            '${_normalizedScore.toStringAsFixed(0)}% Match',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
