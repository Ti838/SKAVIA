import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';

/// Renders the Client ("Invoice To") and Invoice Number / Date columns for InvoiceScreen.
class InvoicePartiesSection extends StatelessWidget {
  final String clientName;
  final String clientPhone;
  final String invoiceNumber;
  final DateTime paidAt;

  const InvoicePartiesSection({
    super.key,
    required this.clientName,
    required this.clientPhone,
    required this.invoiceNumber,
    required this.paidAt,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final l10n = context.l10n;

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 16,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.invoiceTo}:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: tokens.mutedText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                clientName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                Formatters.formatBdPhone(clientPhone),
                style: TextStyle(
                  fontSize: 12,
                  color: tokens.mutedText,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.invoiceNumber}:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: tokens.mutedText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                invoiceNumber,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                Formatters.formatDate(paidAt),
                style: TextStyle(
                  fontSize: 12,
                  color: tokens.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
