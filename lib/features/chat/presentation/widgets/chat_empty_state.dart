import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Empty state illustration and message for chat list when no direct messages exist yet.
class ChatEmptyState extends StatelessWidget {
  final bool shrinkWrap;

  const ChatEmptyState({super.key, this.shrinkWrap = false});

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return ListView(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: tokens.softBlueBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.forum_outlined,
                  size: 48,
                  color: tokens.brandAccent,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Conversations Yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'When you book a specialist, post a requirement, or accept a job assignment, your direct real-time communication will be listed here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: tokens.mutedText,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
