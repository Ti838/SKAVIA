import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Submit button for BookingConfirmationScreen handling Cash vs Escrow Digital Pay.
class BookingActionButton extends StatelessWidget {
  final bool isSubmitting;
  final String selectedPaymentMethod;
  final String displayAmount;
  final VoidCallback onPressed;

  const BookingActionButton({
    super.key,
    required this.isSubmitting,
    required this.selectedPaymentMethod,
    required this.displayAmount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final isBn = context.isBengali;

    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50),
        child: ElevatedButton(
          onPressed: isSubmitting ? null : onPressed,
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
          child: isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: tokens.onBrandAccent,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  selectedPaymentMethod == 'Cash'
                      ? (isBn
                          ? 'ক্যাশ বুকিং নিশ্চিত করুন ($displayAmount)'
                          : 'Confirm Cash Booking ($displayAmount)')
                      : (isBn
                          ? 'নিশ্চিত করুন ও পেমেন্ট করুন ($displayAmount)'
                          : 'Confirm & Pay ($displayAmount)'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
