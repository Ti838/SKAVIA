import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/empty_states/empty_data_view.dart';

/// Actionable empty state for Messages when no direct conversations exist yet.
class ChatEmptyState extends StatelessWidget {
  final bool shrinkWrap;

  const ChatEmptyState({super.key, this.shrinkWrap = false});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return EmptyDataView(
      scrollable: !shrinkWrap,
      icon: Icons.forum_outlined,
      title: l10n.messagesEmptyTitle,
      message: l10n.messagesEmptyMessage,
      actionText: l10n.messagesBrowseServices,
      onAction: () => Navigator.pushNamed(context, AppRoutes.categoryCatalog),
      secondaryActionText: l10n.messagesPostRequirement,
      onSecondaryAction: () =>
          Navigator.pushNamed(context, AppRoutes.postRequirement),
    );
  }
}
