import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/job_otp_util.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../billing/presentation/screens/simulated_checkout_screen.dart';
import '../widgets/booking_payment_details_card.dart';
import '../widgets/booking_payment_method_list.dart';
import 'booking_timeline_screen.dart';

/// Payment & Escrow Booking Confirmation Screen matching Screen 14 of SKAVIA reference design.
/// Dispatches service request to Supabase while offering bKash, Nagad, Bank Transfer, Card, and Cash options.
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
    {
      'id': 'Cash',
      'name': 'Cash on Completion',
      'color': Color(0xFF059669),
      'icon': Icons.money_rounded,
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

  double get _basePrice => widget.hourlyRate > 0 ? widget.hourlyRate : 1500.0;
  double get _platformFee => _basePrice * AppConfig.skaviaPlatformFeePercent;
  double get _totalPrice => _basePrice + _platformFee;

  User? _safeCurrentUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitBooking() async {
    if (_isSubmitting) return;
    final user = _safeCurrentUser();
    if (user == null) {
      UiFeedbackHelper.showError(
        context,
        'Authentication required. Please sign in to book a service.',
      );
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      UiFeedbackHelper.showError(
        context,
        'A valid delivery address is required for doorstep technician dispatch.',
      );
      return;
    }

    final client = tryGetSupabaseClient();
    if (client == null) {
      UiFeedbackHelper.showError(
        context,
        'Offline mode: booking confirmation requires an active backend connection.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final randomOtp = JobOtpUtil.generateOtp();
    final clientId = user.uid;
    final extraNotes = _notesController.text.trim();

    try {
      String? effectiveWorkerProfileId = UuidUtil.isValidUuid(
        widget.workerProfileId,
      )
          ? widget.workerProfileId.trim()
          : null;

      if (effectiveWorkerProfileId == null) {
        final fallbackWorker = await client
            .from(DatabaseTables.workerProfiles)
            .select('worker_profile_id')
            .eq('is_available', true)
            .limit(1)
            .maybeSingle();
        final candidateId = fallbackWorker?['worker_profile_id']?.toString();
        if (candidateId != null && UuidUtil.isValidUuid(candidateId)) {
          effectiveWorkerProfileId = candidateId;
        }
      }

      if (effectiveWorkerProfileId == null) {
        if (mounted) {
          UiFeedbackHelper.showError(
            context,
            'No verified specialist is currently assigned to accept this booking. Please post a requirement for algorithmic matching.',
          );
        }
        return;
      }

      final inserted = await client
          .from(DatabaseTables.serviceRequests)
          .insert({
            if (UuidUtil.isValidUuid(widget.requirementId))
              'requirement_id': widget.requirementId,
            'client_id': clientId,
            'worker_profile_id': effectiveWorkerProfileId,
            'status': 'Requested',
            'scheduled_at': _selectedDate.toIso8601String(),
            'agreed_price': _totalPrice,
            'service_notes':
                'OTP:$randomOtp | Method:$_selectedPaymentMethod | Addr:$address${extraNotes.isNotEmpty ? ' | Notes:$extraNotes' : ''}',
          })
          .select('service_request_id')
          .single();

      final requestId = inserted['service_request_id']?.toString() ?? '';
      if (requestId.isEmpty) {
        throw StateError('Database did not return a service_request_id.');
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
                workerProfileId: effectiveWorkerProfileId,
                specialistName: widget.workerName,
                location: address.isNotEmpty ? address : 'Dhaka, Bangladesh',
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BookingTimelineScreen(
                requestId: requestId,
                workerProfileId: effectiveWorkerProfileId,
                jobTitle: effectiveTitle,
                workerName: widget.workerName,
                tradeTitle: widget.tradeTitle.isNotEmpty
                    ? widget.tradeTitle
                    : 'Certified Specialist',
                scheduledSlot: 'Today',
                totalPrice: _totalPrice,
                jobOtp: randomOtp,
                address: address.isNotEmpty ? address : 'Dhaka, Bangladesh',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UiFeedbackHelper.showError(context, 'Failed to confirm booking: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final displayServiceTitle = widget.jobTitle.isNotEmpty
        ? widget.jobTitle
        : 'Certified Trade Service';
    final displayAmount = Formatters.formatCurrency(_totalPrice);

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Booking & Payment',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: colorScheme.onSurface,
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
                baseAmount: _basePrice,
                platformFee: _platformFee,
                totalAmount: _totalPrice,
              ),
              const SizedBox(height: 24),

              // Payment Method Section
              BookingPaymentMethodList(
                paymentOptions: _paymentOptions,
                selectedPaymentMethod: _selectedPaymentMethod,
                onMethodSelected: (id) =>
                    setState(() => _selectedPaymentMethod = id),
              ),
              const SizedBox(height: 12),

              // Service Address input
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: tokens.subtleCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tokens.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: tokens.brandAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: 'Service Address (e.g. Dhaka, Bangladesh)',
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Optional access / job notes input
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: tokens.subtleCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tokens.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'Special instructions or gate code (optional)',
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Pay Now Action Button
              SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.brandAccent,
                      foregroundColor: tokens.onBrandAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: tokens.onBrandAccent,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _selectedPaymentMethod == 'Cash'
                                ? 'Confirm Cash Booking ($displayAmount)'
                                : 'Confirm & Pay ($displayAmount)',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
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
