import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Interactive task item card for Project Management board
class ProjectTaskItemCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onToggleStatus;

  const ProjectTaskItemCard({
    super.key,
    required this.task,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final title = task['title'] as String? ?? 'Task';
    final status = task['status'] as String? ?? 'Pending';
    final date = task['date'] as String? ?? 'Apr 24';

    final isCompleted = status == 'Completed';
    final isInProgress = status == 'In Progress';

    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    Color statusColor;
    Color statusBg;

    if (isCompleted) {
      statusColor = const Color(0xFF10B981);
      statusBg = tokens.softMintBg;
    } else if (isInProgress) {
      statusColor = tokens.brandAccent;
      statusBg = tokens.softBlueBg;
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusBg = tokens.softPeachBg;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggleStatus,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : tokens.border,
                  width: 2,
                ),
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? tokens.secondaryText
                        : colorScheme.onSurface,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: tokens.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
