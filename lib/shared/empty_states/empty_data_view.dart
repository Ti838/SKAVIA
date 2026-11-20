import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import '../widgets/app_button.dart';

/// Unified empty and filtered-empty state component for SKAVIA.
/// Distinguishes genuinely empty collections from active filter/search misses
/// and provides clear next actions without fabricated placeholder content.
class EmptyDataView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final bool isFiltered;
  final bool scrollable;

  const EmptyDataView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.isFiltered = false,
    this.scrollable = true,
  });

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final badgeBg = isFiltered
        ? colorScheme.secondaryContainer
        : colorScheme.primaryContainer;
    final badgeFg = isFiltered
        ? colorScheme.onSecondaryContainer
        : colorScheme.onPrimaryContainer;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
            child: Icon(
              isFiltered ? Icons.filter_alt_off_outlined : icon,
              size: 36,
              color: badgeFg,
            ),
          ),
          const SizedBox(height: AppDimensions.space20),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: AppDimensions.space20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                AppButton(
                  text: actionText!,
                  onPressed: onAction!,
                  variant: isFiltered
                      ? AppButtonVariant.secondary
                      : AppButtonVariant.primary,
                  width: 200,
                  height: 46,
                ),
                if (secondaryActionText != null && onSecondaryAction != null)
                  AppButton(
                    text: secondaryActionText!,
                    onPressed: onSecondaryAction!,
                    variant: AppButtonVariant.outline,
                    width: 200,
                    height: 46,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!scrollable) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
            vertical: AppDimensions.space32,
          ),
          child: _buildContent(context),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  constraints.hasBoundedHeight && constraints.maxHeight > 48
                  ? constraints.maxHeight - (AppDimensions.space24 * 2)
                  : 0,
              minWidth: double.infinity,
            ),
            child: Center(child: _buildContent(context)),
          ),
        );
      },
    );
  }
}
