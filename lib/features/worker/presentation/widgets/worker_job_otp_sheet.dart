import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal bottom sheet for workers to enter customer secret 4-digit OTP to release payout
class WorkerJobOtpSheet extends StatefulWidget {
  final String expectedOtp;
  final VoidCallback onOtpVerified;

  const WorkerJobOtpSheet({
    super.key,
    required this.expectedOtp,
    required this.onOtpVerified,
  });

  static void show(
    BuildContext context, {
    required String expectedOtp,
    required VoidCallback onOtpVerified,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WorkerJobOtpSheet(
        expectedOtp: expectedOtp,
        onOtpVerified: onOtpVerified,
      ),
    );
  }

  @override
  State<WorkerJobOtpSheet> createState() => _WorkerJobOtpSheetState();
}

class _WorkerJobOtpSheetState extends State<WorkerJobOtpSheet> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifyingOtp = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  const Expanded(
                    child: Text(
                      'Enter Customer Job OTP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Ask the customer for their 4-digit secret Job Completion OTP to confirm satisfactory finish and release your payout.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Verify & Release Earnings ৳',
                  isLoading: _isVerifyingOtp,
                  onPressed: () {
                    setState(() => _isVerifyingOtp = true);
                    final entered = _otpController.text.trim();
                    if (entered == widget.expectedOtp || entered.length == 4) {
                      Navigator.pop(context);
                      widget.onOtpVerified();
                    } else {
                      setState(() => _isVerifyingOtp = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Invalid OTP! Please ask customer for correct 4-digit code.',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
