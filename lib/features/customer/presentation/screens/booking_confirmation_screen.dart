import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
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
    setState(() => _isSubmitting = true);

    final randomOtp = (1000 + Random().nextInt(9000)).toString();
    final requestId = 'sr_${DateTime.now().millisecondsSinceEpoch}';
    final user = FirebaseAuth.instance.currentUser;
    final clientId =
        user?.uid ?? 'guest_client_${DateTime.now().millisecondsSinceEpoch}';

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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BookingTimelineScreen(
              requestId: requestId,
              jobTitle: effectiveTitle,
              workerName: widget.workerName,
              tradeTitle: widget.tradeTitle.isNotEmpty
                  ? widget.tradeTitle
                  : 'Mobile Developer',
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
              const Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayServiceTitle,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 22, color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          displayAmount,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Payment Method Section
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              Column(
                children: _paymentOptions.map((opt) {
                  final id = opt['id'] as String;
                  final isSelected = _selectedPaymentMethod == id;
                  final color = opt['color'] as Color;
                  final icon = opt['icon'] as IconData;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedPaymentMethod = id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
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
                          // Brand icon container
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              opt['name'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFCBD5E1),
                                width: isSelected ? 6 : 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
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
