import 'package:flutter/material.dart';

import '../../../../core/services/app_language_service.dart';
import '../../domain/enums/diagnostic_status.dart';

/// Material 3 tonal pill badge for diagnostic statuses.
class DiagnosticStatusBadge extends StatelessWidget {
  final DiagnosticStatus status;
  final bool compact;

  const DiagnosticStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final label = isBn ? status.labelBn : status.labelEn;
    final color = status.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: compact ? 12 : 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
