import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// 6-digit PIN input row widget for OTP verification screens with automated focus traversal and paste handling.
class OtpPinInputRow extends StatelessWidget {
  final int pinLength;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueChanged<int> onDigitChanged;

  const OtpPinInputRow({
    super.key,
    required this.pinLength,
    required this.controllers,
    required this.focusNodes,
    required this.onDigitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final skavia = context.skavia;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(pinLength, (index) {
        final hasText = controllers[index].text.isNotEmpty;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: skavia.brandAccent,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: hasText
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : colorScheme.surfaceContainerHighest,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: hasText
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2.5,
                    ),
                  ),
                ),
                onChanged: (val) => onDigitChanged(index),
              ),
            ),
          ),
        );
      }),
    );
  }
}
