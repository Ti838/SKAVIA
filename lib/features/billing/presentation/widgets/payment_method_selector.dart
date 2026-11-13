import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Reusable list of selectable payment rails (bKash, Nagad, Card, SSLCommerz, Cash).
class PaymentMethodSelector extends StatelessWidget {
  final List<Map<String, dynamic>> methods;
  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.methods,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: methods.map((method) {
        final isSelected = selectedMethod == method['id'];
        final rawColor = method['color'] as Color;
        final methodColor =
            isDark && method['id'] == 'Card' ? tokens.brandAccent : rawColor;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onMethodSelected(method['id'] as String),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? methodColor.withValues(alpha: isDark ? 0.16 : 0.08)
                    : tokens.cardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(
                  color: isSelected ? methodColor : tokens.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: methodColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      method['icon'] as IconData,
                      color: methodColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method['name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          method['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: tokens.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? methodColor : tokens.border,
                        width: isSelected ? 6 : 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
