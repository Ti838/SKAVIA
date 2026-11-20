import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/skavia_badge.dart';

/// Official itemized digital invoice screen with tax breakdown, payment rail details, and sharing.
class InvoiceScreen extends StatelessWidget {
  final String invoiceNumber;
  final String serviceTitle;
  final String clientName;
  final String clientPhone;
  final String specialistName;
  final double baseAmount;
  final double platformFee;
  final double totalAmount;
  final String paymentMethod;
  final String transactionId;
  final DateTime paidAt;
  final String status;

  const InvoiceScreen({
    super.key,
    required this.invoiceNumber,
    required this.serviceTitle,
    required this.clientName,
    required this.clientPhone,
    required this.specialistName,
    required this.baseAmount,
    required this.platformFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.transactionId,
    required this.paidAt,
    this.status = 'Paid',
  });

  SkaviaBadgeTone _statusTone(String normalized) {
    if (normalized.contains('paid') ||
        normalized.contains('settled') ||
        normalized.contains('completed')) {
      return SkaviaBadgeTone.success;
    }
    if (normalized.contains('pending') || normalized.contains('escrow')) {
      return SkaviaBadgeTone.warning;
    }
    if (normalized.contains('refund') ||
        normalized.contains('fail') ||
        normalized.contains('cancel')) {
      return SkaviaBadgeTone.error;
    }
    return SkaviaBadgeTone.neutral;
  }

  IconData _statusIcon(String normalized) {
    if (normalized.contains('paid') ||
        normalized.contains('settled') ||
        normalized.contains('completed')) {
      return Icons.check_circle_rounded;
    }
    if (normalized.contains('pending') || normalized.contains('escrow')) {
      return Icons.schedule_rounded;
    }
    return Icons.info_outline_rounded;
  }

  String _shareSummary() {
    return [
      'SKAVIA Invoice $invoiceNumber',
      'Service: $serviceTitle',
      'Client: $clientName',
      'Specialist: $specialistName',
      'Total: ${Formatters.formatCurrency(totalAmount)}',
      'Status: $status',
      'Method: $paymentMethod',
      if (transactionId.isNotEmpty) 'Ref: $transactionId',
      'Date: ${Formatters.formatDate(paidAt)}',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final l10n = context.l10n;
    final normalizedStatus = status.trim().toLowerCase();

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppAppBar(
        title: l10n.invoiceTitle,
        actions: [
          IconButton(
            icon: Icon(
              Icons.copy_rounded,
              size: 20,
              color: colorScheme.onSurface,
            ),
            tooltip: l10n.invoiceCopySummary,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _shareSummary()));
              if (context.mounted) {
                UiFeedbackHelper.showSuccess(
                  context,
                  l10n.invoiceSummaryCopied,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tokens.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: tokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SKAVIA',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: tokens.brandAccent,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Every Skill. Every Opportunity.',
                          style: TextStyle(
                            fontSize: 11,
                            color: tokens.mutedText,
                          ),
                        ),
                      ],
                    ),
                    SkaviaBadge(
                      label: status.trim().isEmpty
                          ? 'PAID'
                          : status.trim().toUpperCase(),
                      icon: _statusIcon(normalizedStatus),
                      tone: _statusTone(normalizedStatus),
                    ),
                  ],
                ),
              ),
              Divider(height: 32, color: tokens.border),

              SizedBox(
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
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.subtleCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tokens.border),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Transaction Reference:',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: tokens.mutedText,
                      ),
                    ),
                    Text(
                      transactionId,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Itemized Breakdown',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              _buildInvoiceItem(
                context,
                serviceTitle,
                'Certified execution by $specialistName',
                Formatters.formatCurrency(baseAmount),
              ),
              Divider(height: 20, color: tokens.border),
              _buildInvoiceItem(
                context,
                'SKAVIA Platform & Trust Escrow (15%)',
                'Insurance protection, dispute mediation & Job OTP verification',
                Formatters.formatCurrency(platformFee),
              ),
              Divider(height: 24, color: tokens.border),

              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      'Total Paid ($paymentMethod)',
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(totalAmount),
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: tokens.brandAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.softBlueBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: tokens.brandAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This invoice is digitally signed and compliant with the SKAVIA Marketplace Services Standard. Escrow balance is settled upon Job OTP verification.',
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.secondaryText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(
    BuildContext context,
    String title,
    String subtitle,
    String amount,
  ) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: tokens.mutedText),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
