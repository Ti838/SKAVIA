import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';
import '../widgets/app_button.dart';

/// Unified error & recovery state view for SKAVIA.
/// Used whenever a backend/network request fails so failures are never
/// disguised as empty collections or filled with fabricated fallback items.
class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final String retryText;
  final VoidCallback? onRetry;
  final bool scrollable;

  const ErrorView({
    super.key,
    this.title = 'Something Went Wrong',
    required this.message,
    this.retryText = 'Try Again',
    this.onRetry,
    this.scrollable = true,
  });

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tokens.errorBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 36,
              color: tokens.onErrorBg,
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
          if (onRetry != null) ...[
            const SizedBox(height: AppDimensions.space20),
            AppButton(
              text: retryText,
              onPressed: onRetry!,
              variant: AppButtonVariant.primary,
              width: 180,
              height: 46,
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
