import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
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
  String? _errorText;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    final entered = _otpController.text.trim();
    final expected = widget.expectedOtp.trim();
    if (entered.length == 4 && expected.isNotEmpty && entered == expected) {
      setState(() {
        _isVerifyingOtp = true;
        _errorText = null;
      });
      Navigator.pop(context);
      widget.onOtpVerified();
    } else {
      setState(() {
        _isVerifyingOtp = false;
        _errorText =
            'Invalid OTP! Please ask the customer for the correct 4-digit code.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorText!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          color: tokens.sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: tokens.border)),
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
                    color: tokens.border,
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
                      color: tokens.softPeachBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: tokens.brandAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: Text(
                      'Enter Customer Job OTP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Ask the customer for their 4-digit secret Job Completion OTP to confirm satisfactory finish and release your payout.',
                style: TextStyle(
                  fontSize: 13,
                  color: tokens.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                  color: tokens.brandAccent,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: TextStyle(color: tokens.mutedText),
                  errorText: _errorText,
                  filled: true,
                  fillColor: tokens.subtleCardBg,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: tokens.brandAccent, width: 1.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Verify & Release Earnings ৳',
                  isLoading: _isVerifyingOtp,
                  onPressed: _verify,
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
