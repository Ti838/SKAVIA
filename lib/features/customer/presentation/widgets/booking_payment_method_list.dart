import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Selectable list of payment methods (bKash, Nagad, Bank Transfer, Card, Cash).
class BookingPaymentMethodList extends StatelessWidget {
  final List<Map<String, dynamic>> paymentOptions;
  final String selectedPaymentMethod;
  final ValueChanged<String> onMethodSelected;

  const BookingPaymentMethodList({
    super.key,
    required this.paymentOptions,
    required this.selectedPaymentMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: paymentOptions.map((opt) {
            final id = opt['id'] as String;
            final isSelected = selectedPaymentMethod == id;
            final rawColor = opt['color'] as Color;
            final iconColor = (isDark && rawColor == const Color(0xFF475569))
                ? const Color(0xFF94A3B8)
                : rawColor;
            final icon = opt['icon'] as IconData;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onMethodSelected(id),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? tokens.brandAccent : tokens.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: iconColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            opt['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? tokens.brandAccent
                                  : tokens.border,
                              width: isSelected ? 6 : 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

