import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/skavia_search_field.dart';

/// Search input field (with reactive clear icon) and Urgent filter toggle for Feed.
class FeedSearchUrgentBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool onlyEmergency;
  final VoidCallback onToggleEmergency;
  final bool isBn;

  const FeedSearchUrgentBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onlyEmergency,
    required this.onToggleEmergency,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.skavia;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SkaviaSearchField(
              controller: searchController,
              hintText: isBn
                  ? 'কাজের নাম বা এলাকা খুঁজুন...'
                  : 'Search feed by keyword...',
              onChanged: onSearchChanged,
              onClear: () => onSearchChanged(''),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: onlyEmergency ? tokens.warning : tokens.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              side: BorderSide(
                color: onlyEmergency ? tokens.warning : tokens.border,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onToggleEmergency,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: onlyEmergency ? Colors.white : tokens.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'জরুরি' : 'Urgent',
                      maxLines: 1,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: onlyEmergency ? Colors.white : tokens.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
