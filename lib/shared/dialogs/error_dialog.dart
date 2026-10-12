import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_typography.dart';
import '../widgets/app_button.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.buttonText = 'Dismiss',
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Notice',
    required String message,
    String buttonText = 'Dismiss',
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => ErrorDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actionsPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
      actions: [
        AppButton(
          text: buttonText,
          onPressed: onDismiss ?? () => Navigator.of(context).pop(),
          height: 40,
        ),
      ],
    );
  }
}
