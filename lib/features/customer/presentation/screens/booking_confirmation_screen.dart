import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../billing/presentation/screens/simulated_checkout_screen.dart';
import '../widgets/booking_payment_details_card.dart';
import '../widgets/booking_payment_method_list.dart';
import 'booking_timeline_screen.dart';

/// Payment & Escrow Booking Confirmation Screen matching Screen 14 of SKAVIA reference design.
/// Dispatches service request to Supabase while offering bKash, Nagad, Bank Transfer, and Card options.
class BookingConfirmationScreen extends StatefulWidget {
  final String? requirementId;
  final String workerProfileId;
  final String workerName;
  final String tradeTitle;
  final double hourlyRate;
  final String jobTitle;
  final String location;

  const BookingConfirmationScreen({
    super.key,
    this.requirementId,
    required this.workerProfileId,
    required this.workerName,
    required this.tradeTitle,
    required this.hourlyRate,
    required this.jobTitle,
    required this.location,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final DateTime _selectedDate = DateTime.now().add(const Duration(hours: 2));
  String _selectedPaymentMethod = 'bKash';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'id': 'bKash',
      'name': 'bKash',
      'color': Color(0xFFD12053),
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'id': 'Nagad',
      'name': 'Nagad',
      'color': Color(0xFFF7941D),
      'icon': Icons.wallet_rounded,
    },
    {
      'id': 'Bank Transfer',
      'name': 'Bank Transfer',
      'color': Color(0xFF2563EB),
      'icon': Icons.account_balance_rounded,
    },
    {
      'id': 'Card',
      'name': 'Card',
      'color': Color(0xFF475569),
      'icon': Icons.credit_card_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.location;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  double get _basePrice => widget.hourlyRate > 0 ? widget.hourlyRate : 150.0;
  double get _platformFee => _basePrice * 0.10; // 10% platform fee
  double get _totalPrice => _basePrice + _platformFee;

  Future<void> _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      UiFeedbackHelper.showError(
        context,
        'Authentication required. Please sign in to book a service.',
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      UiFeedbackHelper.showError(
        context,
        'A valid delivery address is required for doorstep technician dispatch.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final randomOtp = (1000 + Random().nextInt(9000)).toString();
    final requestId = 'sr_${DateTime.now().millisecondsSinceEpoch}';
    final clientId = user.uid;

    try {
      try {
        final client = Supabase.instance.client;
        await client.from('service_requests').insert({
          'client_id': clientId,
          'worker_profile_id': widget.workerProfileId.startsWith('wp_')
              ? null
              : widget.workerProfileId,
          'status': 'Requested',
          'scheduled_at': _selectedDate.toIso8601String(),
          'agreed_price': _totalPrice,
          'service_notes':
              'OTP:$randomOtp | Method:$_selectedPaymentMethod | Addr:${_addressController.text.trim()}',
        });
      } catch (e) {
        debugPrint('[Booking] Supabase insert warning: $e');
      }

      if (mounted) {
        final effectiveTitle = widget.jobTitle.isNotEmpty
            ? widget.jobTitle
            : 'Certified Trade Service';

        if (_selectedPaymentMethod != 'Cash') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SimulatedCheckoutScreen(
                title: effectiveTitle,
                amount: _basePrice,
                serviceRequestId: requestId,
                workerProfileId: widget.workerProfileId,
                specialistName: widget.workerName,
                location: _addressController.text.trim().isNotEmpty
                    ? _addressController.text.trim()
                    : 'Dhaka, Bangladesh',
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BookingTimelineScreen(
                requestId: requestId,
                jobTitle: effectiveTitle,
                workerName: widget.workerName,
                tradeTitle: widget.tradeTitle.isNotEmpty
                    ? widget.tradeTitle
                    : 'Certified Specialist',
                scheduledSlot: 'Today',
                totalPrice: _totalPrice,
                jobOtp: randomOtp,
                address: _addressController.text.trim().isNotEmpty
                    ? _addressController.text.trim()
                    : 'Dhaka, Bangladesh',
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayServiceTitle = widget.jobTitle.isNotEmpty
        ? widget.jobTitle
        : 'Mobile App Development';
    final displayAmount = widget.hourlyRate > 0
        ? '\$${widget.hourlyRate.toInt()}'
        : '\$150';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Details Section
              BookingPaymentDetailsCard(
                serviceTitle: displayServiceTitle,
                displayAmount: displayAmount,
              ),
              const SizedBox(height: 26),

              // Payment Method Section
              BookingPaymentMethodList(
                paymentOptions: _paymentOptions,
                selectedPaymentMethod: _selectedPaymentMethod,
                onMethodSelected: (id) =>
                    setState(() => _selectedPaymentMethod = id),
              ),
              const SizedBox(height: 16),

              // Address input (clean minimal card)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          hintText: 'Service Address (e.g. Dhaka, Bangladesh)',
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Pay Now Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Pay Now',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
