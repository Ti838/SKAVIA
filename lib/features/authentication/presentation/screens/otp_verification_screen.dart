import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? fullName;

  const OtpVerificationScreen({super.key, this.phoneNumber, this.fullName});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final int _pinLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  final AuthController _authController = AuthController();

  int _resendCountdown = 60;
  Timer? _countdownTimer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_pinLength, (_) => TextEditingController());
    _focusNodes = List.generate(_pinLength, (_) => FocusNode());
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
          _resendCountdown = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _authController.dispose();
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handles copy-paste of multiple digits into one field
      final pasted = value.trim();
      for (int i = 0; i < _pinLength; i++) {
        if (i < pasted.length) {
          _controllers[i].text = pasted[i];
        }
      }
      _focusNodes.last.requestFocus();
      setState(() {});
      if (_currentOtp.length == _pinLength) {
        _handleVerify();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < _pinLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_currentOtp.length == _pinLength) {
          _handleVerify();
        }
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    setState(() {});
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;
    final phone = widget.phoneNumber ?? '+8801700000000';
    final success = await _authController.sendPhoneOtp(phone);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent successfully.'),
          backgroundColor: AppColors.statusActive,
        ),
      );
      _startCountdown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _authController.errorMessage ?? 'Failed to resend code.',
          ),
          backgroundColor: AppColors.statusCancelled,
        ),
      );
    }
  }

  Future<void> _handleVerify() async {
    final otp = _currentOtp;
    if (otp.length < _pinLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits.'),
          backgroundColor: AppColors.accentCoral,
        ),
      );
      return;
    }

    final success = await _authController.verifyPhoneOtp(
      otp,
      fullName: widget.fullName,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone verified successfully! Welcome to SKAVIA.'),
          backgroundColor: AppColors.statusActive,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.appShell,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _authController.errorMessage ?? 'Invalid verification code.',
          ),
          backgroundColor: AppColors.statusCancelled,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayPhone = widget.phoneNumber ?? '+880 17XX-XXXXXX';

    return Scaffold(
      backgroundColor: AppColors.primarySky,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  // Brand Emblem
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      AppAssets.emblem,
                      height: 24,
                      width: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stack) => const Icon(
                        Icons.engineering_rounded,
                        size: 20,
                        color: AppColors.primaryRoyal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top Header Title Area
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify Phone',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit verification code to $displayPhone',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFont,
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // 32dp Curved White Sheet
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.sheetBackground,
                  borderRadius: AppDimensions.roundedSheetTop,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                  child: Column(
                    children: [
                      // Lock & SMS illustration badge
                      Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color: AppColors.accentPeach.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sms_rounded,
                          size: 36,
                          color: AppColors.accentCoral,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Enter 6-Digit Code',
                        style: TextStyle(
                          fontFamily: AppTypography.headingFont,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check your SMS inbox for the one-time code',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFont,
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 6-Pin Input Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_pinLength, (index) {
                          return Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 48,
                                  minWidth: 36,
                                ),
                                child: SizedBox(
                                  height: 56,
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.headingFont,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryRoyal,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.zero,
                                      filled: true,
                                      fillColor: _controllers[index].text.isNotEmpty
                                          ? AppColors.primarySky.withValues(
                                              alpha: 0.08,
                                            )
                                          : AppColors.surfaceVariant,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: _controllers[index].text.isNotEmpty
                                              ? AppColors.primarySky
                                              : AppColors.borderLight,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: AppColors.primarySky,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                    onChanged: (val) => _onDigitChanged(index, val),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 36),

                      // Verify Button
                      ListenableBuilder(
                        listenable: _authController,
                        builder: (context, _) {
                          return AppButton(
                            text: 'Verify & Continue',
                            isLoading: _authController.isLoading,
                            onPressed: _currentOtp.length == _pinLength
                                ? _handleVerify
                                : null,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Resend Code Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFont,
                              fontSize: 13,
                              color: AppColors.textMedium,
                            ),
                          ),
                          _canResend
                              ? GestureDetector(
                                  onTap: _handleResend,
                                  child: const Text(
                                    'Resend Code',
                                    style: TextStyle(
                                      fontFamily: AppTypography.bodyFont,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryRoyal,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Resend in 0:${_resendCountdown.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.bodyFont,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentCoral,
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
