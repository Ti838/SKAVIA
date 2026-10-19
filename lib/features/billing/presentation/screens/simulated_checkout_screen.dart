import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/payment_controller.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_disclaimer_card.dart';
import '../widgets/payment_method_selector.dart';
import 'invoice_screen.dart';
import 'payment_success_screen.dart';

/// Comprehensive Checkout & Payment Screen for SKAVIA services and project milestones.
/// Supports bKash, Nagad, Cards, SSLCommerz, and Cash upon Service Completion.
class SimulatedCheckoutScreen extends StatefulWidget {
  final String title;
  final double amount;
  final String? serviceRequestId;
  final String? projectId;
  final String? workerProfileId;
  final String specialistName;
  final String location;

  const SimulatedCheckoutScreen({
    super.key,
    required this.title,
    required this.amount,
    this.serviceRequestId,
    this.projectId,
    this.workerProfileId,
    this.specialistName = 'SKAVIA Verified Specialist',
    this.location = 'Dhaka, Bangladesh',
  });

  @override
  State<SimulatedCheckoutScreen> createState() =>
      _SimulatedCheckoutScreenState();
}

class _SimulatedCheckoutScreenState extends State<SimulatedCheckoutScreen> {
  final PaymentController _paymentController = PaymentController();
  String _selectedMethod = 'bKash';
  bool _isProcessing = false;

  static const List<Map<String, dynamic>> _methods = [
    {
      'id': 'bKash',
      'name': 'bKash',
      'subtitle': 'Instant MFS Checkout (017...)',
      'color': Color(0xFFD12053),
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'id': 'Nagad',
      'name': 'Nagad',
      'subtitle': 'Post Office Digital Banking',
      'color': Color(0xFFF7941D),
      'icon': Icons.wallet_rounded,
    },
    {
      'id': 'Card',
      'name': 'Credit / Debit Card',
      'subtitle': 'Visa, Mastercard, AMEX',
      'color': Color(0xFF1E293B),
      'icon': Icons.credit_card_rounded,
    },
    {
      'id': 'SSLCommerz',
      'name': 'SSLCommerz Gateway',
      'subtitle': 'Internet Banking & EMI',
      'color': Color(0xFF2563EB),
      'icon': Icons.payment_rounded,
    },
    {
      'id': 'Cash',
      'name': 'Cash on Completion',
      'subtitle': 'Pay after work inspection',
      'color': Color(0xFF059669),
      'icon': Icons.money_rounded,
    },
  ];

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  double get _baseAmount => widget.amount > 0 ? widget.amount : 1000.0;
  double get _platformFee =>
      _baseAmount * _paymentController.platformFeePercentage;
  double get _totalPayable => _baseAmount + _platformFee;

  Future<void> _processPayment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      UiFeedbackHelper.showError(
        context,
        'Authentication required. Please sign in to proceed with checkout.',
      );
      return;
    }

    setState(() => _isProcessing = true);

    final clientId = user.uid;
    final customerName =
        (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : 'Valued Client';
    final customerEmail = user.email ?? 'client@skavia.com';
    final customerPhone = user.phoneNumber ?? '01700000000';

    try {
      // 1. Initiate checkout via PaymentController
      await _paymentController.initiateCheckout(
        clientId: clientId,
        serviceRequestId: widget.serviceRequestId,
        projectId: widget.projectId,
        totalAmount: _totalPayable,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        workerProfileId: widget.workerProfileId,
        serviceTitle: widget.title,
      );

      // 2. Complete payment settlement
      final txId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
      await _paymentController.handlePaymentSuccess(
        gatewayTxId: txId,
        gatewayName: _selectedMethod,
        clientName: customerName,
        workerProfileId: widget.workerProfileId,
      );

      final transactionId =
          _paymentController.currentTransaction?.transactionId ??
          'TRX-${DateTime.now().millisecondsSinceEpoch}';

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              amount: _totalPayable,
              transactionId: transactionId,
              paymentMethod: _selectedMethod,
              jobTitle: widget.title,
              specialistName: widget.specialistName,
              serviceRequestId: widget.serviceRequestId,
              projectId: widget.projectId,
              onViewInvoice: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InvoiceScreen(
                      invoiceNumber:
                          'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                      serviceTitle: widget.title,
                      clientName: customerName,
                      clientPhone: customerPhone,
                      specialistName: widget.specialistName,
                      baseAmount: _baseAmount,
                      platformFee: _platformFee,
                      totalAmount: _totalPayable,
                      paymentMethod: _selectedMethod,
                      transactionId: transactionId,
                      paidAt: DateTime.now(),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        UiFeedbackHelper.showError(
          context,
          'Payment could not be completed: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Checkout & Escrow',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            OrderSummaryCard(
              title: widget.title,
              specialistName: widget.specialistName,
              baseAmount: _baseAmount,
              platformFee: _platformFee,
              totalPayable: _totalPayable,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Escrow Guarantee Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: AppColors.successGreen.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.successGreen,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '100% Escrow Protected: Funds are held securely and released only after your Job OTP is verified.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Payment Methods
            Text(
              'Select Payment Rail',
              style: TextStyle(
                fontFamily: AppTypography.headingFont,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            // Selectable Payment Rails
            PaymentMethodSelector(
              methods: _methods,
              selectedMethod: _selectedMethod,
              onMethodSelected: (methodId) =>
                  setState(() => _selectedMethod = methodId),
            ),

            // Sandbox / Test Mode Disclaimer
            PaymentDisclaimerCard(selectedMethod: _selectedMethod),

            // Pay CTA
            AppButton(
              text: _isProcessing
                  ? (_selectedMethod == 'Cash'
                        ? 'Confirming Booking...'
                        : 'Processing Sandbox Transaction...')
                  : (_selectedMethod == 'Cash'
                        ? 'Confirm Cash on Delivery (${Formatters.formatCurrency(_totalPayable)})'
                        : 'Test Sandbox Payment (${Formatters.formatCurrency(_totalPayable)})'),
              isLoading: _isProcessing,
              onPressed: _isProcessing ? null : _processPayment,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
