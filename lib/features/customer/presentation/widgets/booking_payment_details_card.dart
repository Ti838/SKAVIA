import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';

/// Card showing the service name, itemized breakdown, and payment amount for a booking.
class BookingPaymentDetailsCard extends StatelessWidget {
  final String serviceTitle;
  final String displayAmount;
  final double? baseAmount;
  final double? platformFee;
  final double? totalAmount;

  const BookingPaymentDetailsCard({
    super.key,
    required this.serviceTitle,
    required this.displayAmount,
    this.baseAmount,
    this.platformFee,
    this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final hasBreakdown =
        baseAmount != null && platformFee != null && totalAmount != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.subtleCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      serviceTitle,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Divider(height: 22, color: tokens.border),
              if (hasBreakdown) ...[
                _buildBreakdownRow(
                  context,
                  'Base Service Rate',
                  Formatters.formatCurrency(baseAmount!),
                ),
                const SizedBox(height: 8),
                _buildBreakdownRow(
                  context,
                  'SKAVIA Management Fee (15%)',
                  Formatters.formatCurrency(platformFee!),
                ),
                Divider(height: 22, color: tokens.border),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hasBreakdown ? 'Total Payable' : 'Amount',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasBreakdown
                        ? Formatters.formatCurrency(totalAmount!)
                        : displayAmount,
                    style: TextStyle(
                      fontSize: 16,
                      color: tokens.brandAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(BuildContext context, String label, String value) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

